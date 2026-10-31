package tags

import (
	"slices"
	"testing"
)

func TestReadTagsFindsProseTagsOnly(t *testing.T) {
	cases := map[string][]string{
		"#work and #home":                   {"work", "home"},
		"# Heading\n\n## Sub #inside":       {"inside"},
		"see `#code` and #real":             {"real"},
		"```\n#fenced\n```\n#after":         {"after"},
		"issue #123 and #v2":                {"v2"},
		"mail a#b and &#39; and ##double":   nil,
		"[#label](#anchor) #linked":         {"linked"},
		"#Work #work #WORK":                 {"Work"},
		"#café #project/polder. #trailing-": {"café", "project/polder", "trailing"},
		"---\ntitle: x\n---\n#afterfront":   {"afterfront"},
		"under_scored #my_tag":              {"my_tag"},
	}
	for source, want := range cases {
		if got := ReadTags([]byte(source)); !slices.Equal(got, want) {
			t.Errorf("ReadTags(%q) = %v, want %v", source, got, want)
		}
	}
}

func TestAppendTag(t *testing.T) {
	cases := []struct{ source, name, want string }{
		{"", "work", "#work\n"},
		{"Hello", "work", "Hello\n\n#work\n"},
		{"Hello\n\n#home\n", "work", "Hello\n\n#home #work\n"},
		{"Hello #Work", "work", "Hello #Work"},
	}
	for _, c := range cases {
		if got := string(AppendTag([]byte(c.source), c.name)); got != c.want {
			t.Errorf("AppendTag(%q, %q) = %q, want %q", c.source, c.name, got, c.want)
		}
	}
}

func TestRenameAndRemoveTag(t *testing.T) {
	source := "Plan #work today, `#work` stays.\n\n#home #Work\n"
	if got := string(RenameTag([]byte(source), "work", "job")); got != "Plan #job today, `#work` stays.\n\n#home #job\n" {
		t.Errorf("RenameTag = %q", got)
	}
	if got := string(RemoveTag([]byte(source), "work")); got != "Plan today, `#work` stays.\n\n#home\n" {
		t.Errorf("RemoveTag = %q", got)
	}
	if got := string(RemoveTag([]byte("#work first"), "work")); got != "first" {
		t.Errorf("RemoveTag at start = %q", got)
	}
}

func TestValidName(t *testing.T) {
	for name, want := range map[string]bool{
		"work": true, "project/polder": true, "a-b_c": true, "café": true,
		"123": false, "": false, "with space": false, "a#b": false,
	} {
		if got := ValidName(name); got != want {
			t.Errorf("ValidName(%q) = %v, want %v", name, got, want)
		}
	}
}
