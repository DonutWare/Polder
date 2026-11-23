package auth

import (
	"context"
	"time"

	"polder-server/internal/apperr"
	"polder-server/internal/users"
)

type SecondFactor struct {
	Code         string
	RecoveryCode string
}

type SecondFactorResult struct {
	Tokens           TokenPair
	UsedRecoveryCode bool
}

type TwoFactorState struct {
	Enabled                bool `json:"enabled"`
	RecoveryCodesRemaining int  `json:"recoveryCodesRemaining" doc:"Unused recovery codes left"`
}

func (s *Service) UseTwoFactor(twoFactor *TwoFactor, challenges *Challenges) {
	s.twoFactor = twoFactor
	s.challenges = challenges
}

func (s *Service) requireSecondFactor(ctx context.Context, user users.User, deviceName string) error {
	enabled, err := s.twoFactor.Enabled(ctx, user.ID)
	if err != nil || !enabled {
		return err
	}
	challenge, err := s.challenges.Issue(user.ID, deviceName)
	if err != nil {
		return err
	}
	activeSessions, err := s.sessions.CountActiveForUser(ctx, user.ID)
	if err != nil {
		return err
	}
	return apperr.WithCurrent(apperr.KindTwoFactorRequired, TwoFactorChallenge{
		Challenge:      challenge,
		ExpiresIn:      int(ChallengeLifetime.Seconds()),
		DeviceApproval: activeSessions > 0,
	}, "enter the code from your authenticator app")
}

func (s *Service) OpenChallenge(challenge string) (PendingSignIn, error) {
	return s.challenges.Open(challenge)
}

func (s *Service) CompleteSecondFactor(ctx context.Context, challenge string, factor SecondFactor, deviceName string) (SecondFactorResult, error) {
	pending, err := s.challenges.Open(challenge)
	if err != nil {
		return SecondFactorResult{}, err
	}
	user, err := s.ActiveUser(ctx, pending.UserID)
	if err != nil {
		return SecondFactorResult{}, err
	}
	usedRecovery, err := s.checkSecondFactor(ctx, user.ID, factor)
	if apperr.Is(err, apperr.KindUnauthorized) {
		s.challenges.Failed(pending)
	}
	if err != nil {
		return SecondFactorResult{}, err
	}
	if !s.challenges.Finish(pending) {
		return SecondFactorResult{}, errInvalidChallenge
	}
	if deviceName == "" {
		deviceName = pending.Device
	}
	tokens, err := s.startSession(ctx, user, deviceName, MethodPassword, time.Now())
	return SecondFactorResult{Tokens: tokens, UsedRecoveryCode: usedRecovery}, err
}

func (s *Service) checkSecondFactor(ctx context.Context, userID int64, factor SecondFactor) (bool, error) {
	switch {
	case factor.Code != "":
		return false, s.twoFactor.VerifyCode(ctx, userID, factor.Code)
	case factor.RecoveryCode != "":
		return true, s.twoFactor.UseRecoveryCode(ctx, userID, factor.RecoveryCode)
	}
	return false, apperr.Invalid("send the code from your authenticator app or a recovery code")
}

func (s *Service) TwoFactorState(ctx context.Context, userID int64) (TwoFactorState, error) {
	enabled, err := s.twoFactor.Enabled(ctx, userID)
	if err != nil || !enabled {
		return TwoFactorState{}, err
	}
	remaining, err := s.twoFactor.RemainingRecoveryCodes(ctx, userID)
	return TwoFactorState{Enabled: true, RecoveryCodesRemaining: remaining}, err
}

func (s *Service) BeginTwoFactorSetup(ctx context.Context, user users.User, sessionID int64, password, issuer string) (TwoFactorSetup, error) {
	if err := s.ConfirmPassword(ctx, user, sessionID, password); err != nil {
		return TwoFactorSetup{}, err
	}
	return s.twoFactor.Begin(ctx, user.ID, issuer, user.Username)
}

func (s *Service) ConfirmTwoFactorSetup(ctx context.Context, user users.User, code string) (RecoveryCodes, error) {
	codes, err := s.twoFactor.Confirm(ctx, user.ID, code)
	if err != nil {
		return RecoveryCodes{}, err
	}
	return codes, s.users.Store().SetTwoFactorDeadline(ctx, user.ID, nil)
}

func (s *Service) RegenerateRecoveryCodes(ctx context.Context, user users.User, sessionID int64, password string) (RecoveryCodes, error) {
	if err := s.ConfirmPassword(ctx, user, sessionID, password); err != nil {
		return RecoveryCodes{}, err
	}
	return s.twoFactor.RegenerateRecoveryCodes(ctx, user.ID)
}

func (s *Service) DisableTwoFactor(ctx context.Context, user users.User, sessionID int64, password string) error {
	if err := s.ConfirmPassword(ctx, user, sessionID, password); err != nil {
		return err
	}
	return s.twoFactor.Remove(ctx, user.ID)
}

func (s *Service) ResetTwoFactor(ctx context.Context, userID int64) error {
	if err := s.twoFactor.Remove(ctx, userID); err != nil {
		return err
	}
	return s.LogOutEverywhere(ctx, userID)
}
