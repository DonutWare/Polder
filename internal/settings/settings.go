package settings

import (
	"context"
	"database/sql"
	"encoding/json"
	netmail "net/mail"
	"regexp"
	"strconv"
	"strings"
	"unicode/utf8"

	"polder-server/internal/apperr"
	"polder-server/internal/mail"
	"polder-server/internal/users"
)

const (
	trashRetentionDaysKey   = "trash_retention_days"
	trashEnabledKey         = "trash_enabled"
	searchContentEnabledKey = "search_content_enabled"
	ocrEnabledKey           = "ocr_enabled"
	ocrLanguagesKey         = "ocr_languages"
	ocrMaxPagesKey          = "ocr_max_pages"
	instanceNameKey         = "instance_name"
	welcomeMessageKey       = "welcome_message"
	accentColorKey          = "accent_color"
	versionsEnabledKey      = "versions_enabled"
	versionsKeepAllHoursKey = "versions_keep_all_hours"
	versionsMaxAgeDaysKey   = "versions_max_age_days"
	versionsMaxPerFileKey   = "versions_max_per_file"
	federationEnabledKey    = "federation_enabled"
	smtpHostKey             = "smtp_host"
	smtpPortKey             = "smtp_port"
	smtpUsernameKey         = "smtp_username"
	smtpPasswordKey         = "smtp_password"
	smtpFromKey             = "smtp_from"
	smtpSecurityKey         = "smtp_security"

	MaxOCRPages = 10000

	maxInstanceNameLength   = 64
	maxWelcomeMessageLength = 500
	maxSMTPPort             = 65535
)

var (
	ocrLanguagePattern = regexp.MustCompile(`^(script/)?[A-Za-z][A-Za-z0-9_]*$`)
	accentColorPattern = regexp.MustCompile(`^#[0-9A-Fa-f]{6}$`)
)

type ServerSettings struct {
	TrashEnabled         bool     `json:"trashEnabled" doc:"Move deleted items to the trash; off deletes them permanently for everyone"`
	TrashRetentionDays   int      `json:"trashRetentionDays" doc:"Days trashed items are kept before they're deleted permanently; 0 keeps them forever. Users can only choose less"`
	SearchContentEnabled bool     `json:"searchContentEnabled" doc:"Read the text inside files so search can find it"`
	OCREnabled           bool     `json:"ocrEnabled" doc:"Recognise text in images and scanned PDF pages"`
	OCRLanguages         []string `json:"ocrLanguages" doc:"Tesseract models read in one pass: languages such as eng or jpn, or whole writing systems such as script/Latin or script/HanS. Missing models are downloaded when needed"`
	OCRMaxPages          int      `json:"ocrMaxPages" doc:"The most PDF pages recognised per file"`
	InstanceName         string   `json:"instanceName" doc:"Name the apps show for this server; empty shows the default"`
	WelcomeMessage       string   `json:"welcomeMessage" doc:"Shown on the login screen; empty shows none"`
	AccentColor          string   `json:"accentColor" doc:"Default accent color as #RRGGBB; empty uses the apps' own default"`
	VersionsEnabled      bool     `json:"versionsEnabled" doc:"Keep earlier versions of files when they're saved over; off turns history off for everyone"`
	VersionsKeepAllHours int      `json:"versionsKeepAllHours" doc:"Hours during which every saved version is kept; older versions thin out gradually. Users can only choose less"`
	VersionsMaxAgeDays   int      `json:"versionsMaxAgeDays" doc:"Days earlier versions are kept; 0 for no age limit. Users can only choose less"`
	VersionsMaxPerFile   int      `json:"versionsMaxPerFile" doc:"Most earlier versions kept per file; 0 for no count limit. Users can only choose fewer"`
	FederationEnabled    bool     `json:"federationEnabled" doc:"Share with people on trusted servers that support Open Cloud Mesh; needs publicUrl in the server config"`
	SMTPHost             string   `json:"smtpHost" doc:"Mail server for emails; empty sends none"`
	SMTPPort             int      `json:"smtpPort" doc:"Mail server port; 0 picks 587, 465 with tls or 25 with none"`
	SMTPUsername         string   `json:"smtpUsername" doc:"Mail server login; empty skips logging in"`
	SMTPPasswordSet      bool     `json:"smtpPasswordSet" doc:"Whether a mail server password is stored; the password itself is never shown"`
	SMTPFrom             string   `json:"smtpFrom" doc:"Sender address, such as Polder <polder@example.com>"`
	SMTPSecurity         string   `json:"smtpSecurity" enum:"starttls,tls,none" doc:"How the connection to the mail server is secured"`
	SMTPManagedByConfig  bool     `json:"smtpManagedByConfig" doc:"The mail server is set in the server config or environment, so it can't be changed here"`
	smtpPassword         string
}

