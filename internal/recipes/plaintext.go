package recipes

import (
	"regexp"
	"strconv"
	"strings"
)

const (
	maxHeadingLength = 60
	maxTitleScan     = 40
	maxIngredients   = 80
	maxSteps         = 40
)

var (
	ingredientsHeading = regexp.MustCompile(`(?i)^(ingredients?|ingrediënten|ingredienten|benodigdheden)\b`)
	stepsHeading       = regexp.MustCompile(`(?i)^(instructions|method|directions|preparation|steps|bereiding|bereidingswijze|werkwijze|zo maak je het)\b`)
	endHeading         = regexp.MustCompile(`(?i)^(notes?|tips?|nutrition|voedingswaarde|opmerkingen|serving suggestions?|did you make|heb je dit recept|reviews?|comments?|reacties)\b`)
	listMarker         = regexp.MustCompile(`^(?:(?:[-*•·▢☐□✓✔▪◦]|\[[ xX]\])\s*|\d{1,2}[.)]\s+)+`)
	stepLabel          = regexp.MustCompile(`(?i)^(?:step|stap)\s*\d{1,2}\s*[:.)-]?\s*`)
	numberOnly         = regexp.MustCompile(`^\d{1,2}[.)]?$`)
	servingsText       = regexp.MustCompile(`(?i)(?:servings|serves|yield|porties|personen)\D{0,4}(\d{1,3})\b|\b(\d{1,3})\s*(?:servings|people|porties|personen)\b`)
)

func fromText(text string) (Recipe, bool) {
	lines := nonEmptyLines(text)
	for ingredientsAt := headingIndex(lines, ingredientsHeading, 0); ingredientsAt >= 0; ingredientsAt = headingIndex(lines, ingredientsHeading, ingredientsAt+1) {
		stepsAt := headingIndex(lines, stepsHeading, ingredientsAt+1)
		if stepsAt < 0 {
			break
		}
		ingredients := ingredientGroupsIn(lines[ingredientsAt+1 : stepsAt])
		steps := withoutDuplicateSteps([]StepGroup{{Steps: stepsIn(lines[stepsAt+1:])}})
		if countIngredients(ingredients) == 0 || countIngredients(ingredients) > maxIngredients || len(steps) == 0 {
			continue
		}
		return Recipe{
			Name:        titleIn(lines[:ingredientsAt]),
			Servings:    servingsIn(lines[:stepsAt]),
			Ingredients: ingredients,
			Steps:       steps,
		}, true
	}
	return Recipe{}, false
}

func nonEmptyLines(text string) []string {
	var lines []string
	for _, line := range strings.Split(strings.ReplaceAll(text, "\r", "\n"), "\n") {
		if cleaned := cleanText(line); cleaned != "" {
			lines = append(lines, cleaned)
		}
	}
	return lines
}

func headingIndex(lines []string, heading *regexp.Regexp, from int) int {
	for index := from; index < len(lines); index++ {
		if isHeading(lines[index], heading) {
			return index
		}
	}
	return -1
}

func isHeading(line string, heading *regexp.Regexp) bool {
	return len([]rune(line)) <= maxHeadingLength && heading.MatchString(strings.TrimLeft(line, "#* ")) && !strings.HasSuffix(line, ".")
}

func titleIn(lines []string) string {
	for _, line := range lines[:min(len(lines), maxTitleScan)] {
		line = strings.TrimLeft(line, "# ")
		if line != "" && len([]rune(line)) <= maxTitleLength && !servingsText.MatchString(line) {
			return line
		}
	}
	return ""
}

func servingsIn(lines []string) int {
	for _, line := range lines {
		if match := servingsText.FindStringSubmatch(line); match != nil {
			servings, _ := strconv.Atoi(fallback(match[1], match[2]))
			return servings
		}
	}
	return 0
}

func ingredientGroupsIn(lines []string) []IngredientGroup {
	groups := []IngredientGroup{{}}
	for _, line := range lines {
		if strings.HasSuffix(line, ":") && len([]rune(line)) <= maxHeadingLength {
			groups = append(groups, IngredientGroup{Name: strings.TrimSuffix(line, ":")})
			continue
		}
		if item := strings.TrimSpace(listMarker.ReplaceAllString(line, "")); item != "" {
			groups[len(groups)-1].Items = append(groups[len(groups)-1].Items, item)
		}
	}
	var kept []IngredientGroup
	for _, group := range groups {
		if len(group.Items) > 0 {
			kept = append(kept, group)
		}
	}
	return kept
}

func stepsIn(lines []string) []Step {
	var steps []Step
	for _, line := range lines {
		if isHeading(line, endHeading) {
			break
		}
		if numberOnly.MatchString(line) {
			continue
		}
		text := strings.TrimSpace(listMarker.ReplaceAllString(stepLabel.ReplaceAllString(line, ""), ""))
		if text != "" {
			steps = append(steps, Step{Text: text})
		}
		if len(steps) == maxSteps {
			break
		}
	}
	return steps
}
