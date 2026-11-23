package auth

import (
	"context"
	"crypto/rand"
	"crypto/subtle"
	"encoding/base64"
	"math/big"
	"slices"
	"sync"
	"time"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/activity"
	"polder-server/internal/apperr"
	"polder-server/internal/users"
)

const (
	DeviceLoginLifetime = 2 * time.Minute
	deviceLoginKeep     = 5 * time.Minute
	lowestNumber        = 100
	numberRange         = 900
)

type DeviceLoginStatus string

const (
	DeviceLoginPending   DeviceLoginStatus = "pending"
	DeviceLoginApproved  DeviceLoginStatus = "approved"
	DeviceLoginDenied    DeviceLoginStatus = "denied"
	DeviceLoginExpired   DeviceLoginStatus = "expired"
	DeviceLoginCancelled DeviceLoginStatus = "cancelled"
)

func (DeviceLoginStatus) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(DeviceLoginPending), string(DeviceLoginApproved), string(DeviceLoginDenied), string(DeviceLoginExpired), string(DeviceLoginCancelled)}
	return s
}

var errUnknownLoginRequest = apperr.NotFound("this sign-in request has ended")

type DeviceLoginStart struct {
	RequestID string `json:"requestId"`
	PollToken string `json:"pollToken" doc:"Send this when asking for the status; only the new device knows it"`
	Number    int    `json:"number" doc:"Show this; the approving device has to type it"`
	ExpiresIn int    `json:"expiresIn" doc:"Seconds until the request expires"`
}

type DeviceLoginResult struct {
	Status DeviceLoginStatus `json:"status"`
	Tokens *TokenPair        `json:"tokens,omitempty" required:"false" doc:"Sent once, with the first approved answer"`
	Device string            `json:"-"`
}

type DeviceLoginRequest struct {
	Username   string
	Challenge  string
	DeviceName string
	Address    string
}

type deviceLogin struct {
	id        string
	userID    int64
	pollHash  string
	number    int
	device    string
	address   string
	createdAt time.Time
	expiresAt time.Time
	challenge *PendingSignIn
	status    DeviceLoginStatus
	collected bool
	approver  int64
}

type DeviceLogins struct {
	mu       sync.Mutex
	requests map[string]*deviceLogin
	now      func() time.Time
	publish  func(activity.Event)
}

func NewDeviceLogins(publish func(activity.Event)) *DeviceLogins {
	if publish == nil {
		publish = func(activity.Event) {}
	}
	return &DeviceLogins{requests: map[string]*deviceLogin{}, now: time.Now, publish: publish}
}

func (s *Service) UseDeviceLogins(logins *DeviceLogins) {
	s.deviceLogins = logins
}

func (s *Service) StartDeviceLogin(ctx context.Context, request DeviceLoginRequest) (DeviceLoginStart, error) {
	if request.DeviceName == "" {
		request.DeviceName = UnknownDevice
	}
	var userID int64
	var challenge *PendingSignIn
	switch {
	case request.Challenge != "":
		pending, err := s.challenges.Open(request.Challenge)
		if err != nil {
			return DeviceLoginStart{}, err
		}
		userID, challenge = pending.UserID, &pending
	case request.Username != "":
		user, err := s.userKnownAs(ctx, request.Username)
		if err != nil && !apperr.Is(err, apperr.KindNotFound) {
			return DeviceLoginStart{}, err
		}
		if err == nil && !user.Disabled {
			userID = user.ID
		}
	default:
		return DeviceLoginStart{}, apperr.Invalid("send a username or the challenge from the password step")
	}
	return s.deviceLogins.start(userID, challenge, request.DeviceName, request.Address), nil
}

func (d *DeviceLogins) start(userID int64, challenge *PendingSignIn, device, address string) DeviceLoginStart {
	d.mu.Lock()
	defer d.mu.Unlock()
	now := d.now()
	d.sweepLocked(now)
	pollToken, _ := newSecretToken()
	number := lowestNumber + randomBelow(numberRange)
	login := &deviceLogin{
		id:        randomID(),
		userID:    userID,
		pollHash:  hashToken(pollToken),
		number:    number,
		device:    device,
		address:   address,
		createdAt: now,
		expiresAt: now.Add(DeviceLoginLifetime),
		challenge: challenge,
		status:    DeviceLoginPending,
	}
	d.requests[login.id] = login
	if userID != 0 {
		d.publish(activity.Event{Type: activity.EventLoginRequested, UserID: userID, Login: login.public("")})
	}
	return DeviceLoginStart{RequestID: login.id, PollToken: pollToken, Number: number, ExpiresIn: int(DeviceLoginLifetime.Seconds())}
}