type ServerSettingsChanges struct {
	TrashEnabled         *bool     `json:"trashEnabled" required:"false" doc:"Move deleted items to the trash; off deletes them permanently for everyone"`
	TrashRetentionDays   *int      `json:"trashRetentionDays" required:"false" doc:"Days trashed items are kept; 0 keeps them forever. Users can only choose less"`
	SearchContentEnabled *bool     `json:"searchContentEnabled" required:"false" doc:"Read the text inside files so search can find it"`
	OCREnabled           *bool     `json:"ocrEnabled" required:"false" doc:"Recognise text in images and scanned PDF pages"`
	OCRLanguages         *[]string `json:"ocrLanguages" required:"false" doc:"Tesseract models read in one pass: languages such as eng or jpn, or whole writing systems such as script/Latin or script/HanS. Missing models are downloaded when needed"`
	OCRMaxPages          *int      `json:"ocrMaxPages" required:"false" minimum:"1" maximum:"10000" doc:"The most PDF pages recognised per file"`
	InstanceName         *string   `json:"instanceName" required:"false" maxLength:"64" doc:"Name the apps show for this server; empty shows the default"`
	WelcomeMessage       *string   `json:"welcomeMessage" required:"false" maxLength:"500" doc:"Shown on the login screen; empty shows none"`
	AccentColor          *string   `json:"accentColor" required:"false" doc:"Default accent color as #RRGGBB; empty uses the apps' own default"`
	VersionsEnabled      *bool     `json:"versionsEnabled" required:"false" doc:"Keep earlier versions of files when they're saved over; off turns history off for everyone"`
	VersionsKeepAllHours *int      `json:"versionsKeepAllHours" required:"false" minimum:"0" maximum:"720" doc:"Hours during which every saved version is kept. Users can only choose less"`
	VersionsMaxAgeDays   *int      `json:"versionsMaxAgeDays" required:"false" minimum:"0" maximum:"3650" doc:"Days earlier versions are kept; 0 for no age limit"`
	VersionsMaxPerFile   *int      `json:"versionsMaxPerFile" required:"false" minimum:"0" maximum:"10000" doc:"Most earlier versions kept per file; 0 for no count limit"`
	FederationEnabled    *bool     `json:"federationEnabled" required:"false" doc:"Share with people on trusted servers that support Open Cloud Mesh; needs publicUrl in the server config"`
	SMTPHost             *string   `json:"smtpHost" required:"false" doc:"Mail server for emails; empty sends none"`
	SMTPPort             *int      `json:"smtpPort" required:"false" minimum:"0" maximum:"65535" doc:"Mail server port; 0 picks the usual port for the security"`
	SMTPUsername         *string   `json:"smtpUsername" required:"false" doc:"Mail server login; empty skips logging in"`
	SMTPPassword         *string   `json:"smtpPassword" required:"false" doc:"Mail server password; empty removes it"`
	SMTPFrom             *string   `json:"smtpFrom" required:"false" doc:"Sender address, such as Polder <polder@example.com>"`
	SMTPSecurity         *string   `json:"smtpSecurity" required:"false" enum:"starttls,tls,none" doc:"How the connection to the mail server is secured"`
}

func (c ServerSettingsChanges) changesMail() bool {
	return c.SMTPHost != nil || c.SMTPPort != nil || c.SMTPUsername != nil || c.SMTPPassword != nil || c.SMTPFrom != nil || c.SMTPSecurity != nil
}

func (c ServerSettingsChanges) validateMail() error {
	if c.SMTPPort != nil && (*c.SMTPPort < 0 || *c.SMTPPort > maxSMTPPort) {
		return apperr.Invalid("mail server port must be between 0 and %d", maxSMTPPort)
	}
	if c.SMTPSecurity != nil && !mail.ValidSecurity(*c.SMTPSecurity) {
		return apperr.Invalid("mail security must be %q, %q or %q", mail.SecurityStartTLS, mail.SecurityTLS, mail.SecurityNone)
	}
	if c.SMTPFrom != nil && strings.TrimSpace(*c.SMTPFrom) != "" {
		if _, err := netmail.ParseAddress(strings.TrimSpace(*c.SMTPFrom)); err != nil {
			return apperr.Invalid("%q is not an email address", *c.SMTPFrom)
		}
	}
	return nil
}

