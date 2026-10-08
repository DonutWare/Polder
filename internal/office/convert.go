package office

import (
	"context"
	"errors"
	"fmt"
	"io"
	"mime"
	"mime/multipart"
	"net"
	"net/http"
	"time"
)

const convertTimeout = 2 * time.Minute

var ErrUnavailable = errors.New("the document editor cannot convert documents")

func (s *Service) ConvertibleMimes(ctx context.Context) map[string]bool {
	if !s.Enabled() {
		return nil
	}
	found, err := s.discovery.get(ctx)
	if err != nil {
		return nil
	}
	convertible := make(map[string]bool, len(found.byMime))
	for mimeType := range found.byMime {
		convertible[mimeType] = true
	}
	for extension := range found.byExtension {
		if mimeType, _, err := mime.ParseMediaType(mime.TypeByExtension("." + extension)); err == nil {
			convertible[mimeType] = true
		}
	}
	return convertible
}

func (s *Service) ConvertToPDF(ctx context.Context, name string, content io.Reader) (io.ReadCloser, error) {
	if !s.Enabled() {
		return nil, ErrUnavailable
	}

	body, writer := io.Pipe()
	form := multipart.NewWriter(writer)
	go func() {
		part, err := form.CreateFormFile("data", name)
		if err == nil {
			_, err = io.Copy(part, content)
		}
		if err == nil {
			err = form.Close()
		}
		writer.CloseWithError(err)
	}()

	endpoint := s.collabora.JoinPath("cool", "convert-to", "pdf").String()
	request, err := http.NewRequestWithContext(ctx, http.MethodPost, endpoint, body)
	if err != nil {
		body.Close()
		return nil, err
	}
	request.Header.Set("Content-Type", form.FormDataContentType())
	response, err := s.converter.Do(request)
	if err != nil {
		var dialFailed *net.OpError
		if errors.As(err, &dialFailed) && dialFailed.Op == "dial" {
			return nil, fmt.Errorf("%w: %w", ErrUnavailable, err)
		}
		return nil, fmt.Errorf("convert %s: %w", name, err)
	}
	if response.StatusCode == http.StatusOK {
		return response.Body, nil
	}
	response.Body.Close()
	if response.StatusCode == http.StatusForbidden {
		return nil, fmt.Errorf("%w: Collabora refuses conversions from this server; add its address to Collabora's net.post_allow.host",
			ErrUnavailable)
	}
	return nil, fmt.Errorf("convert %s: status %d", name, response.StatusCode)
}
