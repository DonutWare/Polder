package auth

import (
	"context"
	"crypto/subtle"
	"database/sql"
	"errors"
	"strconv"
	"time"

	"polder-server/internal/apperr"
	"polder-server/internal/secretbox"
)

const (
	TOTPSecretKeyPurpose = "totp-secrets"
	RecoveryCodeCount    = 10
	recoveryCodeLength   = 10
)

var (
	errInvalidTwoFactorCode = apperr.Unauthorized("the code is wrong or was already used")
	errTwoFactorNotEnabled  = apperr.Invalid("two-factor authentication isn't turned on")
)

type TwoFactor struct {
	db  *sql.DB
	box *secretbox.Box
	now func() time.Time
}

type TwoFactorSetup struct {
	Secret string `json:"secret" doc:"The key to type into an authenticator app, in base32"`
	URL    string `json:"url" doc:"An otpauth:// link with the same key, to show as a QR code"`
}

type RecoveryCodes struct {
	Codes []string `json:"codes" doc:"One-time codes to sign in with when the authenticator app is lost; shown only now"`
}

func NewTwoFactor(db *sql.DB, key []byte) (*TwoFactor, error) {
	box, err := secretbox.New(key)
	if err != nil {
		return nil, err
	}
	return &TwoFactor{db: db, box: box, now: time.Now}, nil
}

func sealContext(userID int64) string {
	return "totp:" + strconv.FormatInt(userID, 10)
}

func (f *TwoFactor) Enabled(ctx context.Context, userID int64) (bool, error) {
	var enabled bool
	err := f.db.QueryRowContext(ctx, `SELECT EXISTS (SELECT 1 FROM user_totp WHERE user_id = $1 AND confirmed_at IS NOT NULL)`, userID).Scan(&enabled)
	return enabled, err
}

func (f *TwoFactor) Begin(ctx context.Context, userID int64, issuer, account string) (TwoFactorSetup, error) {
	enabled, err := f.Enabled(ctx, userID)
	if err != nil {
		return TwoFactorSetup{}, err
	}
	if enabled {
		return TwoFactorSetup{}, apperr.New(apperr.KindConflict, "two-factor authentication is already turned on")
	}
	secret := newTOTPSecret()
	_, err = f.db.ExecContext(ctx, `INSERT INTO user_totp (user_id, secret_sealed, confirmed_at, last_used_step) VALUES ($1, $2, NULL, 0)
		ON CONFLICT (user_id) DO UPDATE SET secret_sealed = excluded.secret_sealed, confirmed_at = NULL, last_used_step = 0`,
		userID, f.box.Seal(secret, sealContext(userID)))
	if err != nil {
		return TwoFactorSetup{}, err
	}
	return TwoFactorSetup{Secret: secret, URL: totpURL(issuer, account, secret)}, nil
}

func (f *TwoFactor) Confirm(ctx context.Context, userID int64, code string) (RecoveryCodes, error) {
	secret, confirmed, lastStep, err := f.load(ctx, userID)
	if errors.Is(err, sql.ErrNoRows) {
		return RecoveryCodes{}, apperr.Invalid("start setting up two-factor authentication first")
	}
	if err != nil {
		return RecoveryCodes{}, err
	}
	if confirmed {
		return RecoveryCodes{}, apperr.New(apperr.KindConflict, "two-factor authentication is already turned on")
	}
	step, ok := matchingStep(secret, code, lastStep, f.now())
	if !ok {
		return RecoveryCodes{}, apperr.Invalid("the code doesn't match; check the time on your device and try again")
	}
	tx, err := f.db.BeginTx(ctx, nil)
	if err != nil {
		return RecoveryCodes{}, err
	}
	defer func() { _ = tx.Rollback() }()
	if _, err := tx.ExecContext(ctx, `UPDATE user_totp SET confirmed_at = $1, last_used_step = $2 WHERE user_id = $3`, f.now().Unix(), step, userID); err != nil {
		return RecoveryCodes{}, err
	}
	codes, err := replaceRecoveryCodes(ctx, tx, userID)
	if err != nil {
		return RecoveryCodes{}, err
	}
	return codes, tx.Commit()
}

