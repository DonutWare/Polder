package app_test

import (
	"fmt"
	"net/http"
	"testing"
)

type notificationPage struct {
	Notifications []struct {
		ID    int64  `json:"id"`
		Kind  string `json:"kind"`
		Read  bool   `json:"read"`
		Share *struct {
			ShareID   int64  `json:"shareId"`
			Owner     string `json:"owner"`
			OwnerName string `json:"ownerName"`
			Name      string `json:"name"`
			IsDir     bool   `json:"isDir"`
			Note      string `json:"note"`
			Group     string `json:"group"`
		} `json:"share"`
	} `json:"notifications"`
	Cursor  int64 `json:"cursor"`
	HasMore bool  `json:"hasMore"`
}

func (c *client) notifications(after int64) notificationPage {
	c.server.t.Helper()
	var page notificationPage
	c.mustJSON(http.MethodGet, fmt.Sprintf("/notifications?after=%d", after), nil, http.StatusOK, &page)
	return page
}

func TestNewSharesWaitForTheRecipient(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		alice.put("/Project/plan.txt", 0, []byte("draft"), http.StatusOK, nil)
		share := alice.share(alice.stat("/Project").ID, "user", bob.me(), "read")

		incoming := bob.incoming()
		if len(incoming) != 1 || incoming[0].State != "pending" || incoming[0].MountPath != "" {
			t.Fatalf("a new share starts pending: %+v", incoming)
		}
		if _, found := entryNamed(bob.list("/"), "Project"); found {
			t.Fatal("a pending share stays out of the files root")
		}
		if listed := bob.shareList(share.ID, "/", http.StatusOK); len(listed.Entries) != 1 {
			t.Fatalf("a pending share can be looked at: %+v", listed)
		}

		bob.accept(share.ID)
		if incoming := bob.incoming(); incoming[0].State != "accepted" || incoming[0].MountPath == "" {
			t.Fatalf("an accepted share sits in the files: %+v", incoming)
		}
		if _, found := entryNamed(bob.list("/"), "Project"); !found {
			t.Fatal("an accepted share appears in the files root")
		}

		bob.decline(share.ID)
		if incoming := bob.incoming(); len(incoming) != 0 {
			t.Fatalf("a declined share is hidden: %+v", incoming)
		}
		if _, found := entryNamed(bob.list("/"), "Project"); found {
			t.Fatal("a declined share leaves the files root")
		}
	})
}

func TestSharingNotifiesRecipients(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		carol := server.createUser(admin, "carol", 0)
		start := bob.notifications(-1).Cursor
		alice.put("/notes.md", 0, []byte("# Notes"), http.StatusOK, nil)
		alice.put("/Team/plan.txt", 0, []byte("plan"), http.StatusOK, nil)
		direct := alice.shareWith(map[string]any{"fileId": alice.stat("/notes.md").ID, "note": "have a look"}, "user", bob.me(), viewOnly, http.StatusCreated)
		team := server.createGroup(alice, "Team", bob, carol)
		alice.share(alice.stat("/Team").ID, "group", team, "read")

		page := bob.notifications(start)
		if len(page.Notifications) != 2 || page.HasMore {
			t.Fatalf("bob hears about both shares: %+v", page)
		}
		first, second := page.Notifications[0], page.Notifications[1]
		if first.Kind != "share.received" || first.Share == nil || first.Share.ShareID != direct.ID || first.Share.Owner != "alice" ||
			first.Share.Name != "notes.md" || first.Share.IsDir || first.Share.Note != "have a look" || first.Read {
			t.Fatalf("a direct share notification: %+v", first)
		}
		if second.Share == nil || second.Share.Group != "Team" || second.Share.Name != "Team" || !second.Share.IsDir {
			t.Fatalf("a group share notification: %+v", second)
		}
		if page.Cursor != second.ID || len(bob.notifications(page.Cursor).Notifications) != 0 {
			t.Fatalf("the cursor moves past what was read: %+v", page)
		}
		if carolPage := carol.notifications(0); len(carolPage.Notifications) != 1 {
			t.Fatalf("every group member hears about a group share: %+v", carolPage)
		}
		if alicePage := alice.notifications(0); len(alicePage.Notifications) != 0 {
			t.Fatalf("the owner hears nothing about her own share: %+v", alicePage)
		}

		bob.mustJSON(http.MethodPost, "/notifications/read", map[string]int64{"upTo": first.ID}, http.StatusNoContent, nil)
		if read := bob.notifications(start); !read.Notifications[0].Read || read.Notifications[1].Read {
			t.Fatalf("marking read stops at the given notification: %+v", read)
		}
		if latest := bob.notifications(-1); latest.Cursor != second.ID || len(latest.Notifications) != 0 {
			t.Fatalf("-1 only reports the latest cursor: %+v", latest)
		}
	})
}
