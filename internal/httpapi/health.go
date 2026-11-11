package httpapi

import (
	"context"
	"sync"
	"time"

	"polder-server/internal/apperr"
	"polder-server/internal/files"
)

const (
	storageOK       = "ok"
	storageFull     = "full"
	storageReadOnly = "readonly"

	storageProbeInterval = 15 * time.Second
)

type healthStatus struct {
	Status  string `json:"status" example:"ok"`
	Storage string `json:"storage,omitempty" required:"false" enum:"ok,full,readonly" doc:"Whether the server can currently store data"`
}

type storageProbe struct {
	mu       sync.Mutex
	probe    func() error
	now      func() time.Time
	result   string
	probedAt time.Time
}

func diskProbe(service *files.Service) func() error {
	if service == nil {
		return func() error { return nil }
	}
	return service.Disk().ProbeWritable
}

func newStorageProbe(probe func() error) *storageProbe {
	return &storageProbe{probe: probe, now: time.Now}
}

func (p *storageProbe) status() string {
	p.mu.Lock()
	defer p.mu.Unlock()
	if p.result != "" && p.now().Sub(p.probedAt) < storageProbeInterval {
		return p.result
	}
	p.result = storageStatusOf(p.probe())
	p.probedAt = p.now()
	return p.result
}

func storageStatusOf(err error) string {
	switch {
	case err == nil:
		return storageOK
	case apperr.IsNoSpace(err):
		logger.Error("storage is full", "error", err)
		return storageFull
	default:
		logger.Error("storage is not writable", "error", err)
		return storageReadOnly
	}
}

func (a *API) health(context.Context, *struct{}) (*jsonBody[healthStatus], error) {
	return respond(healthStatus{Status: "ok", Storage: a.storage.status()}), nil
}
