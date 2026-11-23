package config

import "testing"

func TestEmptyComposeMailVariablesLeaveDefaults(t *testing.T) {
	t.Setenv("POLDER_CONFIG_DIR", t.TempDir())
	for _, name := range []string{"POLDER_SMTP_HOST", "POLDER_SMTP_PORT", "POLDER_SMTP_SECURITY", "POLDER_SMTP_FROM", "POLDER_PUBLIC_URL"} {
		t.Setenv(name, "")
	}
	cfg, err := Load()
	if err != nil {
		t.Fatal(err)
	}
	if cfg.SMTPHost != "" || cfg.SMTPPort != 0 {
		t.Fatalf("empty variables should leave mail unset: %+v", cfg)
	}
}

func TestPublicURLNeedsHTTPSExceptOnThisComputer(t *testing.T) {
	for address, valid := range map[string]bool{
		"https://files.example.com":    true,
		"http://localhost:6060":        true,
		"http://127.0.0.1:6060":        true,
		"http://[::1]:6060":            true,
		"http://files.example.com":     false,
		"http://localhost.example.com": false,
		"https://files.example.com/x":  false,
		"ftp://localhost":              false,
	} {
		cfg := Default()
		cfg.PublicURL = address
		if err := cfg.validate(); (err == nil) != valid {
			t.Errorf("%s: valid = %v, error = %v", address, valid, err)
		}
	}
}
