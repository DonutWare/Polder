package recipes

import (
	"encoding/json"
	"net/url"
	"strconv"
	"strings"

	"golang.org/x/net/html"
	"golang.org/x/net/html/atom"
)

const maxSearchDepth = 12

func fromLinkedData(document *html.Node, page *url.URL) (Recipe, bool) {
	scripts := findAll(document, func(node *html.Node) bool {
		return node.DataAtom == atom.Script && strings.Contains(strings.ToLower(attribute(node, "type")), "ld+json")
	})
	for _, script := range scripts {
		var data any
		if err := json.Unmarshal([]byte(scriptText(script)), &data); err != nil {
			continue
		}
		if node := findRecipeNode(data, 0); node != nil {
			return recipeFrom(node, page), true
		}
	}
	return Recipe{}, false
}

func scriptText(script *html.Node) string {
	var text strings.Builder
	for child := script.FirstChild; child != nil; child = child.NextSibling {
		text.WriteString(child.Data)
	}
	return text.String()
}

func findRecipeNode(value any, depth int) map[string]any {
	if depth > maxSearchDepth {
		return nil
	}
	switch typed := value.(type) {
	case map[string]any:
		if hasType(typed, "Recipe") {
			return typed
		}
		for _, child := range typed {
			if found := findRecipeNode(child, depth+1); found != nil {
				return found
			}
		}
	case []any:
		for _, child := range typed {
			if found := findRecipeNode(child, depth+1); found != nil {
				return found
			}
		}
	}
	return nil
}

func hasType(node map[string]any, name string) bool {
	for _, value := range asList(node["@type"]) {
		if text, ok := value.(string); ok && strings.EqualFold(strings.TrimPrefix(text, "schema:"), name) {
			return true
		}
	}
	return false
}

func asList(value any) []any {
	switch typed := value.(type) {
	case nil:
		return nil
	case []any:
		return typed
	default:
		return []any{typed}
	}
}

func recipeFrom(node map[string]any, page *url.URL) Recipe {
	servings, yield := yieldFrom(node["recipeYield"])
	recipe := Recipe{
		Name:        cleanText(textOf(node["name"])),
		Description: limit(cleanText(htmlToText(textOf(node["description"]))), maxDescriptionLength),
		Image:       imageOf(node["image"], page),
		Servings:    servings,
		Yield:       yield,
		PrepTime:    formatDuration(textOf(node["prepTime"])),
		CookTime:    formatDuration(textOf(node["cookTime"])),
		TotalTime:   formatDuration(textOf(node["totalTime"])),
		Steps:       stepGroupsFrom(node["recipeInstructions"], page),
	}
	if items := ingredientsFrom(fallbackValue(node["recipeIngredient"], node["ingredients"])); len(items) > 0 {
		recipe.Ingredients = []IngredientGroup{{Items: items}}
	}
	return recipe
}

func fallbackValue(value, otherwise any) any {
	if value != nil {
		return value
	}
	return otherwise
}

func textOf(value any) string {
	switch typed := value.(type) {
	case string:
		return typed
	case float64:
		return strconv.FormatFloat(typed, 'f', -1, 64)
	case []any:
		for _, item := range typed {
			if text := textOf(item); text != "" {
				return text
			}
		}
	case map[string]any:
		for _, key := range []string{"text", "name", "@value"} {
			if text := textOf(typed[key]); text != "" {
				return text
			}
		}
	}
	return ""
}

func imageOf(value any, page *url.URL) string {
	switch typed := value.(type) {
	case string:
		return resolve(page, typed)
	case []any:
		for _, item := range typed {
			if image := imageOf(item, page); image != "" {
				return image
			}
		}
	case map[string]any:
		for _, key := range []string{"url", "contentUrl", "@id"} {
			if text, ok := typed[key].(string); ok {
				if image := resolve(page, text); image != "" {
					return image
				}
			}
		}
	}
	return ""
}

func yieldFrom(value any) (int, string) {
	var firstText string
	for _, item := range asList(value) {
		text := cleanText(textOf(item))
		if text == "" {
			continue
		}
		if servings, err := strconv.Atoi(text); err == nil && servings > 0 {
			return servings, text
		}
		if firstText == "" {
			firstText = text
		}
	}
	return leadingNumber(firstText), firstText
}

func leadingNumber(text string) int {
	digits := strings.FieldsFunc(text, func(r rune) bool { return r < '0' || r > '9' })
	if len(digits) == 0 {
		return 0
	}
	number, err := strconv.Atoi(digits[0])
	if err != nil {
		return 0
	}
	return number
}

func ingredientsFrom(value any) []string {
	var items []string
	for _, item := range asList(value) {
		for _, line := range cleanLines(textOf(item)) {
			items = append(items, line)
		}
	}
	return items
}

func stepGroupsFrom(value any, page *url.URL) []StepGroup {
	main := StepGroup{}
	var groups []StepGroup
	for _, item := range asList(value) {
		if section, ok := item.(map[string]any); ok && hasType(section, "HowToSection") {
			group := StepGroup{Name: cleanText(textOf(section["name"])), Steps: stepsFrom(section["itemListElement"], page, 0)}
			if len(group.Steps) > 0 {
				groups = append(groups, group)
			}
			continue
		}
		main.Steps = append(main.Steps, stepsFrom(item, page, 0)...)
	}
	if len(main.Steps) > 0 {
		groups = append([]StepGroup{main}, groups...)
	}
	return withoutDuplicateSteps(groups)
}

func stepsFrom(value any, page *url.URL, depth int) []Step {
	if depth > maxSearchDepth {
		return nil
	}
	switch typed := value.(type) {
	case string:
		var steps []Step
		for _, line := range cleanLines(typed) {
			steps = append(steps, Step{Text: line})
		}
		return steps
	case []any:
		var steps []Step
		for _, item := range typed {
			steps = append(steps, stepsFrom(item, page, depth+1)...)
		}
		return steps
	case map[string]any:
		if list, ok := typed["itemListElement"]; ok {
			return stepsFrom(list, page, depth+1)
		}
		text := strings.Join(cleanLines(fallback(textOf(typed["text"]), textOf(typed["name"]))), " ")
		if text == "" {
			return nil
		}
		return []Step{{Text: text, Image: imageOf(typed["image"], page)}}
	}
	return nil
}

func withoutDuplicateSteps(groups []StepGroup) []StepGroup {
	seen := map[string]bool{}
	var kept []StepGroup
	for _, group := range groups {
		unique := StepGroup{Name: group.Name}
		for _, step := range group.Steps {
			key := strings.ToLower(step.Text)
			if seen[key] {
				continue
			}
			seen[key] = true
			unique.Steps = append(unique.Steps, step)
		}
		if len(unique.Steps) > 0 {
			kept = append(kept, unique)
		}
	}
	return kept
}
