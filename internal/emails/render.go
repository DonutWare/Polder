package emails

import (
	"bytes"
	"embed"
	htmltemplate "html/template"
	"net/url"
	texttemplate "text/template"

	"polder-server/internal/mail"
)

//go:embed templates/layout.html templates/layout.txt
var templateFiles embed.FS

var (
	htmlLayout = htmltemplate.Must(htmltemplate.ParseFS(templateFiles, "templates/layout.html"))
	textLayout = texttemplate.Must(texttemplate.ParseFS(templateFiles, "templates/layout.txt"))
)

type Detail struct {
	Label string
	Value string
}

type Action struct {
	Label string
	URL   string
}

type Code struct {
	Value string
	Note  string
}

type Content struct {
	Subject    string
	Preheader  string
	Heading    string
	Paragraphs []string
	Details    []Detail
	Code       *Code
	Action     *Action
	Closing    []string
	Footer     string
}

type layoutData struct {
	Brand   Brand
	Content Content
	Host    string
}

func Compose(brand Brand, to string, content Content) (mail.Message, error) {
	data := layoutData{Brand: brand, Content: content, Host: hostOf(brand.PublicURL)}
	var html, text bytes.Buffer
	if err := htmlLayout.Execute(&html, data); err != nil {
		return mail.Message{}, err
	}
	if err := textLayout.Execute(&text, data); err != nil {
		return mail.Message{}, err
	}
	message := mail.Message{
		To:      to,
		Subject: content.Subject,
		Text:    text.String(),
		HTML:    html.String(),
	}
	if brand.icon != nil {
		message.Inline = []mail.Attachment{*brand.icon}
	}
	return message, nil
}

func hostOf(publicURL string) string {
	parsed, err := url.Parse(publicURL)
	if err != nil {
		return ""
	}
	return parsed.Host
}
