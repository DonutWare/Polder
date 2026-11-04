package version

import polder "polder-server"

var (
	Current     = ""
	BuildNumber = ""
)

func init() {
	name, build := polder.PubspecVersion()
	Current = orDefault(Current, name, "0.0.0")
	BuildNumber = orDefault(BuildNumber, build, "0")
}

func orDefault(injected, embedded, fallback string) string {
	if injected != "" {
		return injected
	}
	if embedded != "" {
		return embedded
	}
	return fallback
}
