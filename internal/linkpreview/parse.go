package linkpreview

import (
	"io"
	"net/url"
	"strings"

	"golang.org/x/net/html"
	"golang.org/x/net/html/atom"
)

const (
	maxTitleLength       = 300
	maxDescriptionLength = 500
	maxSiteNameLength    = 300
)

type headFields struct {
	values    map[string]string
	title     string
	icon      string
	touchIcon string
}

func (f *headFields) first(keys ...string) string {
	for _, key := range keys {
		if value := f.values[key]; value != "" {
			return value
		}
	}
	return ""
}

func readHead(body io.Reader) headFields {
	fields := headFields{values: map[string]string{}}
	tokens := html.NewTokenizer(body)
	inTitle := false
	for {
		switch tokens.Next() {
		case html.ErrorToken:
			return fields
		case html.TextToken:
			if inTitle && fields.title == "" {
				fields.title = string(tokens.Text())
			}
		case html.EndTagToken:
			name, _ := tokens.TagName()
			switch atom.Lookup(name) {
			case atom.Title:
				inTitle = false
			case atom.Head:
				return fields
			}
		case html.StartTagToken, html.SelfClosingTagToken:
			name, hasAttributes := tokens.TagName()
			tag := atom.Lookup(name)
			if tag == atom.Body {
				return fields
			}
			if tag == atom.Title {
				inTitle = true
				continue
			}
			if !hasAttributes || (tag != atom.Meta && tag != atom.Link) {
				continue
			}
			attributes := readAttributes(tokens)
			if tag == atom.Meta {
				fields.addMeta(attributes)
			} else {
				fields.addLink(attributes)
			}
		}
	}
}

func readAttributes(tokens *html.Tokenizer) map[string]string {
	attributes := map[string]string{}
	for {
		key, value, more := tokens.TagAttr()
		attributes[strings.ToLower(string(key))] = string(value)
		if !more {
			return attributes
		}
	}
}

func (f *headFields) addMeta(attributes map[string]string) {
	content := strings.TrimSpace(attributes["content"])
	if content == "" {
		return
	}
	for _, key := range []string{attributes["property"], attributes["name"]} {
		key = strings.ToLower(strings.TrimSpace(key))
		if key != "" && f.values[key] == "" {
			f.values[key] = content
		}
	}
}

func (f *headFields) addLink(attributes map[string]string) {
	href := strings.TrimSpace(attributes["href"])
	if href == "" {
		return
	}
	for _, rel := range strings.Fields(strings.ToLower(attributes["rel"])) {
		switch rel {
		case "apple-touch-icon", "apple-touch-icon-precomposed":
			if f.touchIcon == "" {
				f.touchIcon = href
			}
		case "icon":
			if f.icon == "" {
				f.icon = href
			}
		}
	}
}

func pageFrom(fields headFields, page *url.URL) Page {
	return Page{
		URL:         page.String(),
		Title:       clean(fields.first("og:title", "twitter:title"), fields.title, maxTitleLength),
		Description: clean(fields.first("og:description", "twitter:description", "description"), "", maxDescriptionLength),
		SiteName:    clean(fields.first("og:site_name", "application-name"), siteName(page), maxSiteNameLength),
		Image:       resolve(page, fields.first("og:image:secure_url", "og:image", "og:image:url", "twitter:image", "twitter:image:src")),
		Icon:        resolveIcon(page, fields),
	}
}

func resolveIcon(page *url.URL, fields headFields) string {
	for _, candidate := range []string{fields.touchIcon, fields.icon, "/favicon.ico"} {
		if resolved := resolve(page, candidate); resolved != "" {
			return resolved
		}
	}
	return ""
}

func resolve(page *url.URL, reference string) string {
	if reference == "" {
		return ""
	}
	parsed, err := page.Parse(reference)
	if err != nil || (parsed.Scheme != "http" && parsed.Scheme != "https") {
		return ""
	}
	return parsed.String()
}

func clean(value, fallback string, limit int) string {
	collapsed := strings.Join(strings.Fields(value), " ")
	if collapsed == "" {
		collapsed = strings.Join(strings.Fields(fallback), " ")
	}
	runes := []rune(collapsed)
	if len(runes) <= limit {
		return collapsed
	}
	return string(runes[:limit]) + "…"
}

func siteName(page *url.URL) string {
	return strings.TrimPrefix(strings.ToLower(page.Hostname()), "www.")
}
