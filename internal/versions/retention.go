package versions

import (
	"sort"
	"time"

	"polder-server/internal/files"
)

const (
	thinningDivisor = 24
	minimumGap      = time.Hour
)

type Limits struct {
	KeepAll    time.Duration
	MaxAge     time.Duration
	MaxPerFile int
}

func ToRemove(history []files.Version, limits Limits, now time.Time) []int64 {
	newestFirst := append([]files.Version(nil), history...)
	sort.Slice(newestFirst, func(i, j int) bool {
		if !newestFirst[i].ReplacedAt.Equal(newestFirst[j].ReplacedAt) {
			return newestFirst[i].ReplacedAt.After(newestFirst[j].ReplacedAt)
		}
		return newestFirst[i].ID > newestFirst[j].ID
	})
	var removed []int64
	var kept []files.Version
	for _, version := range newestFirst {
		age := now.Sub(version.ReplacedAt)
		switch {
		case limits.MaxAge > 0 && age > limits.MaxAge:
			removed = append(removed, version.ID)
		case age <= limits.KeepAll || len(kept) == 0:
			kept = append(kept, version)
		case kept[len(kept)-1].ReplacedAt.Sub(version.ReplacedAt) < thinningGap(age):
			removed = append(removed, version.ID)
		default:
			kept = append(kept, version)
		}
	}
	if limits.MaxPerFile > 0 && len(kept) > limits.MaxPerFile {
		for _, version := range kept[limits.MaxPerFile:] {
			removed = append(removed, version.ID)
		}
	}
	return removed
}

func thinningGap(age time.Duration) time.Duration {
	return max(age/thinningDivisor, minimumGap)
}
