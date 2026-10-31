package recipes

import (
	"fmt"
	"math"
	"regexp"
	"strconv"
	"strings"
)

var isoDuration = regexp.MustCompile(`^P(?:(\d+(?:[.,]\d+)?)D)?(?:T(?:(\d+(?:[.,]\d+)?)H)?(?:(\d+(?:[.,]\d+)?)M)?(?:(\d+(?:[.,]\d+)?)S)?)?$`)

func formatDuration(value string) string {
	match := isoDuration.FindStringSubmatch(strings.ToUpper(strings.TrimSpace(value)))
	if match == nil {
		return cleanText(value)
	}
	minutes := amount(match[1])*24*60 + amount(match[2])*60 + amount(match[3]) + amount(match[4])/60
	return formatMinutes(int(math.Round(minutes)))
}

func amount(value string) float64 {
	if value == "" {
		return 0
	}
	number, err := strconv.ParseFloat(strings.Replace(value, ",", ".", 1), 64)
	if err != nil {
		return 0
	}
	return number
}

func formatMinutes(minutes int) string {
	hours, rest := minutes/60, minutes%60
	switch {
	case minutes <= 0:
		return ""
	case hours == 0:
		return fmt.Sprintf("%d min", rest)
	case rest == 0:
		return fmt.Sprintf("%d h", hours)
	default:
		return fmt.Sprintf("%d h %d min", hours, rest)
	}
}
