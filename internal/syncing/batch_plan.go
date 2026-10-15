package syncing

import (
	"context"

	"polder-server/internal/users"
)

type batchPlan struct {
	missing    []ChunkRef
	sources    map[int]map[string]chunkSource
	stillNeeds map[int]map[string]bool
	neededBy   map[string][]int
}

func (s *Service) planBatch(ctx context.Context, owner users.User, target batch) (batchPlan, error) {
	plan := batchPlan{
		missing:    []ChunkRef{},
		sources:    map[int]map[string]chunkSource{},
		stillNeeds: map[int]map[string]bool{},
		neededBy:   map[string][]int{},
	}
	for _, file := range target.unfinishedFiles() {
		sources, err := s.availableChunkSources(ctx, owner, target.id, file.request)
		if err != nil {
			return batchPlan{}, err
		}
		plan.sources[file.idx] = sources
		plan.stillNeeds[file.idx] = map[string]bool{}
		for _, chunk := range file.request.Chunks {
			if _, available := sources[chunk.Hash]; !available {
				plan.addNeed(file.idx, chunk)
			}
		}
	}
	return plan, nil
}

func (p *batchPlan) addNeed(idx int, chunk ChunkRef) {
	if p.stillNeeds[idx][chunk.Hash] {
		return
	}
	p.stillNeeds[idx][chunk.Hash] = true
	if len(p.neededBy[chunk.Hash]) == 0 {
		p.missing = append(p.missing, chunk)
	}
	p.neededBy[chunk.Hash] = append(p.neededBy[chunk.Hash], idx)
}

func (p *batchPlan) isComplete(idx int) bool {
	needs, waiting := p.stillNeeds[idx]
	return waiting && len(needs) == 0
}

func (p *batchPlan) markArrived(idx int, chunk ChunkRef, stagedPath string) {
	p.sources[idx][chunk.Hash] = chunkSource{stagedPath: stagedPath, size: chunk.Size}
	delete(p.stillNeeds[idx], chunk.Hash)
}

func (p *batchPlan) stopWaiting(idx int) {
	delete(p.stillNeeds, idx)
}

func (p *batchPlan) isWaiting(idx int) bool {
	_, waiting := p.stillNeeds[idx]
	return waiting
}

func (p *batchPlan) missingBytes() int64 {
	var total int64
	for _, chunk := range p.missing {
		total += chunk.Size
	}
	return total
}
