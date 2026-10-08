package versions

import (
	"slices"
	"testing"
	"time"

	"polder-server/internal/files"
)

func savedEvery(interval, span time.Duration, now time.Time) []files.Version {
	var history []files.Version
	for age := interval; age <= span; age += interval {
		history = append(history, files.Version{ID: int64(len(history) + 1), ReplacedAt: now.Add(-age)})
	}
	return history
}

func keptVersions(history []files.Version, removed []int64) []files.Version {
	var kept []files.Version
	for _, version := range history {
		if !slices.Contains(removed, version.ID) {
			kept = append(kept, version)
		}
	}
	return kept
}

func TestHistoryThinsOutWithAge(t *testing.T) {
	now := time.Date(2026, 10, 8, 12, 0, 0, 0, time.UTC)
	history := savedEvery(5*time.Minute, 60*24*time.Hour, now)
	limits := Limits{KeepAll: 6 * time.Hour, MaxAge: 30 * 24 * time.Hour}
	kept := keptVersions(history, ToRemove(history, limits, now))

	recent := 0
	for i, version := range kept {
		age := now.Sub(version.ReplacedAt)
		if age > limits.MaxAge {
			t.Fatalf("kept a version %v old, past the age limit", age)
		}
		if age <= limits.KeepAll {
			recent++
			continue
		}
		if gap := kept[i-1].ReplacedAt.Sub(version.ReplacedAt); gap < thinningGap(age) {
			t.Fatalf("versions %v old are %v apart, closer than %v", age, gap, thinningGap(age))
		}
	}
	if recent != 72 {
		t.Fatalf("want every save from the last 6 hours kept, have %d", recent)
	}
	if len(kept) > 200 {
		t.Fatalf("two months of saves every 5 minutes should thin to a few dozen, kept %d", len(kept))
	}
	oldest := now.Sub(kept[len(kept)-1].ReplacedAt)
	if oldest < 25*24*time.Hour {
		t.Fatalf("the oldest kept version is only %v old", oldest)
	}
}

func TestHistoryKeepsTheNewestWithinTheCount(t *testing.T) {
	now := time.Now()
	history := savedEvery(time.Minute, 10*time.Minute, now)
	kept := keptVersions(history, ToRemove(history, Limits{KeepAll: time.Hour, MaxPerFile: 3}, now))
	if len(kept) != 3 || kept[0].ID != 1 || kept[2].ID != 3 {
		t.Fatalf("want the 3 newest versions, kept %+v", kept)
	}
}
