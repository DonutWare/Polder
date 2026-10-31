package recipes

import (
	"net/url"
	"reflect"
	"testing"

	"polder-server/internal/apperr"
)

var testPage, _ = url.Parse("https://cooking.example.com/recipes/bolognese")

func extract(t *testing.T, body string) Recipe {
	t.Helper()
	recipe, err := Extract([]byte(body), testPage)
	if err != nil {
		t.Fatal(err)
	}
	return recipe
}

func stepTexts(group StepGroup) []string {
	var texts []string
	for _, step := range group.Steps {
		texts = append(texts, step.Text)
	}
	return texts
}

func TestLinkedDataInAGraphIsRead(t *testing.T) {
	recipe := extract(t, `<html><head><title>Blog</title>
<script type="application/ld+json">{"@context":"https://schema.org","@graph":[
 {"@type":"WebPage","name":"Page"},
 {"@type":["Recipe","NewsArticle"],"name":"Spaghetti &amp; Bolognese",
  "description":"<p>Grandma&#39;s favourite</p>",
  "image":[{"@type":"ImageObject","url":"/img/hero.jpg"}],
  "recipeYield":["4","4 servings"],
  "prepTime":"PT15M","cookTime":"PT1H30M","totalTime":"P0DT1H45M",
  "recipeIngredient":["2 onions","500 g  minced beef"],
  "recipeInstructions":[
   {"@type":"HowToStep","text":"Slice 2 onions and cook them for 5 minutes.","image":"https://cdn.example.com/step1.jpg"},
   {"@type":"HowToStep","name":"Brown","text":"Add the beef."},
   {"@type":"HowToStep","text":"Add the beef."}
  ]}
]}</script></head><body><p>Long story about my holiday</p></body></html>`)

	if recipe.Name != "Spaghetti & Bolognese" || recipe.Description != "Grandma's favourite" {
		t.Fatalf("name or description %q %q", recipe.Name, recipe.Description)
	}
	if recipe.Image != "https://cooking.example.com/img/hero.jpg" {
		t.Fatalf("image %q", recipe.Image)
	}
	if recipe.Servings != 4 || recipe.PrepTime != "15 min" || recipe.CookTime != "1 h 30 min" || recipe.TotalTime != "1 h 45 min" {
		t.Fatalf("facts %+v", recipe)
	}
	if !reflect.DeepEqual(recipe.Ingredients, []IngredientGroup{{Items: []string{"2 onions", "500 g minced beef"}}}) {
		t.Fatalf("ingredients %+v", recipe.Ingredients)
	}
	if len(recipe.Steps) != 1 || !reflect.DeepEqual(stepTexts(recipe.Steps[0]), []string{"Slice 2 onions and cook them for 5 minutes.", "Add the beef."}) {
		t.Fatalf("steps %+v", recipe.Steps)
	}
	if recipe.Steps[0].Steps[0].Image != "https://cdn.example.com/step1.jpg" {
		t.Fatalf("step image %+v", recipe.Steps[0].Steps[0])
	}
}

func TestSectionsBecomeStepGroups(t *testing.T) {
	recipe := extract(t, `<script type="application/ld+json">[{"@type":"Recipe","name":"Lasagne",
  "recipeIngredient":"1 sheet of pasta",
  "recipeInstructions":[
   {"@type":"HowToSection","name":"Sauce","itemListElement":[{"@type":"HowToStep","text":"Simmer for 20 minutes."}]},
   {"@type":"HowToSection","name":"Assembly","itemListElement":[{"@type":"HowToStep","text":"Layer."},{"@type":"HowToStep","text":"Bake."}]}
  ]}]</script>`)

	if len(recipe.Steps) != 2 || recipe.Steps[0].Name != "Sauce" || recipe.Steps[1].Name != "Assembly" {
		t.Fatalf("groups %+v", recipe.Steps)
	}
	if !reflect.DeepEqual(stepTexts(recipe.Steps[1]), []string{"Layer.", "Bake."}) {
		t.Fatalf("assembly %+v", recipe.Steps[1])
	}
}

func TestInstructionsAsOneHtmlStringAreSplit(t *testing.T) {
	recipe := extract(t, `<script type="application/ld+json">{"@type":"Recipe","name":"Soup",
  "image":"https://cooking.example.com/soup.png",
  "recipeYield":"Serves 6 people",
  "recipeInstructions":"<ol><li>Chop the leeks.</li><li>Boil for 10 min.</li></ol>"}</script>`)

	if !reflect.DeepEqual(stepTexts(recipe.Steps[0]), []string{"Chop the leeks.", "Boil for 10 min."}) {
		t.Fatalf("steps %+v", recipe.Steps)
	}
	if recipe.Servings != 6 || recipe.Yield != "Serves 6 people" {
		t.Fatalf("yield %d %q", recipe.Servings, recipe.Yield)
	}
}