func (f *TwoFactor) VerifyCode(ctx context.Context, userID int64, code string) error {
	secret, confirmed, lastStep, err := f.load(ctx, userID)
	if errors.Is(err, sql.ErrNoRows) || (err == nil && !confirmed) {
		return errTwoFactorNotEnabled
	}
	if err != nil {
		return err
	}
	step, ok := matchingStep(secret, code, lastStep, f.now())
	if !ok {
		return errInvalidTwoFactorCode
	}
	result, err := f.db.ExecContext(ctx, `UPDATE user_totp SET last_used_step = $1 WHERE user_id = $2 AND last_used_step < $1`, step, userID)
	if err != nil {
		return err
	}
	if updated, err := result.RowsAffected(); err != nil || updated == 0 {
		return errors.Join(errInvalidTwoFactorCode, err)
	}
	return nil
}

func (f *TwoFactor) UseRecoveryCode(ctx context.Context, userID int64, code string) error {
	result, err := f.db.ExecContext(ctx, `UPDATE user_recovery_codes SET used_at = $1 WHERE user_id = $2 AND code_hash = $3 AND used_at IS NULL`,
		f.now().Unix(), userID, hashToken(normalizeCode(code)))
	if err != nil {
		return err
	}
	if updated, err := result.RowsAffected(); err != nil || updated == 0 {
		return errors.Join(errInvalidTwoFactorCode, err)
	}
	return nil
}

func (f *TwoFactor) RemainingRecoveryCodes(ctx context.Context, userID int64) (int, error) {
	var count int
	err := f.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM user_recovery_codes WHERE user_id = $1 AND used_at IS NULL`, userID).Scan(&count)
	return count, err
}

func (f *TwoFactor) RegenerateRecoveryCodes(ctx context.Context, userID int64) (RecoveryCodes, error) {
	tx, err := f.db.BeginTx(ctx, nil)
	if err != nil {
		return RecoveryCodes{}, err
	}
	defer func() { _ = tx.Rollback() }()
	codes, err := replaceRecoveryCodes(ctx, tx, userID)
	if err != nil {
		return RecoveryCodes{}, err
	}
	return codes, tx.Commit()
}

func (f *TwoFactor) Remove(ctx context.Context, userID int64) error {
	tx, err := f.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback() }()
	if _, err := tx.ExecContext(ctx, `DELETE FROM user_totp WHERE user_id = $1`, userID); err != nil {
		return err
	}
	if _, err := tx.ExecContext(ctx, `DELETE FROM user_recovery_codes WHERE user_id = $1`, userID); err != nil {
		return err
	}
	return tx.Commit()
}

func (f *TwoFactor) load(ctx context.Context, userID int64) (string, bool, int64, error) {
	var sealed string
	var confirmedAt sql.NullInt64
	var lastStep int64
	err := f.db.QueryRowContext(ctx, `SELECT secret_sealed, confirmed_at, last_used_step FROM user_totp WHERE user_id = $1`, userID).
		Scan(&sealed, &confirmedAt, &lastStep)
	if err != nil {
		return "", false, 0, err
	}
	secret, err := f.box.Open(sealed, sealContext(userID))
	return secret, confirmedAt.Valid, lastStep, err
}

func matchingStep(secret, code string, lastStep int64, now time.Time) (int64, bool) {
	code = normalizeTOTPCode(code)
	if len(code) != totpDigits {
		return 0, false
	}
	current := totpStep(now)
	for step := current - totpSkewSteps; step <= current+totpSkewSteps; step++ {
		if step <= lastStep {
			continue
		}
		expected, err := totpCodeAt(secret, step)
		if err == nil && subtle.ConstantTimeCompare([]byte(expected), []byte(code)) == 1 {
			return step, true
		}
	}
	return 0, false
}

func replaceRecoveryCodes(ctx context.Context, tx *sql.Tx, userID int64) (RecoveryCodes, error) {
	if _, err := tx.ExecContext(ctx, `DELETE FROM user_recovery_codes WHERE user_id = $1`, userID); err != nil {
		return RecoveryCodes{}, err
	}
	codes := make([]string, RecoveryCodeCount)
	for i := range codes {
		code := newCode(recoveryCodeLength)
		if _, err := tx.ExecContext(ctx, `INSERT INTO user_recovery_codes (user_id, code_hash) VALUES ($1, $2)`, userID, hashToken(code)); err != nil {
			return RecoveryCodes{}, err
		}
		codes[i] = formatCode(code)
	}
	return RecoveryCodes{Codes: codes}, nil
}
