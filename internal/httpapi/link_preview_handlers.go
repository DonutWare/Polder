package httpapi

import (
	"context"

	"polder-server/internal/linkpreview"
)

type linkPreviewQuery struct {
	URL string `query:"url" required:"true" doc:"The http or https link to describe"`
}

type linkPreview struct {
	URL         string `json:"url" doc:"The link that was asked about, without its fragment"`
	Title       string `json:"title,omitempty" required:"false" doc:"The page's title"`
	Description string `json:"description,omitempty" required:"false" doc:"A short summary the page gives of itself"`
	SiteName    string `json:"siteName" doc:"The site's name, or its host when it names none"`
	HasImage    bool   `json:"hasImage" doc:"Whether the page names a preview image, served by getLinkPreviewImage"`
	HasIcon     bool   `json:"hasIcon" doc:"Whether there is a site icon to try, served by getLinkPreviewImage"`
}

type linkPreviewImageQuery struct {
	URL  string `query:"url" required:"true" doc:"The link whose preview image or icon to get"`
	Kind string `query:"kind" enum:"image,icon" default:"image" doc:"The page's preview image, or the site's icon"`
}

type linkPreviewImageOutput struct {
	CacheControl          string `header:"Cache-Control"`
	ContentType           string `header:"Content-Type"`
	ContentTypeOptions    string `header:"X-Content-Type-Options"`
	ContentSecurityPolicy string `header:"Content-Security-Policy"`
	Body                  []byte
}

func (a *API) linkPreview(ctx context.Context, input *linkPreviewQuery) (*jsonBody[linkPreview], error) {
	page, err := a.linkPreviews.Page(ctx, currentUser(ctx).ID, input.URL)
	if err != nil {
		return nil, err
	}
	return respond(linkPreview{
		URL:         page.URL,
		Title:       page.Title,
		Description: page.Description,
		SiteName:    page.SiteName,
		HasImage:    page.Image != "",
		HasIcon:     page.Icon != "",
	}), nil
}

func (a *API) linkPreviewImage(ctx context.Context, input *linkPreviewImageQuery) (*linkPreviewImageOutput, error) {
	asset, err := a.linkPreviews.Image(ctx, currentUser(ctx).ID, input.URL, linkpreview.Kind(input.Kind))
	if err != nil {
		return nil, err
	}
	return &linkPreviewImageOutput{
		CacheControl:          "private, max-age=86400",
		ContentType:           asset.ContentType,
		ContentTypeOptions:    "nosniff",
		ContentSecurityPolicy: "default-src 'none'; sandbox",
		Body:                  asset.Body,
	}, nil
}
