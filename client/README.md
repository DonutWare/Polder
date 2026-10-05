# polder-client

The Flutter app for Polder, for Android, iOS, macOS, Windows, Linux and the web. It includes a file browser, folder sync, conflict resolution, auto-upload on mobile, and an admin area.

## Development

```sh
flutter pub get
dart run build_runner build   # freezed / json / drift / the API client
flutter run -d macos          # or linux, windows, a device
```

### API client

`lib/services/api/generated` is a Chopper service and wire models generated from the server's OpenAPI
document, `openapi/polder.json`. Don't edit either by hand. After changing the server's API, run
`scripts/gen-client.sh` in the server repository, which updates both.

The app talks to the server through `PolderApi` (`polderApiProvider`, or `serverPolderApiProvider` before
signing in). It calls the generated service and converts its types to the app's models in
`lib/services/api/wire_mappers.dart`. When the API changes in a way the app depends on, those conversions
stop compiling, so the client can't drift from the server unnoticed.

## Tests

```sh
flutter analyze
flutter test
```

Unit tests run against `test/support/fake_server.dart`, an in-memory server.

`test/integration/` runs the API and sync engine against a real Polder server. It only runs when `POLDER_SERVER_DIR` points at the server's Go sources (it builds them with `go build`), or when `POLDER_SERVER_BIN` points at a server binary. Otherwise it skips.
