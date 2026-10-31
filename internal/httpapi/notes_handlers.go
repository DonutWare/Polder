package httpapi

import (
	"context"
	"path"
	"strings"

	"polder-server/internal/apperr"
	"polder-server/internal/files"
)

type notesSettings struct {
	Path *string `json:"path" required:"false" doc:"Folder the notes view shows as its tree; absent until the user picks one"`
}

func (a *API) getNotesSettings(ctx context.Context, _ *struct{}) (*jsonBody[notesSettings], error) {
	notesPath, err := a.users.Store().NotesPath(ctx, currentUser(ctx).ID)
	if err != nil {
		return nil, err
	}
	return respond(notesSettings{Path: notesPath}), nil
}

func (a *API) setNotesSettings(ctx context.Context, input *jsonBody[notesSettings]) (*jsonBody[notesSettings], error) {
	owner := currentUser(ctx)
	chosen := input.Body
	if chosen.Path != nil {
		folder, err := a.files.Stat(ctx, owner, *chosen.Path)
		if err != nil {
			return nil, err
		}
		if !folder.IsDir {
			return nil, apperr.Invalid("%s is not a folder", folder.Path)
		}
		chosen.Path = &folder.Path
	}
	if err := a.users.Store().SetNotesPath(ctx, owner.ID, chosen.Path); err != nil {
		return nil, err
	}
	return respond(chosen), nil
}

type notesItem struct {
	Entry     files.Entry `json:"entry"`
	HasNotes  bool        `json:"hasNotes,omitempty" required:"false" doc:"For a folder: whether notes other than its README are somewhere inside it"`
	HasReadme bool        `json:"hasReadme,omitempty" required:"false" doc:"For a folder: whether a README directly inside makes the folder a page"`
}

type notesListing struct {
	Path  string      `json:"path"`
	Items []notesItem `json:"items" doc:"The folders and notes in the folder; other files are left out"`
}

func (a *API) listNotes(ctx context.Context, input *pathQuery) (*jsonBody[notesListing], error) {
	owner := currentUser(ctx)
	listedPath, entries, err := a.files.List(ctx, owner, input.Path)
	if err != nil {
		return nil, err
	}
	notesInside, err := a.files.DescendantPaths(ctx, owner, listedPath, files.MarkdownMime)
	if err != nil {
		return nil, err
	}
	if err := a.attachTags(ctx, entries); err != nil {
		return nil, err
	}
	notesPerFolder := notesInFolders(listedPath, notesInside)
	items := []notesItem{}
	for _, entry := range entries {
		if entry.IsDir || entry.Mime == files.MarkdownMime {
			item := notesItem{Entry: entry}
			if entry.IsDir {
				item.HasNotes = notesPerFolder[entry.Name].hasNotes
				item.HasReadme = notesPerFolder[entry.Name].hasReadme
			}
			items = append(items, item)
		}
	}
	return respond(notesListing{Path: listedPath, Items: items}), nil
}

type folderNotes struct {
	hasNotes  bool
	hasReadme bool
}

func notesInFolders(folder string, notePaths []string) map[string]folderNotes {
	prefix := strings.TrimSuffix(folder, "/") + "/"
	found := map[string]folderNotes{}
	for _, notePath := range notePaths {
		child, below, nested := strings.Cut(strings.TrimPrefix(notePath, prefix), "/")
		if !nested {
			continue
		}
		notes := found[child]
		if isReadme(below) {
			notes.hasReadme = true
		} else {
			notes.hasNotes = true
		}
		found[child] = notes
	}
	return found
}

func isReadme(noteName string) bool {
	return strings.EqualFold(strings.TrimSuffix(noteName, path.Ext(noteName)), "README")
}
