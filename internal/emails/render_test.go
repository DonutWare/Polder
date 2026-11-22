package emails

import (
	"bytes"
	"context"
	"strings"
	"testing"

	"polder-server/internal/mail"
)

func TestComposeUsesBrand(t *testing.T) {
	brand := Brand{Name: "Acme Cloud", Accent: "#3E63DD", OnAccent: readableOn("#3E63DD"), PublicURL: "https://cloud.example.com",
		IconCID: iconContentID, icon: &mail.Attachment{ContentType: "image/png", Filename: "icon.png", ContentID: iconContentID, Content: []byte{1}}}
	message, err := Compose(brand, "alice@example.com", Content{
		Subject:    "Reset your password",
		Heading:    "Reset your password",
		Paragraphs: []string{"Someone asked to reset <your> password."},
		Details:    []Detail{{Label: "IP address", Value: "203.0.113.9"}},
		Action:     &Action{Label: "Choose a new password", URL: "https://cloud.example.com/reset-password/abc"},
	})
	if err != nil {
		t.Fatal(err)
	}
	for _, want := range []string{"Acme Cloud", "background:#3E63DD", "color:#FFFFFF", `src="cid:brand-icon@polder"`,
		`href="https://cloud.example.com/reset-password/abc"`, "&lt;your&gt;", "203.0.113.9", "cloud.example.com</a>"} {
		if !strings.Contains(message.HTML, want) {
			t.Errorf("HTML lacks %q", want)
		}
	}
	if strings.Contains(message.HTML, "ZgotmplZ") {
		t.Error("the HTML template refused a value")
	}
	for _, want := range []string{"Reset your password", "IP address: 203.0.113.9", "Choose a new password: https://cloud.example.com/reset-password/abc", "Sent by Acme Cloud"} {
		if !strings.Contains(message.Text, want) {
			t.Errorf("text lacks %q:\n%s", want, message.Text)
		}
	}
	if len(message.Inline) != 1 {
		t.Errorf("inline images = %d, want the icon", len(message.Inline))
	}
}

func TestReadableOnPicksContrastingText(t *testing.T) {
	cases := map[string]string{"#24E2F2": darkText, "#FFFF00": darkText, "#3E63DD": lightText, "#000000": lightText, "bogus": darkText}
	for accent, want := range cases {
		if got := readableOn(accent); got != want {
			t.Errorf("readableOn(%s) = %s, want %s", accent, got, want)
		}
	}
}

func TestInlineIconSkipsSVG(t *testing.T) {
	if _, ok := inlineImageTypes["image/svg+xml"]; ok {
		t.Error("SVG icons should not be inlined")
	}
}

func TestCurrentBrandFallsBackToDefaultIcon(t *testing.T) {
	brand := BrandSource{}.Current(context.Background())
	if brand.IconCID != iconContentID || brand.icon == nil || !bytes.Equal(brand.icon.Content, defaultIcon) {
		t.Error("a server without its own icon should send the default Polder icon")
	}
}
