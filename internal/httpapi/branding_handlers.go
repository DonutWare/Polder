package httpapi

import (
	"context"
	"io"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/apperr"
	"polder-server/internal/settings"
)

const (
	maxImageBytes = 10 << 20
	maxDrainBytes = 256 << 20
)

type branding struct {
	Name        string               `json:"name" doc:"Name to show for this server; empty means the app's own name"`
	Message     string               `json:"message" doc:"Welcome message for the login screen; empty means none"`
	AccentColor string               `json:"accentColor" doc:"Default accent color as #RRGGBB; empty means the app's own default"`
	Icon        *settings.ImageInfo  `json:"icon,omitempty" required:"false" doc:"Absent when the server has no icon of its own"`
	Backgrounds []settings.ImageInfo `json:"backgrounds" doc:"The login screen's backgrounds, shown in turn"`
}

type imageUpload struct {
	content io.Reader
}

func (i *imageUpload) Resolve(ctx huma.Context) []error {
	i.content = ctx.BodyReader()
	return nil
}

type imagePath struct {
	ImageID string `path:"imageID"`
}

type imageOutput struct {
	ETag                  string `header:"ETag"`
	CacheControl          string `header:"Cache-Control"`
	ContentType           string `header:"Content-Type"`
	ContentSecurityPolicy string `header:"Content-Security-Policy"`
	Body                  []byte
}

func (a *API) branding(ctx context.Context, _ *struct{}) (*jsonBody[branding], error) {
	current, err := a.settings.Get(ctx)
	if err != nil {
		return nil, err
	}
	return respond(branding{
		Name:        current.InstanceName,
		Message:     current.WelcomeMessage,
		AccentColor: current.AccentColor,
		Icon:        a.images.Icon(),
		Backgrounds: a.images.Backgrounds(),
	}), nil
}

func (a *API) brandingIcon(_ context.Context, input *imagePath) (*imageOutput, error) {
	return imageResponse(a.images.ReadIcon(input.ImageID))
}

func (a *API) brandingBackground(_ context.Context, input *imagePath) (*imageOutput, error) {
	return imageResponse(a.images.ReadBackground(input.ImageID))
}

func imageResponse(image settings.Image, err error) (*imageOutput, error) {
	if err != nil {
		return nil, err
	}
	return &imageOutput{
		ETag:         `"` + image.ID + `"`,
		CacheControl: "public, max-age=31536000, immutable",
		ContentType:  image.ContentType,
		// An SVG opened directly must not run scripts with this origin's access.
		ContentSecurityPolicy: "default-src 'none'; style-src 'unsafe-inline'; sandbox",
		Body:                  image.Content,
	}, nil
}

func (a *API) setBrandingIcon(ctx context.Context, input *imageUpload) (*jsonBody[branding], error) {
	content, err := readImage(input.content, maxImageBytes)
	if err != nil {
		return nil, err
	}
	if _, err := a.images.SetIcon(content); err != nil {
		return nil, err
	}
	settingsLog.Info("server icon changed", "bytes", len(content), "by", currentUser(ctx).Username)
	return a.branding(ctx, nil)
}

func (a *API) removeBrandingIcon(ctx context.Context, _ *struct{}) (*struct{}, error) {
	if err := a.images.RemoveIcon(); err != nil {
		return nil, err
	}
	settingsLog.Info("server icon removed", "by", currentUser(ctx).Username)
	return nil, nil
}

func (a *API) addBrandingBackground(ctx context.Context, input *imageUpload) (*jsonBody[branding], error) {
	content, err := readImage(input.content, maxImageBytes)
	if err != nil {
		return nil, err
	}
	info, err := a.images.AddBackground(content)
	if err != nil {
		return nil, err
	}
	settingsLog.Info("login background added", "id", info.ID, "bytes", len(content), "by", currentUser(ctx).Username)
	return a.branding(ctx, nil)
}

func (a *API) removeBrandingBackground(ctx context.Context, input *imagePath) (*struct{}, error) {
	if err := a.images.RemoveBackground(input.ImageID); err != nil {
		return nil, err
	}
	settingsLog.Info("login background removed", "id", input.ImageID, "by", currentUser(ctx).Username)
	return nil, nil
}

func readImage(body io.Reader, limit int64) ([]byte, error) {
	content, err := io.ReadAll(io.LimitReader(body, limit+1))
	if err != nil {
		return nil, err
	}
	if int64(len(content)) > limit {
		_, _ = io.Copy(io.Discard, io.LimitReader(body, maxDrainBytes))
		return nil, apperr.Invalid("the image must be at most %d MiB", limit>>20)
	}
	return content, nil
}
