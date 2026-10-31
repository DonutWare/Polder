package recipes

import (
	"net/url"
	"strings"

	"golang.org/x/net/html"
)

func fromMicrodata(document *html.Node, page *url.URL) (Recipe, bool) {
	scope := findFirst(document, func(node *html.Node) bool {
		return strings.HasSuffix(strings.ToLower(attribute(node, "itemtype")), "schema.org/recipe")
	})
	if scope == nil {
		return Recipe{}, false
	}
	properties := map[string][]*html.Node{}
	for _, node := range findAll(scope, func(node *html.Node) bool { return attribute(node, "itemprop") != "" }) {
		for _, name := range strings.Fields(attribute(node, "itemprop")) {
			properties[name] = append(properties[name], node)
		}
	}
	first := func(names ...string) *html.Node {
		for _, name := range names {
			if nodes := properties[name]; len(nodes) > 0 {
				return nodes[0]
			}
		}
		return nil
	}
	servings, yield := yieldFrom(propertyText(first("recipeYield")))
	recipe := Recipe{
		Name:        cleanText(propertyText(first("name"))),
		Description: limit(cleanText(propertyText(first("description"))), maxDescriptionLength),
		Image:       propertyURL(first("image"), page),
		Servings:    servings,
		Yield:       yield,
		PrepTime:    formatDuration(propertyText(first("prepTime"))),
		CookTime:    formatDuration(propertyText(first("cookTime"))),
		TotalTime:   formatDuration(propertyText(first("totalTime"))),
		Steps:       microdataSteps(properties["recipeInstructions"]),
	}
	var ingredients []string
	for _, node := range append(properties["recipeIngredient"], properties["ingredients"]...) {
		ingredients = append(ingredients, cleanLines(textContent(node))...)
	}
	if len(ingredients) > 0 {
		recipe.Ingredients = []IngredientGroup{{Items: ingredients}}
	}
	return recipe, true
}

func microdataSteps(nodes []*html.Node) []StepGroup {
	var steps []Step
	for _, node := range nodes {
		for _, line := range cleanLines(textContent(node)) {
			steps = append(steps, Step{Text: line})
		}
	}
	return withoutDuplicateSteps([]StepGroup{{Steps: steps}})
}

func propertyText(node *html.Node) string {
	if node == nil {
		return ""
	}
	for _, name := range []string{"content", "datetime"} {
		if value := attribute(node, name); value != "" {
			return value
		}
	}
	return textContent(node)
}

func propertyURL(node *html.Node, page *url.URL) string {
	if node == nil {
		return ""
	}
	for _, name := range []string{"src", "content", "href", "data-src"} {
		if value := resolve(page, attribute(node, name)); value != "" {
			return value
		}
	}
	if image := findFirst(node, func(child *html.Node) bool { return child.Data == "img" }); image != nil && image != node {
		return propertyURL(image, page)
	}
	return ""
}
