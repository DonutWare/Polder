package httpapi

import (
	"context"

	"polder-server/internal/extract"
	"polder-server/internal/search"
)

const searchDescription = "Free text matches names fuzzily: substrings, abbreviations such as `invq3` for invoice_q3.pdf, " +
	"and small typos. It also matches the text inside files when the server reads it, including text recognised in " +
	"images and scans; every word must appear, and quotes match a phrase. Name matches come first. Tags narrow the results; they have the form `key<op>values`:\n\n" +
	"- `type` (also `kind`, `is`): `folder`, `file`, a top-level MIME type (`image`, `video`, `text`…), an extension, " +
	"a MIME subtype or a whole MIME type, such as `type=image,pdf,md` or `type=application/zip`\n" +
	"- `ext`: extensions only\n" +
	"- `in`: a folder and everything below it, such as `in=\"/My Docs\"`\n" +
	"- `modified` (also `date`): `2024`, `2024-06`, `2024-06-15`, `today`, `yesterday`, or a relative `7d`, `2w`, `3m`, `1y`\n" +
	"- `size`: such as `10mb`, `500kb`, `1.5gb`\n\n" +
	"Operators are `=` or `:` (is), `!=` or a leading `-` (is not), and `>`, `>=`, `<`, `<=` for modified and size. " +
	"Commas separate alternatives, separate tags must all hold, and `modified=a..b` or `size=a..b` is a range. " +
	"A relative date is a moment: `modified>7d` is newer than a week ago."

type searchInput struct {
	Query  string `query:"q" doc:"What to look for; see the operation description for tags"`
	Limit  int    `query:"limit" default:"50" minimum:"1" maximum:"200"`
	Offset int    `query:"offset" default:"0" minimum:"0"`
}

type suggestInput struct {
	Query  string `query:"q"`
	Cursor int    `query:"cursor" minimum:"0" doc:"Caret position in the query, in UTF-16 code units"`
}

func (a *API) searchFiles(ctx context.Context, input *searchInput) (*jsonBody[search.Results], error) {
	response, err := a.search.Search(ctx, currentUser(ctx), input.Query, input.Limit, input.Offset)
	if err != nil {
		return nil, err
	}
	return respond(response), nil
}

func (a *API) suggestSearch(ctx context.Context, input *suggestInput) (*jsonBody[search.Suggestions], error) {
	suggestions, err := a.search.Suggest(ctx, currentUser(ctx), input.Query, input.Cursor)
	if err != nil {
		return nil, err
	}
	return respond(suggestions), nil
}

type searchStatus struct {
	search.IndexStatus
	Extraction extract.ExtractionStatus `json:"extraction"`
}

func (a *API) searchStatus(ctx context.Context, _ *struct{}) (*jsonBody[searchStatus], error) {
	index, err := a.search.Status()
	if err != nil {
		return nil, err
	}
	extraction, err := a.extract.Status(ctx)
	if err != nil {
		return nil, err
	}
	return respond(searchStatus{IndexStatus: index, Extraction: extraction}), nil
}

func (a *API) rebuildSearchIndex(ctx context.Context, _ *struct{}) (*struct{}, error) {
	go func() {
		if err := a.search.Rebuild(context.WithoutCancel(ctx)); err != nil {
			logger.Error("rebuild search index", "error", err)
		}
	}()
	return nil, nil
}
