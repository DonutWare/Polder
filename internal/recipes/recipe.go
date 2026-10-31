package recipes

type Recipe struct {
	Name        string
	Description string
	Image       string
	Servings    int
	Yield       string
	PrepTime    string
	CookTime    string
	TotalTime   string
	Ingredients []IngredientGroup
	Steps       []StepGroup
}

type IngredientGroup struct {
	Name  string
	Items []string
}

type StepGroup struct {
	Name  string
	Steps []Step
}

type Step struct {
	Text  string
	Image string
}

func (r Recipe) isEmpty() bool {
	return countIngredients(r.Ingredients) == 0 && countSteps(r.Steps) == 0
}

func countIngredients(groups []IngredientGroup) int {
	total := 0
	for _, group := range groups {
		total += len(group.Items)
	}
	return total
}

func countSteps(groups []StepGroup) int {
	total := 0
	for _, group := range groups {
		total += len(group.Steps)
	}
	return total
}