func (c ServerSettingsChanges) validate() error {
	if c.TrashRetentionDays != nil {
		if err := users.ValidateRetentionDays(*c.TrashRetentionDays); err != nil {
			return err
		}
	}
	if c.OCRLanguages != nil {
		for _, language := range *c.OCRLanguages {
			if !ocrLanguagePattern.MatchString(language) {
				return apperr.Invalid("%q is not a Tesseract model name", language)
			}
		}
	}
	if c.OCRMaxPages != nil && (*c.OCRMaxPages < 1 || *c.OCRMaxPages > MaxOCRPages) {
		return apperr.Invalid("OCR page limit must be between 1 and %d", MaxOCRPages)
	}
	if c.InstanceName != nil && utf8.RuneCountInString(strings.TrimSpace(*c.InstanceName)) > maxInstanceNameLength {
		return apperr.Invalid("name must be at most %d characters", maxInstanceNameLength)
	}
	if c.WelcomeMessage != nil && utf8.RuneCountInString(strings.TrimSpace(*c.WelcomeMessage)) > maxWelcomeMessageLength {
		return apperr.Invalid("welcome message must be at most %d characters", maxWelcomeMessageLength)
	}
	if c.AccentColor != nil && *c.AccentColor != "" && !accentColorPattern.MatchString(*c.AccentColor) {
		return apperr.Invalid("%q is not a color as #RRGGBB", *c.AccentColor)
	}
	if err := c.validateMail(); err != nil {
		return err
	}
	return ValidateVersionLimits(c.VersionsKeepAllHours, c.VersionsMaxAgeDays, c.VersionsMaxPerFile)
}

type Store struct {
	db         *sql.DB
	defaults   ServerSettings
	configured mail.Options
}

func NewStore(db *sql.DB, defaults ServerSettings) *Store {
	return &Store{db: db, defaults: defaults}
}

func (s *Store) UseConfiguredMail(options mail.Options) {
	s.configured = options
}

func (s *Store) mailManagedByConfig() bool {
	return s.configured.Host != ""
}

func (s *Store) MailOptions(ctx context.Context) (mail.Options, error) {
	if s.mailManagedByConfig() {
		return s.configured, nil
	}
	current, err := s.Get(ctx)
	if err != nil {
		return mail.Options{}, err
	}
	return mail.Options{
		Host:     current.SMTPHost,
		Port:     current.SMTPPort,
		Username: current.SMTPUsername,
		Password: current.smtpPassword,
		From:     current.SMTPFrom,
		Security: current.SMTPSecurity,
	}, nil
}

func (s *Store) Get(ctx context.Context) (ServerSettings, error) {
	current, err := s.stored(ctx)
	if err != nil {
		return ServerSettings{}, err
	}
	if s.mailManagedByConfig() {
		current.SMTPHost = s.configured.Host
		current.SMTPPort = s.configured.Port
		current.SMTPUsername = s.configured.Username
		current.smtpPassword = s.configured.Password
		current.SMTPFrom = s.configured.From
		current.SMTPSecurity = s.configured.Security
		current.SMTPManagedByConfig = true
	}
	if current.SMTPSecurity == "" {
		current.SMTPSecurity = mail.SecurityStartTLS
	}
	current.SMTPPasswordSet = current.smtpPassword != ""
	return current, nil
}

