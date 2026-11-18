import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:path/path.dart" as p;

import "package:polder/services/desktop/launch_at_login_io.dart";

void main() {
  late Directory home;

  setUp(() async => home = await Directory.systemTemp.createTemp("launch_at_login"));
  tearDown(() => home.delete(recursive: true));

  File entry(String name) => File(p.join(home.path, ".config", "autostart", name));

  test("writes and removes an autostart entry for the AppImage", () async {
    final launchAtLogin = LinuxLaunchAtLogin({"HOME": home.path, "APPIMAGE": "/opt/Polder.AppImage"});

    expect(await launchAtLogin.isEnabled(), isFalse);
    await launchAtLogin.setEnabled(true);
    expect(await launchAtLogin.isEnabled(), isTrue);
    expect(
      await entry("org.knaapen.polder.desktop").readAsString(),
      contains('Exec="/opt/Polder.AppImage" --launched-at-login\n'),
    );

    await launchAtLogin.setEnabled(false);
    expect(await launchAtLogin.isEnabled(), isFalse);
  });

  test("launches through flatpak inside the sandbox", () async {
    final launchAtLogin = LinuxLaunchAtLogin({
      "HOME": home.path,
      "FLATPAK_ID": "org.knaapen.polder",
      "XDG_CONFIG_HOME": p.join(home.path, ".var", "app", "org.knaapen.polder", "config"),
    });

    await launchAtLogin.setEnabled(true);
    expect(
      await entry("org.knaapen.polder.desktop").readAsString(),
      contains("Exec=flatpak run org.knaapen.polder --launched-at-login"),
    );
  });

  test("recognises a launch at login from its arguments", () async {
    final launchAtLogin = LinuxLaunchAtLogin({"HOME": home.path});

    expect(await launchAtLogin.launchedAtLogin(["--launched-at-login"]), isTrue);
    expect(await launchAtLogin.launchedAtLogin(["polder://shortcut/search"]), isFalse);
  });
}