func TestMicrodataIsTheFallback(t *testing.T) {
	recipe := extract(t, `<html><head><title>Pancakes | Site</title></head><body>
<div itemscope itemtype="http://schema.org/Recipe">
 <h1 itemprop="name">Pancakes</h1>
 <img itemprop="image" src="/p.jpg">
 <meta itemprop="recipeYield" content="2">
 <time itemprop="cookTime" datetime="PT10M">10 minutes</time>
 <ul><li itemprop="recipeIngredient">200 g flour</li><li itemprop="recipeIngredient">2 <b>eggs</b></li></ul>
 <div itemprop="recipeInstructions"><p>Whisk everything.</p><p>Fry in butter.</p></div>
</div></body></html>`)

	if recipe.Name != "Pancakes" || recipe.Image != "https://cooking.example.com/p.jpg" || recipe.Servings != 2 || recipe.CookTime != "10 min" {
		t.Fatalf("recipe %+v", recipe)
	}
	if !reflect.DeepEqual(recipe.Ingredients[0].Items, []string{"200 g flour", "2 eggs"}) {
		t.Fatalf("ingredients %+v", recipe.Ingredients)
	}
	if !reflect.DeepEqual(stepTexts(recipe.Steps[0]), []string{"Whisk everything.", "Fry in butter."}) {
		t.Fatalf("steps %+v", recipe.Steps)
	}
}

func TestPagesWithoutARecipeAreRefused(t *testing.T) {
	_, err := Extract([]byte(`<html><head><script type="application/ld+json">{"@type":"Article"}</script></head><body>Hello</body></html>`), testPage)
	if !apperr.Is(err, apperr.KindInvalid) {
		t.Fatalf("expected invalid, got %v", err)
	}
}

func TestDurationsAreReadable(t *testing.T) {
	for input, expected := range map[string]string{
		"PT45M": "45 min", "PT2H": "2 h", "PT90M": "1 h 30 min", "P1D": "24 h", "PT0S": "", "about an hour": "about an hour",
	} {
		if got := formatDuration(input); got != expected {
			t.Errorf("formatDuration(%q) = %q, want %q", input, got, expected)
		}
	}
}

func TestPastedPlainTextIsRead(t *testing.T) {
	recipe, err := Parse(`Kimchi stew
Hoofdgerecht · 4 personen · 35 min

Ingrediënten
• 1.5 kg varkensbuik
• 300 g kimchi
Voor de garnering:
• 2 bosuitjes

Bereiding
1
Snijd het vlees in blokjes.
Stap 2: Bak de kimchi 5 minuten.
3. Voeg water toe en laat 20 min sudderen.

Tips
Lekker met rijst.`, nil)
	if err != nil {
		t.Fatal(err)
	}
	if recipe.Name != "Kimchi stew" || recipe.Servings != 4 {
		t.Fatalf("recipe %+v", recipe)
	}
	if !reflect.DeepEqual(recipe.Ingredients, []IngredientGroup{
		{Items: []string{"1.5 kg varkensbuik", "300 g kimchi"}},
		{Name: "Voor de garnering", Items: []string{"2 bosuitjes"}},
	}) {
		t.Fatalf("ingredients %+v", recipe.Ingredients)
	}
	if !reflect.DeepEqual(stepTexts(recipe.Steps[0]), []string{"Snijd het vlees in blokjes.", "Bak de kimchi 5 minuten.", "Voeg water toe en laat 20 min sudderen."}) {
		t.Fatalf("steps %+v", recipe.Steps)
	}
}

func TestPageTextSkipsATableOfContents(t *testing.T) {
	recipe := extract(t, `<html><head><title>Soup | Blog</title></head><body>
<nav><a>Ingredients</a><a>Instructions</a></nav>
<p>My grandmother made this every winter.</p>
<h2>Ingredients</h2><ul><li>2 leeks</li><li>1 l stock</li></ul>
<h2>Instructions</h2><ol><li>Slice the leeks.</li><li>Simmer for 15 minutes.</li></ol>
<h2>Comments</h2><p>Great soup!</p></body></html>`)

	if recipe.Name != "Soup | Blog" || !reflect.DeepEqual(recipe.Ingredients[0].Items, []string{"2 leeks", "1 l stock"}) {
		t.Fatalf("recipe %+v", recipe)
	}
	if !reflect.DeepEqual(stepTexts(recipe.Steps[0]), []string{"Slice the leeks.", "Simmer for 15 minutes."}) {
		t.Fatalf("steps %+v", recipe.Steps)
	}
}

func TestPastedTextWithoutHeadingsIsRefused(t *testing.T) {
	if _, err := Parse("Just some text about dinner.", nil); !apperr.Is(err, apperr.KindInvalid) {
		t.Fatalf("expected invalid, got %v", err)
	}
}
