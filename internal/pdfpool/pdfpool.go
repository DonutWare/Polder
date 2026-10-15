package pdfpool

import (
	"github.com/klippa-app/go-pdfium"
	"github.com/klippa-app/go-pdfium/webassembly"
	"github.com/tetratelabs/wazero"
	"github.com/tetratelabs/wazero/api"
	"github.com/tetratelabs/wazero/experimental"
)

var compiled = wazero.NewCompilationCache()

func New() (pdfium.Pool, error) {
	runtime := wazero.NewRuntimeConfig().
		WithCoreFeatures(api.CoreFeaturesV2 | experimental.CoreFeaturesExceptionHandling).
		WithCompilationCache(compiled)
	return webassembly.Init(webassembly.Config{MinIdle: 0, MaxIdle: 1, MaxTotal: 1, RuntimeConfig: runtime})
}
