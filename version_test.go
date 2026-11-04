package polder

import (
	"regexp"
	"testing"
)

func TestPubspecVersionIsReadFromTheClient(t *testing.T) {
	name, build := PubspecVersion()
	if !regexp.MustCompile(`^\d+\.\d+\.\d+$`).MatchString(name) {
		t.Fatalf("version name %q is not x.y.z", name)
	}
	if !regexp.MustCompile(`^\d+$`).MatchString(build) {
		t.Fatalf("build number %q is not numeric", build)
	}
}
