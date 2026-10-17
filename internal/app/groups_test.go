package app_test

import (
	"fmt"
	"net/http"
	"testing"
)

type groupSummary struct {
	ID          int64   `json:"id"`
	Name        string  `json:"name"`
	MemberCount int     `json:"memberCount"`
	MyRole      *string `json:"myRole"`
}

type groupDetails struct {
	Group     groupSummary `json:"group"`
	CanManage bool         `json:"canManage"`
	Members   []struct {
		User struct {
			ID       int64  `json:"id"`
			Username string `json:"username"`
		} `json:"user"`
		Role string `json:"role"`
	} `json:"members"`
}

type directory struct {
	Users []struct {
		ID       int64  `json:"id"`
		Username string `json:"username"`
	} `json:"users"`
	Groups []struct {
		ID   int64  `json:"id"`
		Name string `json:"name"`
	} `json:"groups"`
}

func (c *client) me() int64 {
	c.server.t.Helper()
	var me struct {
		ID int64 `json:"id"`
	}
	c.mustJSON(http.MethodGet, "/auth/me", nil, http.StatusOK, &me)
	return me.ID
}

func (s *testServer) createGroup(creator *client, name string, members ...*client) int64 {
	s.t.Helper()
	var created struct {
		ID int64 `json:"id"`
	}
	creator.mustJSON(http.MethodPost, "/groups", map[string]string{"name": name}, http.StatusCreated, &created)
	for _, member := range members {
		creator.addMember(created.ID, member, "member", http.StatusCreated)
	}
	return created.ID
}

func (c *client) addMember(groupID int64, member *client, role string, expectedStatus int) {
	c.server.t.Helper()
	c.mustJSON(http.MethodPost, fmt.Sprintf("/groups/%d/members", groupID), map[string]any{"userId": member.me(), "role": role}, expectedStatus, nil)
}

func (c *client) setRole(groupID int64, member *client, role string, expectedStatus int) {
	c.server.t.Helper()
	c.mustJSON(http.MethodPatch, fmt.Sprintf("/groups/%d/members/%d", groupID, member.me()), map[string]any{"role": role}, expectedStatus, nil)
}

func (c *client) removeMember(groupID int64, member *client, expectedStatus int) {
	c.server.t.Helper()
	c.expect(c.request(http.MethodDelete, fmt.Sprintf("/groups/%d/members/%d", groupID, member.me()), nil, nil), expectedStatus, nil)
}

func (c *client) groups(scope string, expectedStatus int) []groupSummary {
	c.server.t.Helper()
	var list []groupSummary
	var target any = &list
	if expectedStatus != http.StatusOK {
		target = nil
	}
	c.mustJSON(http.MethodGet, "/groups?scope="+scope, nil, expectedStatus, target)
	return list
}

func TestAnyoneCanCreateGroupsAndOnlyMembersSeeThem(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		carol := server.createUser(admin, "carol", 0)

		groupID := server.createGroup(alice, "Family", bob)
		var details groupDetails
		alice.mustJSON(http.MethodGet, fmt.Sprintf("/groups/%d", groupID), nil, http.StatusOK, &details)
		if !details.CanManage || len(details.Members) != 2 || details.Members[0].Role != "admin" || details.Members[0].User.Username != "alice" {
			t.Fatalf("creator should be the group's admin: %+v", details)
		}

		if mine := bob.groups("mine", http.StatusOK); len(mine) != 1 || mine[0].MyRole == nil || *mine[0].MyRole != "member" {
			t.Fatalf("bob's groups: %+v", mine)
		}
		if len(carol.groups("mine", http.StatusOK)) != 0 {
			t.Fatal("carol sees a group she is not in")
		}
		carol.mustJSON(http.MethodGet, fmt.Sprintf("/groups/%d", groupID), nil, http.StatusNotFound, nil)
		carol.groups("all", http.StatusForbidden)
		if all := admin.groups("all", http.StatusOK); len(all) != 1 {
			t.Fatalf("administrators see every group: %+v", all)
		}
		namesake := server.createGroup(carol, "Family")
		if namesake == groupID || len(carol.groups("mine", http.StatusOK)) != 1 {
			t.Fatal("groups with the same name should be separate groups")
		}
	})
}

func TestTheLastMemberLeavingDeletesTheGroup(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		solo := server.createGroup(alice, "Just me")
		alice.removeMember(solo, alice, http.StatusNoContent)
		if all := admin.groups("all", http.StatusOK); len(all) != 0 {
			t.Fatalf("an empty group was left behind: %+v", all)
		}

		pair := server.createGroup(alice, "Pair", bob)
		alice.removeMember(pair, alice, http.StatusBadRequest)
		bob.removeMember(pair, bob, http.StatusNoContent)
		alice.removeMember(pair, alice, http.StatusNoContent)
		if all := admin.groups("all", http.StatusOK); len(all) != 0 {
			t.Fatalf("the group should be gone once its last member left: %+v", all)
		}
	})
}

