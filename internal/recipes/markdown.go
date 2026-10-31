package recipes

import (
	"fmt"
	"net/url"
	"strconv"
	"strings"
)

var markdownEscaper = strings.NewReplacer(
	`\`, `\\`, "`", "\\`", "*", `\*`, "_", `\_`, "[", `\[`, "]", `\]`, "<", `\<`, "#", `\#`,
)

var destinationEscaper = strings.NewReplacer(" ", "%20", "(", "%28", ")", "%29", "<", "%3C", ">", "%3E")

func Render(recipe Recipe, source string, images map[string]string) string {
	var sections []string
	if image := images[recipe.Image]; image != "" {
		sections = append(sections, imageLine(recipe.Name, image))
	}
	if header := headerLines(recipe, source); header != "" {
		sections = append(sections, header)
	}
	if recipe.Description != "" {
		sections = append(sections, escape(recipe.Description))
	}
	sections = append(sections, ingredientsSection(recipe.Ingredients), stepsSection(recipe.Steps, images))
	return strings.Join(sections, "\n\n") + "\n"
}

func headerLines(recipe Recipe, source string) string {
	var facts []string
	switch {
	case recipe.Servings > 0:
		facts = append(facts, "**Servings:** "+strconv.Itoa(recipe.Servings))
	case recipe.Yield != "":
		facts = append(facts, "**Yield:** "+escape(recipe.Yield))
	}
	for _, fact := range []struct{ label, value string }{
		{"Prep", recipe.PrepTime}, {"Cook", recipe.CookTime}, {"Total", recipe.TotalTime},
	} {
		if fact.value != "" {
			facts = append(facts, fmt.Sprintf("**%s:** %s", fact.label, escape(fact.value)))
		}
	}
	var lines []string
	if len(facts) > 0 {
		lines = append(lines, strings.Join(facts, " · "))
	}
	if link := sourceLink(source); link != "" {
		lines = append(lines, "Source: "+link)
	}
	return strings.Join(lines, "  \n")
}

func sourceLink(source string) string {
	parsed, err := url.Parse(source)
	if err != nil || parsed.Host == "" {
		return ""
	}
	site := strings.TrimPrefix(strings.ToLower(parsed.Hostname()), "www.")
	return fmt.Sprintf("[%s](%s)", escape(site), destinationEscaper.Replace(parsed.String()))
}

func ingredientsSection(groups []IngredientGroup) string {
	lines := []string{"## Ingredients"}
	for _, group := range groups {
		if group.Name != "" {
			lines = append(lines, "", "### "+escape(group.Name))
		}
		for _, item := range group.Items {
			lines = append(lines, "- [ ] "+escape(item))
		}
	}
	return strings.Join(lines, "\n")
}

func stepsSection(groups []StepGroup, images map[string]string) string {
	lines := []string{"## Steps"}
	for _, group := range groups {
		if group.Name != "" {
			lines = append(lines, "", "### "+escape(group.Name))
		}
		for index, step := range group.Steps {
			marker := strconv.Itoa(index+1) + ". "
			lines = append(lines, marker+escape(step.Text))
			if image := images[step.Image]; image != "" {
				lines = append(lines, strings.Repeat(" ", len(marker))+imageLine("", image))
			}
		}
	}
	return strings.Join(lines, "\n")
}

func imageLine(label, destination string) string {
	return fmt.Sprintf("![%s](%s)", escape(label), destination)
}

func escape(text string) string {
	return markdownEscaper.Replace(text)
}
