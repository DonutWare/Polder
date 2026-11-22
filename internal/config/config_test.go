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