func TestLeavingAGroupHidesItAndRemovesYourShares(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		carol := server.createUser(admin, "carol", 0)
		groupID := server.createGroup(alice, "Family", bob, carol)
		alice.setRole(groupID, bob, "admin", http.StatusOK)
		alice.put("/Photos/a.txt", 0, []byte("a"), http.StatusOK, nil)
		bob.put("/Recipes/b.txt", 0, []byte("b"), http.StatusOK, nil)
		alice.shareWith(map[string]any{"fileId": alice.stat("/Photos").ID}, "group", groupID, viewOnly, http.StatusCreated)
		bob.shareWith(map[string]any{"fileId": bob.stat("/Recipes").ID}, "group", groupID, viewOnly, http.StatusCreated)

		alice.removeMember(groupID, alice, http.StatusNoContent)
		if len(alice.groups("mine", http.StatusOK)) != 0 {
			t.Fatal("the creator still sees the group after leaving")
		}
		alice.mustJSON(http.MethodGet, fmt.Sprintf("/groups/%d", groupID), nil, http.StatusNotFound, nil)
		incoming := carol.incoming()
		if len(incoming) != 1 || incoming[0].Entry.Name != "Recipes" {
			t.Fatalf("only bob's share should stay in the group: %+v", incoming)
		}

		bob.removeMember(groupID, carol, http.StatusNoContent)
		if len(carol.incoming()) != 0 {
			t.Fatal("a removed member still sees the group's shares")
		}
	})
}

func TestOnlyGroupAdminsManageMembers(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		carol := server.createUser(admin, "carol", 0)
		groupID := server.createGroup(alice, "Team", bob)

		bob.addMember(groupID, carol, "member", http.StatusForbidden)
		bob.setRole(groupID, bob, "admin", http.StatusForbidden)
		bob.mustJSON(http.MethodPatch, fmt.Sprintf("/groups/%d", groupID), map[string]string{"name": "Mine"}, http.StatusForbidden, nil)

		alice.addMember(groupID, carol, "viewer", http.StatusCreated)
		alice.setRole(groupID, bob, "admin", http.StatusOK)
		bob.removeMember(groupID, carol, http.StatusNoContent)

		alice.removeMember(groupID, alice, http.StatusNoContent)
		admin.addMember(groupID, carol, "member", http.StatusCreated)
		bob.removeMember(groupID, bob, http.StatusBadRequest)
		bob.setRole(groupID, bob, "member", http.StatusBadRequest)
		carol.removeMember(groupID, carol, http.StatusNoContent)
		admin.mustJSON(http.MethodPatch, fmt.Sprintf("/groups/%d", groupID), map[string]string{"name": "Renamed"}, http.StatusOK, nil)
		admin.expect(admin.request(http.MethodDelete, fmt.Sprintf("/groups/%d", groupID), nil, nil), http.StatusNoContent, nil)
		bob.mustJSON(http.MethodGet, fmt.Sprintf("/groups/%d", groupID), nil, http.StatusNotFound, nil)
	})
}

func TestDeletingAUserRemovesTheirMemberships(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		groupID := server.createGroup(alice, "Family", bob)
		admin.mustJSON(http.MethodDelete, fmt.Sprintf("/admin/users/%d", bob.me()), nil, http.StatusNoContent, nil)
		var details groupDetails
		alice.mustJSON(http.MethodGet, fmt.Sprintf("/groups/%d", groupID), nil, http.StatusOK, &details)
		if details.Group.MemberCount != 1 {
			t.Fatalf("deleted user still a member: %+v", details)
		}
	})
}

func TestDirectoryListsUsersAndGroupsYouMayShareWith(t *testing.T) {
	forEachDatabase(t, func(t *testing.T, server *testServer) {
		admin := server.setupAdmin()
		alice := server.createUser(admin, "alice", 0)
		bob := server.createUser(admin, "bob", 0)
		carol := server.createUser(admin, "carol", 0)
		admin.mustJSON(http.MethodPatch, fmt.Sprintf("/admin/users/%d", carol.me()), map[string]any{"disabled": true}, http.StatusOK, nil)
		bowling := server.createGroup(bob, "Bowling")
		bob.addMember(bowling, alice, "viewer", http.StatusCreated)
		server.createGroup(alice, "Book club")

		var found directory
		alice.mustJSON(http.MethodGet, "/directory?q=", nil, http.StatusOK, &found)
		names := map[string]bool{}
		for _, user := range found.Users {
			names[user.Username] = true
		}
		if names["alice"] || names["carol"] || !names["bob"] || !names["admin"] {
			t.Fatalf("unexpected users %+v", found.Users)
		}
		if len(found.Groups) != 1 || found.Groups[0].Name != "Book club" {
			t.Fatalf("only groups alice may share with should show: %+v", found.Groups)
		}
	})
}
