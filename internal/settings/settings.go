package settings

import (
	"context"
	"database/sql"
	"encoding/json"
	"regexp"
	"strconv"
	"strings"
	"unicode/utf8"

	"polder-server/internal/apperr"
	"polder-server/internal/users"
)

const (
	trashRetentionDaysKey     = "trash_retention_days"
	trashRetentionEnforcedKey = "trash_retention_enforced"
	searchContentEnabledKey   = "search_content_enabled"
	ocrEnabledKey             = "ocr_enabled"
	ocrLanguagesKey           = "ocr_languages"
	ocrMaxPagesKey            = "ocr_max_pages"
	instanceNameKey           = "instance_name"
	welcomeMessageKey         = "welcome_message"
	accentColorKey            = "accent_color"
	versionsEnabledKey        = "versions_enabled"
	versionsEnforcedKey       = "versions_enforced"
	versionsKeepAllHoursKey   = "versions_keep_all_hours"
	versionsMaxAgeDaysKey     = "versions_max_age_days"
	versionsMaxPerFileKey     = "versions_max_per_file"

	MaxOCRPages = 10000

	maxInstanceNameLength   = 64
	maxWelcomeMessageLength = 500
)

var (
	ocrLanguagePattern = regexp.MustCompile(`^(script/)?[A-Za-z][A-Za-z0-9_]*$`)
	accentColorPattern = regexp.MustCompile(`^#[0-9A-Fa-f]{6}$`)
)

type ServerSettings struct {
	TrashRetentionDays     int      `json:"trashRetentionDays" doc:"Days trashed items are kept before they're deleted permanently; 0 keeps them forever"`
	TrashRetentionEnforced bool     `json:"trashRetentionEnforced" doc:"Apply trashRetentionDays to every user, ignoring their own setting"`
	SearchContentEnabled   bool     `json:"searchContentEnabled" doc:"Read the text inside files so search can find it"`
	OCREnabled             bool     `json:"ocrEnabled" doc:"Recognise text in images and scanned PDF pages"`
	OCRLanguages           []string `json:"ocrLanguages" doc:"Tesseract models read in one pass: languages such as eng or jpn, or whole writing systems such as script/Latin or script/HanS. Missing models are downloaded when needed"`
	OCRMaxPages            int      `json:"ocrMaxPages" doc:"The most PDF pages recognised per file"`
	InstanceName           string   `json:"instanceName" doc:"Name the apps show for this server; empty shows the default"`
	WelcomeMessage         string   `json:"welcomeMessage" doc:"Shown on the login screen; empty shows none"`
	AccentColor            string   `json:"accentColor" doc:"Default accent color as #RRGGBB; empty uses the apps' own default"`
	VersionsEnabled        bool     `json:"versionsEnabled" doc:"Keep earlier versions of files when they're saved over; off turns history off for everyone"`
	VersionsEnforced       bool     `json:"versionsEnforced" doc:"Apply the server's history limits to every user, ignoring their own settings"`
	VersionsKeepAllHours   int      `json:"versionsKeepAllHours" doc:"Hours during which every saved version is kept; older versions thin out gradually"`
	VersionsMaxAgeDays     int      `json:"versionsMaxAgeDays" doc:"Days earlier versions are kept; 0 for no age limit. Users can only choose less"`
	VersionsMaxPerFile     int      `json:"versionsMaxPerFile" doc:"Most earlier versions kept per file; 0 for no count limit. Users can only choose fewer"`
}

type ServerSettingsChanges struct {
	TrashRetentionDays     *int      `json:"trashRetentionDays" required:"false" doc:"Days trashed items are kept; 0 keeps them forever"`
	TrashRetentionEnforced *bool     `json:"trashRetentionEnforced" required:"false" doc:"Apply trashRetentionDays to every user, ignoring their own setting"`
	SearchContentEnabled   *bool     `json:"searchContentEnabled" required:"false" doc:"Read the text inside files so search can find it"`
	OCREnabled             *bool     `json:"ocrEnabled" required:"false" doc:"Recognise text in images and scanned PDF pages"`
	OCRLanguages           *[]string `json:"ocrLanguages" required:"false" doc:"Tesseract models read in one pass: languages such as eng or jpn, or whole writing systems such as script/Latin or script/HanS. Missing models are downloaded when needed"`
	OCRMaxPages            *int      `json:"ocrMaxPages" required:"false" minimum:"1" maximum:"10000" doc:"The most PDF pages recognised per file"`
	InstanceName           *string   `json:"instanceName" required:"false" maxLength:"64" doc:"Name the apps show for this server; empty shows the default"`
	WelcomeMessage         *string   `json:"welcomeMessage" required:"false" maxLength:"500" doc:"Shown on the login screen; empty shows none"`
	AccentColor            *string   `json:"accentColor" required:"false" doc:"Default accent color as #RRGGBB; empty uses the apps' own default"`
	VersionsEnabled        *bool     `json:"versionsEnabled" required:"false" doc:"Keep earlier versions of files when they're saved over; off turns history off for everyone"`
	VersionsEnforced       *bool     `json:"versionsEnforced" required:"false" doc:"Apply the server's history limits to every user, ignoring their own settings"`
	VersionsKeepAllHours   *int      `json:"versionsKeepAllHours" required:"false" minimum:"0" maximum:"720" doc:"Hours during which every saved version is kept"`
	VersionsMaxAgeDays     *int      `json:"versionsMaxAgeDays" required:"false" minimum:"0" maximum:"3650" doc:"Days earlier versions are kept; 0 for no age limit"`
	VersionsMaxPerFile     *int      `json:"versionsMaxPerFile" required:"false" minimum:"0" maximum:"10000" doc:"Most earlier versions kept per file; 0 for no count limit"`
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
	if c.VersionsKeepAllHours != nil && (*c.VersionsKeepAllHours < 0 || *c.VersionsKeepAllHours > MaxVersionKeepAllHours) {
		return apperr.Invalid("hours to keep every version must be between 0 and %d", MaxVersionKeepAllHours)
	}
	return ValidateVersionLimits(c.VersionsMaxAgeDays, c.VersionsMaxPerFile)
}

type Store struct {
	db       *sql.DB
	defaults ServerSettings
}

func NewStore(db *sql.DB, defaults ServerSettings) *Store {
	return &Store{db: db, defaults: defaults}
}

func (s *Store) Get(ctx context.Context) (ServerSettings, error) {
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
		case trashRetentionEnforcedKey:
			if enforced, err := strconv.ParseBool(value); err == nil {
				current.TrashRetentionEnforced = enforced
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
		case versionsEnforcedKey:
			if enforced, err := strconv.ParseBool(value); err == nil {
				current.VersionsEnforced = enforced
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
		}
	}
	return current, rows.Err()
}

func (s *Store) Update(ctx context.Context, changes ServerSettingsChanges) (ServerSettings, error) {
	if err := changes.validate(); err != nil {
		return ServerSettings{}, err
	}
	values := map[string]string{}
	if changes.TrashRetentionDays != nil {
		values[trashRetentionDaysKey] = strconv.Itoa(*changes.TrashRetentionDays)
	}
	if changes.TrashRetentionEnforced != nil {
		values[trashRetentionEnforcedKey] = strconv.FormatBool(*changes.TrashRetentionEnforced)
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
	if changes.VersionsEnforced != nil {
		values[versionsEnforcedKey] = strconv.FormatBool(*changes.VersionsEnforced)
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
	if err := s.save(ctx, values); err != nil {
		return ServerSettings{}, err
	}
	return s.Get(ctx)
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