func (s *Store) stored(ctx context.Context) (ServerSettings, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT name, value FROM server_settings`)
	if err != nil {
		return ServerSettings{}, err
	}
	defer rows.Close()

	current := s.defaults
	for rows.Next() {
		var name, value string
		if err := rows.Scan(&name, &value); err != nil {
			return ServerSettings{}, err
		}
		switch name {
		case trashRetentionDaysKey:
			if days, err := strconv.Atoi(value); err == nil {
				current.TrashRetentionDays = days
			}
		case trashEnabledKey:
			if enabled, err := strconv.ParseBool(value); err == nil {
				current.TrashEnabled = enabled
			}
		case searchContentEnabledKey:
			if enabled, err := strconv.ParseBool(value); err == nil {
				current.SearchContentEnabled = enabled
			}
		case ocrEnabledKey:
			if enabled, err := strconv.ParseBool(value); err == nil {
				current.OCREnabled = enabled
			}
		case ocrLanguagesKey:
			var languages []string
			if err := json.Unmarshal([]byte(value), &languages); err == nil {
				current.OCRLanguages = languages
			}
		case ocrMaxPagesKey:
			if pages, err := strconv.Atoi(value); err == nil {
				current.OCRMaxPages = pages
			}
		case instanceNameKey:
			current.InstanceName = value
		case welcomeMessageKey:
			current.WelcomeMessage = value
		case accentColorKey:
			current.AccentColor = value
		case versionsEnabledKey:
			if enabled, err := strconv.ParseBool(value); err == nil {
				current.VersionsEnabled = enabled
			}
		case versionsKeepAllHoursKey:
			if hours, err := strconv.Atoi(value); err == nil {
				current.VersionsKeepAllHours = hours
			}
		case versionsMaxAgeDaysKey:
			if days, err := strconv.Atoi(value); err == nil {
				current.VersionsMaxAgeDays = days
			}
		case versionsMaxPerFileKey:
			if count, err := strconv.Atoi(value); err == nil {
				current.VersionsMaxPerFile = count
			}
		case federationEnabledKey:
			if enabled, err := strconv.ParseBool(value); err == nil {
				current.FederationEnabled = enabled
			}
		default:
			readMailSetting(&current, name, value)
		}
	}
	return current, rows.Err()
}

func (s *Store) Update(ctx context.Context, changes ServerSettingsChanges) (ServerSettings, error) {
	if err := changes.validate(); err != nil {
		return ServerSettings{}, err
	}
	if changes.changesMail() && s.mailManagedByConfig() {
		return ServerSettings{}, apperr.Invalid("the mail server is set in the server config, so it can't be changed here")
	}
	values := map[string]string{}
	writeMailSettings(values, changes)
	if changes.TrashRetentionDays != nil {
		values[trashRetentionDaysKey] = strconv.Itoa(*changes.TrashRetentionDays)
	}
	if changes.TrashEnabled != nil {
		values[trashEnabledKey] = strconv.FormatBool(*changes.TrashEnabled)
	}
	if changes.SearchContentEnabled != nil {
		values[searchContentEnabledKey] = strconv.FormatBool(*changes.SearchContentEnabled)
	}
	if changes.OCREnabled != nil {
		values[ocrEnabledKey] = strconv.FormatBool(*changes.OCREnabled)
	}
	if changes.OCRLanguages != nil {
		encoded, _ := json.Marshal(*changes.OCRLanguages)
		values[ocrLanguagesKey] = string(encoded)
	}
	if changes.OCRMaxPages != nil {
		values[ocrMaxPagesKey] = strconv.Itoa(*changes.OCRMaxPages)
	}
	if changes.InstanceName != nil {
		values[instanceNameKey] = strings.TrimSpace(*changes.InstanceName)
	}
	if changes.WelcomeMessage != nil {
		values[welcomeMessageKey] = strings.TrimSpace(*changes.WelcomeMessage)
	}
	if changes.AccentColor != nil {
		values[accentColorKey] = strings.ToUpper(*changes.AccentColor)
	}
	if changes.VersionsEnabled != nil {
		values[versionsEnabledKey] = strconv.FormatBool(*changes.VersionsEnabled)
	}
	if changes.VersionsKeepAllHours != nil {
		values[versionsKeepAllHoursKey] = strconv.Itoa(*changes.VersionsKeepAllHours)
	}
	if changes.VersionsMaxAgeDays != nil {
		values[versionsMaxAgeDaysKey] = strconv.Itoa(*changes.VersionsMaxAgeDays)
	}
	if changes.VersionsMaxPerFile != nil {
		values[versionsMaxPerFileKey] = strconv.Itoa(*changes.VersionsMaxPerFile)
	}
	if changes.FederationEnabled != nil {
		values[federationEnabledKey] = strconv.FormatBool(*changes.FederationEnabled)
	}
	if err := s.save(ctx, values); err != nil {
		return ServerSettings{}, err
	}
	return s.Get(ctx)
}

func readMailSetting(current *ServerSettings, name, value string) {
	switch name {
	case smtpHostKey:
		current.SMTPHost = value
	case smtpPortKey:
		if port, err := strconv.Atoi(value); err == nil {
			current.SMTPPort = port
		}
	case smtpUsernameKey:
		current.SMTPUsername = value
	case smtpPasswordKey:
		current.smtpPassword = value
	case smtpFromKey:
		current.SMTPFrom = value
	case smtpSecurityKey:
		current.SMTPSecurity = value
	}
}

func writeMailSettings(values map[string]string, changes ServerSettingsChanges) {
	texts := map[string]*string{
		smtpHostKey:     changes.SMTPHost,
		smtpUsernameKey: changes.SMTPUsername,
		smtpFromKey:     changes.SMTPFrom,
		smtpSecurityKey: changes.SMTPSecurity,
	}
	for key, value := range texts {
		if value != nil {
			values[key] = strings.TrimSpace(*value)
		}
	}
	if changes.SMTPPassword != nil {
		values[smtpPasswordKey] = *changes.SMTPPassword
	}
	if changes.SMTPPort != nil {
		values[smtpPortKey] = strconv.Itoa(*changes.SMTPPort)
	}
}

func (s *Store) save(ctx context.Context, values map[string]string) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback() }()
	for name, value := range values {
		_, err := tx.ExecContext(ctx,
			`INSERT INTO server_settings (name, value) VALUES ($1, $2) ON CONFLICT (name) DO UPDATE SET value = excluded.value`, name, value)
		if err != nil {
			return err
		}
	}
	return tx.Commit()
}
