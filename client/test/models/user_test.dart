import "package:flutter_test/flutter_test.dart";

import "package:polder/models/account.dart";
import "package:polder/models/user.dart";

void main() {
  User alice([UserProfile profile = const UserProfile()]) => User(id: 1, username: "alice", profile: profile);

  test("names fall back from display name to first name to username", () {
    expect(alice().firstName, "alice");
    expect(alice().displayName, "alice");
    expect(alice(const UserProfile(firstName: "Alice")).displayName, "Alice");
    expect(alice(const UserProfile(firstName: "Alice", displayName: "Al")).displayName, "Al");
  });

  test("initials come from the display name, then the full name, then the username", () {
    expect(alice(const UserProfile(displayName: "Captain Al", firstName: "Alice", lastName: "Example")).initials, "CA");
    expect(alice(const UserProfile(firstName: "Alice", lastName: "Example")).initials, "AE");
    expect(alice(const UserProfile(lastName: "Example")).initials, "E");
    expect(alice().initials, "A");
    expect(const User(id: 2, username: "bob.van-dijk").initials, "BD");
  });

  test("initials keep whole characters in any script", () {
    expect(alice(const UserProfile(firstName: "Ølga", lastName: "Ñandú")).initials, "ØÑ");
    expect(alice(const UserProfile(displayName: "山田 太郎")).initials, "山太");
    expect(alice(const UserProfile(displayName: "👩‍🚀 crew")).initials, "👩‍🚀C");
  });

  test("the handle names the server without its scheme", () {
    Account on(String serverUrl) => Account(serverUrl: serverUrl, accessToken: "", refreshToken: "", user: alice());

    expect(on("https://cloud.test").handle, "alice@cloud.test");
    expect(on("http://localhost:8080").handle, "alice@localhost:8080");
  });
}