func (s *Service) DeviceLoginStatus(ctx context.Context, id, pollToken string) (DeviceLoginResult, error) {
	login, status, err := s.deviceLogins.collect(id, pollToken)
	if err != nil || status != DeviceLoginApproved {
		return DeviceLoginResult{Status: status}, err
	}
	user, err := s.ActiveUser(ctx, login.userID)
	if err != nil {
		return DeviceLoginResult{}, err
	}
	if login.challenge != nil && !s.challenges.Finish(*login.challenge) {
		return DeviceLoginResult{Status: DeviceLoginExpired}, nil
	}
	authenticatedAt, err := s.sessions.AuthenticatedAt(ctx, login.userID, login.approver)
	if err != nil {
		return DeviceLoginResult{}, err
	}
	tokens, err := s.startSession(ctx, user, login.device, MethodDevice, authenticatedAt)
	if err != nil {
		return DeviceLoginResult{}, err
	}
	return DeviceLoginResult{Status: DeviceLoginApproved, Tokens: &tokens, Device: login.device}, nil
}

func (d *DeviceLogins) collect(id, pollToken string) (deviceLogin, DeviceLoginStatus, error) {
	d.mu.Lock()
	defer d.mu.Unlock()
	login, ok := d.requests[id]
	if !ok || subtle.ConstantTimeCompare([]byte(hashToken(pollToken)), []byte(login.pollHash)) != 1 {
		return deviceLogin{}, "", errUnknownLoginRequest
	}
	d.expireLocked(login, d.now())
	if login.status != DeviceLoginApproved {
		return *login, login.status, nil
	}
	if login.collected {
		return deviceLogin{}, "", errUnknownLoginRequest
	}
	login.collected = true
	return *login, DeviceLoginApproved, nil
}

func (s *Service) CancelDeviceLogin(id, pollToken string) error {
	return s.deviceLogins.cancel(id, pollToken)
}

func (d *DeviceLogins) cancel(id, pollToken string) error {
	d.mu.Lock()
	defer d.mu.Unlock()
	login, ok := d.requests[id]
	if !ok || subtle.ConstantTimeCompare([]byte(hashToken(pollToken)), []byte(login.pollHash)) != 1 {
		return errUnknownLoginRequest
	}
	if login.status == DeviceLoginPending {
		d.resolveLocked(login, DeviceLoginCancelled)
	}
	return nil
}

func (s *Service) PendingLoginRequests(userID int64) []activity.LoginRequest {
	return s.deviceLogins.pending(userID)
}

func (d *DeviceLogins) pending(userID int64) []activity.LoginRequest {
	d.mu.Lock()
	defer d.mu.Unlock()
	now := d.now()
	list := []activity.LoginRequest{}
	for _, login := range d.requests {
		if login.userID != userID {
			continue
		}
		d.expireLocked(login, now)
		if login.status == DeviceLoginPending {
			list = append(list, *login.public(""))
		}
	}
	slices.SortFunc(list, func(a, b activity.LoginRequest) int { return a.CreatedAt.Compare(b.CreatedAt) })
	return list
}

func (s *Service) ApproveLoginRequest(approver Identity, id string, number int) error {
	return s.deviceLogins.answer(approver.User.ID, id, func(login *deviceLogin) (DeviceLoginStatus, error) {
		if number != login.number {
			return DeviceLoginDenied, apperr.Forbidden("that wasn't the number on the other device, so the sign-in was refused")
		}
		login.approver = approver.SessionID
		return DeviceLoginApproved, nil
	})
}

func (s *Service) DenyLoginRequest(user users.User, id string) error {
	return s.deviceLogins.answer(user.ID, id, func(*deviceLogin) (DeviceLoginStatus, error) { return DeviceLoginDenied, nil })
}

func (d *DeviceLogins) answer(userID int64, id string, decide func(*deviceLogin) (DeviceLoginStatus, error)) error {
	d.mu.Lock()
	defer d.mu.Unlock()
	login, ok := d.requests[id]
	if !ok || login.userID != userID {
		return errUnknownLoginRequest
	}
	d.expireLocked(login, d.now())
	if login.status != DeviceLoginPending {
		return errUnknownLoginRequest
	}
	outcome, err := decide(login)
	d.resolveLocked(login, outcome)
	return err
}

func (d *DeviceLogins) expireLocked(login *deviceLogin, now time.Time) {
	if login.status == DeviceLoginPending && !now.Before(login.expiresAt) {
		d.resolveLocked(login, DeviceLoginExpired)
	}
}

func (d *DeviceLogins) resolveLocked(login *deviceLogin, status DeviceLoginStatus) {
	login.status = status
	if login.userID != 0 {
		d.publish(activity.Event{Type: activity.EventLoginResolved, UserID: login.userID, Login: login.public(string(status))})
	}
}

func (d *DeviceLogins) sweepLocked(now time.Time) {
	for id, login := range d.requests {
		d.expireLocked(login, now)
		if now.Sub(login.expiresAt) > deviceLoginKeep {
			delete(d.requests, id)
		}
	}
}

func (l *deviceLogin) public(resolution string) *activity.LoginRequest {
	return &activity.LoginRequest{
		ID:         l.id,
		Device:     l.device,
		Address:    l.address,
		CreatedAt:  l.createdAt,
		ExpiresAt:  l.expiresAt,
		Resolution: resolution,
	}
}

func randomBelow(limit int) int {
	value, _ := rand.Int(rand.Reader, big.NewInt(int64(limit)))
	return int(value.Int64())
}

func randomID() string {
	buffer := make([]byte, 16)
	_, _ = rand.Read(buffer)
	return base64.RawURLEncoding.EncodeToString(buffer)
}
