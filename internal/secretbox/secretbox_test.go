package secretbox

import "testing"

func TestSealedSecretOpensOnlyInItsContext(t *testing.T) {
	box, err := New(make([]byte, 32))
	if err != nil {
		t.Fatal(err)
	}
	sealed := box.Seal("secret", "share:1")
	if opened, err := box.Open(sealed, "share:1"); err != nil || opened != "secret" {
		t.Fatalf("open = %q, %v", opened, err)
	}
	if _, err := box.Open(sealed, "share:2"); err == nil {
		t.Fatal("opened a secret in another context")
	}
}
