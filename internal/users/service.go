package users

import (
	"context"
	"fmt"

	"polder-server/internal/apperr"
)

type PasswordHasher interface {
	Hash(password string) (string, error)
}

type UserDirectories interface {
	EnsureUserRoot(username string) error
	ArchiveUserRoot(username string) error
}

type Service struct {
	store       *Store
	hasher      PasswordHasher
	directories UserDirectories
	onCreated   []func(User)
}

func NewService(store *Store, hasher PasswordHasher, directories UserDirectories) *Service {
	return &Service{store: store, hasher: hasher, directories: directories}
}

func (s *Service) Store() *Store { return s.store }

func (s *Service) OnCreated(listener func(User)) {
	s.onCreated = append(s.onCreated, listener)
}

func (s *Service) Create(ctx context.Context, newUser NewUser) (User, error) {
	if err := newUser.validate(); err != nil {
		return User{}, err
	}
	passwordHash, err := s.hasher.Hash(newUser.Password)
	if err != nil {
		return User{}, err
	}
	user, err := s.store.Insert(ctx, newUser, passwordHash)
	if err != nil {
		return User{}, err
	}
	if err := s.directories.EnsureUserRoot(user.Username); err != nil {
		return User{}, fmt.Errorf("create user directory: %w", err)
	}
	for _, listener := range s.onCreated {
		listener(user)
	}
	return user, nil
}

func (s *Service) Update(ctx context.Context, actor User, targetID int64, changes Changes) (User, error) {
	if err := changes.validate(); err != nil {
		return User{}, err
	}
	if actor.ID == targetID && changes.locksOutActor() {
		return User{}, apperr.Forbidden("you cannot demote or disable your own account")
	}
	if _, err := s.store.ByID(ctx, targetID); err != nil {
		return User{}, err
	}
	var passwordHash string
	if changes.Password != nil {
		hash, err := s.hasher.Hash(*changes.Password)
		if err != nil {
			return User{}, err
		}
		passwordHash = hash
	}
	if err := s.store.Update(ctx, targetID, changes, passwordHash); err != nil {
		return User{}, err
	}
	return s.store.ByID(ctx, targetID)
}

func (c Changes) locksOutActor() bool {
	demoted := c.Role != nil && *c.Role != RoleAdmin
	disabled := c.Disabled != nil && *c.Disabled
	return demoted || disabled
}

func (s *Service) Delete(ctx context.Context, actor User, targetID int64) error {
	if actor.ID == targetID {
		return apperr.Forbidden("you cannot delete your own account")
	}
	target, err := s.store.ByID(ctx, targetID)
	if err != nil {
		return err
	}
	if err := s.store.Delete(ctx, targetID); err != nil {
		return err
	}
	return s.directories.ArchiveUserRoot(target.Username)
}
