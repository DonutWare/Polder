package mail

import (
	"bytes"
	"io"
	"mime"
	"mime/multipart"
	netmail "net/mail"
	"strings"
	"testing"
)

func TestComposeNestsHTMLAndInlineImages(t *testing.T) {
	from, _ := netmail.ParseAddress("Polder <polder@example.com>")
	to, _ := netmail.ParseAddress("alice@example.com")
	raw, err := compose(from, to, Message{
		Subject: "Welcome",
		Text:    "plain body",
		HTML:    "<p>html body</p>",
		Inline:  []Attachment{{ContentType: "image/png", Filename: "icon.png", ContentID: "icon@polder", Content: []byte("png")}},
	})
	if err != nil {
		t.Fatal(err)
	}
	parsed, err := netmail.ReadMessage(bytes.NewReader(raw))
	if err != nil {
		t.Fatal(err)
	}
	mixed := partsOf(t, parsed.Header.Get("Content-Type"), parsed.Body)
	if len(mixed) != 1 || !strings.HasPrefix(mixed[0].contentType, "multipart/related") {
		t.Fatalf("mixed parts: %+v", mixed)
	}
	related := partsOf(t, mixed[0].contentType, bytes.NewReader(mixed[0].body))
	if len(related) != 2 || !strings.HasPrefix(related[0].contentType, "multipart/alternative") || related[1].contentID != "<icon@polder>" {
		t.Fatalf("related parts: %+v", related)
	}
	alternative := partsOf(t, related[0].contentType, bytes.NewReader(related[0].body))
	if len(alternative) != 2 || !strings.HasPrefix(alternative[0].contentType, "text/plain") || !strings.HasPrefix(alternative[1].contentType, "text/html") {
		t.Fatalf("alternative parts: %+v", alternative)
	}
}

func TestComposeWithoutInlineImagesKeepsAlternativeOnly(t *testing.T) {
	from, _ := netmail.ParseAddress("polder@example.com")
	to, _ := netmail.ParseAddress("bob@example.com")
	raw, err := compose(from, to, Message{Subject: "Hi", Text: "plain"})
	if err != nil {
		t.Fatal(err)
	}
	parsed, _ := netmail.ReadMessage(bytes.NewReader(raw))
	mixed := partsOf(t, parsed.Header.Get("Content-Type"), parsed.Body)
	if len(mixed) != 1 || !strings.HasPrefix(mixed[0].contentType, "multipart/alternative") {
		t.Fatalf("mixed parts: %+v", mixed)
	}
}

type mimePart struct {
	contentType string
	contentID   string
	body        []byte
}

func partsOf(t *testing.T, contentType string, body io.Reader) []mimePart {
	t.Helper()
	_, params, err := mime.ParseMediaType(contentType)
	if err != nil {
		t.Fatal(err)
	}
	reader := multipart.NewReader(body, params["boundary"])
	var parts []mimePart
	for {
		part, err := reader.NextRawPart()
		if err == io.EOF {
			return parts
		}
		if err != nil {
			t.Fatal(err)
		}
		content, _ := io.ReadAll(part)
		parts = append(parts, mimePart{contentType: part.Header.Get("Content-Type"), contentID: part.Header.Get("Content-ID"), body: content})
	}
}
