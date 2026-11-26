# polder-client

The Flutter apps for Polder, for Android, iOS, macOS, Windows, Linux and the web.

## Layout

`client/` is a [pub workspace](https://dart.dev/tools/pub/workspaces): one `pubspec.lock` and one `flutter pub get`
for every app and package.

| Path | What |
| --- | --- |
| `apps/polder` | Polder: file browser, folder sync, conflict resolution, auto-upload on mobile, notes, calendar and an admin area |
| `packages/polder_core` | Data layer shared by the apps: API client, models, sign-in, offline storage and sync, realtime events |
| `packages/polder_ui` | Shared look and building blocks: theme, strings, layout, navigation, sign-in screens and common widgets |
| `packages/media_viewer` | Gesture layer for full-screen photo and video viewers |
| `packages/polder_calendar` | Calendar views and state over pluggable calendar sources |
| `packages/flutter_web_auth_2_desktop_webview_stub` | Override that leaves out flutter_web_auth_2's desktop webview |

Shared dependency overrides live in the workspace `pubspec.yaml`. Packages commit their generated localizations,
because Flutter only generates them for the app being built.

Dependencies point one way: apps → feature packages → `polder_ui` → `polder_core`. Each app tells `polder_ui`
about its routes by overriding `polderUiConfigProvider`.

Strings shared by the apps are in `packages/polder_ui/lib/l10n`, and the data layer's few strings (notifications,
the browser sign-in page) are in `packages/polder_core/lib/l10n`. After editing an `.arb` file, run
`flutter gen-l10n` in that package. `dart tool/l10n/split_arb.dart` moves keys from one catalog to another.

## Development

Check the [fvm file](.fvmrc) for the current flutter version

```sh
flutter pub get
(cd packages/polder_core && dart run build_runner build)
cd apps/polder
dart run build_runner build
flutter run -d macos --flavor dev
```

### Flavors

| Flavor | App id | Name | Icon |
| --- | --- | --- | --- |
| `prod` (default) | `org.knaapen.polder` | Polder | cyan |
| `dev` | `org.knaapen.polder.dev` | Polder Dev | orange |

`dev` installs next to the release app with its own settings, data and stored login, so debugging never touches
the live install. Android, iOS, macOS, Windows and Linux support it; the web has a single build. Builds without
`--flavor` use `prod`. Icons come from `icons_launcher.yaml` (`dart run icons_launcher:create`) and
`icons_launcher-dev.yaml` (`dart run icons_launcher:create --flavor dev`).

The document editor is a webview (`flutter_inappwebview`). On Linux it uses WPE WebKit through
`flutter_inappwebview_linux`, which needs the WPE WebKit libraries installed to build and run; see that package's
`WPE_BACKEND.md`.

### API client

Paths in this section and the next are relative to `packages/polder_core`.

`lib/services/api/generated` is a Chopper service and wire models generated from the server's OpenAPI
document, `openapi/polder.json`. Don't edit either by hand. After changing the server's API, run
`scripts/gen-client.sh` in the server repository, which updates both.

The app talks to the server through `PolderApi` (`polderApiProvider`, or `serverPolderApiProvider` before
signing in). It calls the generated service and converts its types to the app's models in
`lib/services/api/wire_mappers.dart`. When the API changes in a way the app depends on, those conversions
stop compiling, so the client can't drift from the server unnoticed.

### Offline storage

Notes, pinned files, queued uploads and calendar events are kept in a per-account drift database
(`lib/services/offline/`). Every change is written there first and sent to the server afterwards, so nothing is
lost while the server is unreachable or unable to store it.

On the web the database runs in a worker. `apps/polder/web/sqlite3.wasm` and `apps/polder/web/drift_worker.js` must match the `sqlite3`
and `drift` versions in the workspace `pubspec.lock`. After upgrading either package, download the matching files from the
[sqlite3.dart](https://github.com/simolus3/sqlite3.dart/releases) and
[drift](https://github.com/simolus3/drift/releases) releases.

## Tests

```sh
flutter analyze            # from client/, covers every app and package
cd apps/polder && flutter test
```

Paths below are relative to `apps/polder`. Unit tests run against `test/support/fake_server.dart`, an in-memory server.

`test/integration/` runs the API and sync engine against a real Polder server. It only runs when `POLDER_SERVER_DIR` points at the server's Go sources (it builds them with `go build`), or when `POLDER_SERVER_BIN` points at a server binary. Otherwise it skips.
