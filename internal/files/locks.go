package files

import "sync"

type userLocks struct {
	locks sync.Map
}

func (l *userLocks) lock(userID int64) func() {
	value, _ := l.locks.LoadOrStore(userID, &sync.Mutex{})
	mutex := value.(*sync.Mutex)
	mutex.Lock()
	return mutex.Unlock
}
