package httpapi

import (
	"errors"
	"fmt"
	"net/http"
	"testing"
)

func TestInternalErrorsSayWhatWentWrong(t *testing.T) {
	cause := fmt.Errorf("move to trash: %w", errors.New("permission denied"))
	response := newError(nil, http.StatusInternalServerError, "unexpected error occurred", cause).(*errorResponse)
	if response.status != http.StatusInternalServerError || response.Detail.Code != "internal" {
		t.Fatalf("unexpected response %+v", response)
	}
	if response.Detail.Message != "move to trash: permission denied" {
		t.Fatalf("message %q hides the cause", response.Detail.Message)
	}
}
