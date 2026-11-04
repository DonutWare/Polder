package polder

import (
	_ "embed"
	"strings"
)

//go:embed client/pubspec.yaml
var pubspec string

func PubspecVersion() (name, build string) {
	for _, line := range strings.Split(pubspec, "\n") {
		value, found := strings.CutPrefix(strings.TrimSpace(line), "version:")
		if !found {
			continue
		}
		name, build, _ = strings.Cut(strings.TrimSpace(value), "+")
		return name, build
	}
	return "", ""
}
