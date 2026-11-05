package mail

import (
	"bytes"
	"context"
	"crypto/rand"
	"crypto/tls"
	"encoding/base64"
	"encoding/hex"
	"errors"
	"fmt"
	"mime"
	"mime/multipart"
	"net"
	"net/mail"
	"net/smtp"
	"net/textproto"
	"strconv"
	"strings"
	"time"
)

const (
	SecurityStartTLS = "starttls"
	SecurityTLS      = "tls"
	SecurityNone     = "none"

	dialTimeout = 20 * time.Second
	lineLength  = 76
)

type Options struct {
	Host     string
	Port     int
	Username string
	Password string
	From     string
	Security string
}

type Attachment struct {
	ContentType string
	Filename    string
	Content     []byte
}

type Message struct {
	To          string
	ReplyTo     string
	Subject     string
	Text        string
	Calendar    []byte
	Method      string
	Attachments []Attachment
}

type Sender struct {
	options Options
}

func NewSender(options Options) *Sender {
	if options.Security == "" {
		options.Security = SecurityStartTLS
	}
	if options.Port == 0 {
		options.Port = defaultPort(options.Security)
	}
	return &Sender{options: options}
}

func defaultPort(security string) int {
	switch security {
	case SecurityTLS:
		return 465
	case SecurityNone:
		return 25
	}
	return 587
}

func ValidSecurity(security string) bool {
	return security == "" || security == SecurityStartTLS || security == SecurityTLS || security == SecurityNone
}

func (s *Sender) Configured() bool {
	return s != nil && s.options.Host != "" && s.options.From != ""
}

func (s *Sender) Send(ctx context.Context, message Message) error {
	if !s.Configured() {
		return errors.New("no mail server is configured")
	}
	from, err := mail.ParseAddress(s.options.From)
	if err != nil {
		return fmt.Errorf("the sender address %q: %w", s.options.From, err)
	}
	to, err := mail.ParseAddress(message.To)
	if err != nil {
		return fmt.Errorf("the recipient address %q: %w", message.To, err)
	}
	body, err := compose(from, to, message)
	if err != nil {
		return err
	}
	return s.deliver(ctx, from.Address, to.Address, body)
}

func (s *Sender) deliver(ctx context.Context, from, to string, body []byte) error {
	client, err := s.dial(ctx)
	if err != nil {
		return err
	}
	defer func() { _ = client.Close() }()
	if s.options.Username != "" {
		if err := client.Auth(smtp.PlainAuth("", s.options.Username, s.options.Password, s.options.Host)); err != nil {
			return err
		}
	}
	if err := client.Mail(from); err != nil {
		return err
	}
	if err := client.Rcpt(to); err != nil {
		return err
	}
	writer, err := client.Data()
	if err != nil {
		return err
	}
	if _, err := writer.Write(body); err != nil {
		return err
	}
	if err := writer.Close(); err != nil {
		return err
	}
	return client.Quit()
}

func (s *Sender) dial(ctx context.Context) (*smtp.Client, error) {
	address := net.JoinHostPort(s.options.Host, strconv.Itoa(s.options.Port))
	dialer := &net.Dialer{Timeout: dialTimeout}
	tlsConfig := &tls.Config{ServerName: s.options.Host, MinVersion: tls.VersionTLS12}
	var conn net.Conn
	var err error
	if s.options.Security == SecurityTLS {
		conn, err = (&tls.Dialer{NetDialer: dialer, Config: tlsConfig}).DialContext(ctx, "tcp", address)
	} else {
		conn, err = dialer.DialContext(ctx, "tcp", address)
	}
	if err != nil {
		return nil, err
	}
	if deadline, ok := ctx.Deadline(); ok {
		_ = conn.SetDeadline(deadline)
	}
	client, err := smtp.NewClient(conn, s.options.Host)
	if err != nil {
		_ = conn.Close()
		return nil, err
	}
	if s.options.Security == SecurityStartTLS {
		if err := client.StartTLS(tlsConfig); err != nil {
			_ = client.Close()
			return nil, err
		}
	}
	return client, nil
}

func compose(from, to *mail.Address, message Message) ([]byte, error) {
	var body bytes.Buffer
	writer := multipart.NewWriter(&body)
	if err := writeTextParts(writer, message); err != nil {
		return nil, err
	}
	for _, attachment := range message.Attachments {
		if err := writeAttachment(writer, attachment); err != nil {
			return nil, err
		}
	}
	if err := writer.Close(); err != nil {
		return nil, err
	}
	var head bytes.Buffer
	headers := [][2]string{
		{"From", from.String()},
		{"To", to.String()},
		{"Subject", mime.QEncoding.Encode("utf-8", message.Subject)},
		{"Date", time.Now().Format(time.RFC1123Z)},
		{"Message-ID", "<" + randomID() + "@" + domainOf(from.Address) + ">"},
		{"MIME-Version", "1.0"},
		{"Content-Type", "multipart/mixed; boundary=" + writer.Boundary()},
	}
	if message.ReplyTo != "" {
		headers = append(headers, [2]string{"Reply-To", message.ReplyTo})
	}
	for _, header := range headers {
		head.WriteString(header[0] + ": " + header[1] + "\r\n")
	}
	head.WriteString("\r\n")
	head.Write(body.Bytes())
	return head.Bytes(), nil
}

func writeTextParts(writer *multipart.Writer, message Message) error {
	var alternative bytes.Buffer
	inner := multipart.NewWriter(&alternative)
	if err := writePart(inner, "text/plain; charset=utf-8", "", []byte(message.Text)); err != nil {
		return err
	}
	if len(message.Calendar) > 0 {
		contentType := "text/calendar; charset=utf-8; method=" + message.Method
		if err := writePart(inner, contentType, "", message.Calendar); err != nil {
			return err
		}
	}
	if err := inner.Close(); err != nil {
		return err
	}
	header := textproto.MIMEHeader{}
	header.Set("Content-Type", "multipart/alternative; boundary="+inner.Boundary())
	part, err := writer.CreatePart(header)
	if err != nil {
		return err
	}
	_, err = part.Write(alternative.Bytes())
	return err
}

func writeAttachment(writer *multipart.Writer, attachment Attachment) error {
	disposition := mime.FormatMediaType("attachment", map[string]string{"filename": attachment.Filename})
	return writePart(writer, attachment.ContentType, disposition, attachment.Content)
}

func writePart(writer *multipart.Writer, contentType, disposition string, content []byte) error {
	header := textproto.MIMEHeader{}
	header.Set("Content-Type", contentType)
	header.Set("Content-Transfer-Encoding", "base64")
	if disposition != "" {
		header.Set("Content-Disposition", disposition)
	}
	part, err := writer.CreatePart(header)
	if err != nil {
		return err
	}
	encoded := base64.StdEncoding.EncodeToString(content)
	for len(encoded) > lineLength {
		if _, err := part.Write([]byte(encoded[:lineLength] + "\r\n")); err != nil {
			return err
		}
		encoded = encoded[lineLength:]
	}
	_, err = part.Write([]byte(encoded + "\r\n"))
	return err
}

func randomID() string {
	buffer := make([]byte, 16)
	_, _ = rand.Read(buffer)
	return hex.EncodeToString(buffer)
}

func domainOf(address string) string {
	if _, domain, found := strings.Cut(address, "@"); found {
		return domain
	}
	return "localhost"
}
