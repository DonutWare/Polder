package mail

import "context"

type OptionsSource func(ctx context.Context) (Options, error)

type Resolver struct {
	options OptionsSource
}

func NewResolver(options OptionsSource) *Resolver {
	return &Resolver{options: options}
}

func (r *Resolver) Configured(ctx context.Context) bool {
	options, err := r.options(ctx)
	return err == nil && NewSender(options).Configured()
}

func (r *Resolver) Send(ctx context.Context, message Message) error {
	options, err := r.options(ctx)
	if err != nil {
		return err
	}
	return NewSender(options).Send(ctx, message)
}
