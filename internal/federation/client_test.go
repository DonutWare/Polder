package federation

import (
	"testing"
)

func TestParseCloudID(t *testing.T) {
	valid := map[string]CloudID{
		"alice@cloud.example.com":                   {User: "alice", Remote: "cloud.example.com"},
		"alice@example.com@cloud.example.com":       {User: "alice@example.com", Remote: "cloud.example.com"},
		"Bob Smith@Cloud.Example.com:8443/nc/":      {User: "Bob Smith", Remote: "cloud.example.com:8443/nc"},
		"carol@https://cloud.example.com/index.php": {User: "carol", Remote: "cloud.example.com"},
	}
	for raw, want := range valid {
		got, err := ParseCloudID(raw)
		if err != nil || got != want {
			t.Errorf("%q: %+v %v, want %+v", raw, got, err, want)
		}
	}
	for _, raw := range []string{"", "alice", "@host", "alice@", "alice@http://cloud.example.com", "a<b@host", "alice@host/../x",
		"alice@host?x=1", "alice@ho st"} {
		if got, err := ParseCloudID(raw); err == nil {
			t.Errorf("%q should be rejected, got %+v", raw, got)
		}
	}
}
