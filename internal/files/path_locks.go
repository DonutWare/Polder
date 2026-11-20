package files

import (
	"sync"

	"polder-server/internal/storage"
)

type pathLocks struct {
	mu    sync.Mutex
	users map[int64]*pathQueue
}

type pathQueue struct {
	requests []*pathRequest
}

type pathRequest struct {
	paths   []string
	granted bool
	ready   chan struct{}
}

func (l *pathLocks) lockAll(userID int64) func() {
	return l.lock(userID, storage.RootPath)
}

func (l *pathLocks) lock(userID int64, paths ...string) func() {
	request := &pathRequest{paths: paths, ready: make(chan struct{})}
	l.mu.Lock()
	if l.users == nil {
		l.users = map[int64]*pathQueue{}
	}
	queue := l.users[userID]
	if queue == nil {
		queue = &pathQueue{}
		l.users[userID] = queue
	}
	queue.requests = append(queue.requests, request)
	queue.grantWaiting()
	l.mu.Unlock()
	<-request.ready
	return sync.OnceFunc(func() { l.release(userID, request) })
}

func (l *pathLocks) lockFree(userID int64, paths ...string) ([]string, func()) {
	l.mu.Lock()
	defer l.mu.Unlock()
	var requests []*pathRequest
	if queue := l.users[userID]; queue != nil {
		requests = queue.requests
	}
	var free []string
	for _, path := range paths {
		if !overlapsAny(path, requests) {
			free = append(free, path)
		}
	}
	if len(free) == 0 {
		return nil, func() {}
	}
	request := &pathRequest{paths: free, granted: true, ready: make(chan struct{})}
	close(request.ready)
	if l.users == nil {
		l.users = map[int64]*pathQueue{}
	}
	if l.users[userID] == nil {
		l.users[userID] = &pathQueue{}
	}
	l.users[userID].requests = append(l.users[userID].requests, request)
	return free, sync.OnceFunc(func() { l.release(userID, request) })
}

func overlapsAny(path string, requests []*pathRequest) bool {
	for _, request := range requests {
		if pathsOverlap([]string{path}, request.paths) {
			return true
		}
	}
	return false
}

func (l *pathLocks) release(userID int64, request *pathRequest) {
	l.mu.Lock()
	defer l.mu.Unlock()
	queue := l.users[userID]
	for i, queued := range queue.requests {
		if queued == request {
			queue.requests = append(queue.requests[:i], queue.requests[i+1:]...)
			break
		}
	}
	if len(queue.requests) == 0 {
		delete(l.users, userID)
		return
	}
	queue.grantWaiting()
}

func (q *pathQueue) grantWaiting() {
	for i, request := range q.requests {
		if request.granted || q.blockedByEarlier(i) {
			continue
		}
		request.granted = true
		close(request.ready)
	}
}

func (q *pathQueue) blockedByEarlier(index int) bool {
	for _, earlier := range q.requests[:index] {
		if pathsOverlap(earlier.paths, q.requests[index].paths) {
			return true
		}
	}
	return false
}

func pathsOverlap(first, second []string) bool {
	for _, a := range first {
		for _, b := range second {
			if storage.IsSameOrDescendant(a, b) || storage.IsSameOrDescendant(b, a) {
				return true
			}
		}
	}
	return false
}
