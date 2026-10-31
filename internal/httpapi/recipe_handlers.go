package httpapi

import (
	"context"

	"polder-server/internal/apperr"
	"polder-server/internal/files"
	"polder-server/internal/recipes"
)

type recipeImportRequest struct {
	URL     string `json:"url,omitempty" required:"false" doc:"The http or https page that holds the recipe; with content, it only names the source and resolves image links"`
	Content string `json:"content,omitempty" required:"false" doc:"The recipe pasted by the user, as the page's HTML source or as plain text with an ingredients and a steps heading; read instead of fetching the link"`
	Folder  string `json:"folder" doc:"The folder the recipe note is created in; its images go in an attachments folder beside it"`
}

func (a *API) importRecipe(ctx context.Context, input *jsonBody[recipeImportRequest]) (*jsonBody[files.Entry], error) {
	owner := currentUser(ctx)
	mounted, err := a.mountAt(ctx, owner, input.Body.Folder)
	if err != nil {
		return nil, err
	}
	if mounted != nil {
		return nil, apperr.Invalid("recipes can only be imported into your own files")
	}
	entry, err := a.recipes.Import(ctx, owner, recipes.Request{
		Source:  input.Body.URL,
		Content: input.Body.Content,
		Folder:  input.Body.Folder,
	})
	if err != nil {
		return nil, err
	}
	return respond(entry), nil
}
