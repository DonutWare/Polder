import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:go_router/go_router.dart";

import "package:polder/providers/account_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/login/login_screen.dart";
import "package:polder/screens/login/widgets/credentials_step.dart";
import "package:polder/screens/login/widgets/server_step.dart";

import "../support/localized_app.dart";
import "../support/provider_harness.dart";
import "../support/scripted_client.dart";

void main() {
  late bool needsSetup;
  late ProviderHarness harness;
  late GoRouter router;

  Future<http.StreamedResponse> handle(RecordedRequest request) async => switch (request.path) {
    "/setup" when request.method == "GET" => jsonResponse(200, {"needsSetup": needsSetup}),
    "/setup" => jsonResponse(200, tokenJson("a", "r")),
    "/auth/login" when (request.data as Map)["password"] == "secret" => jsonResponse(200, tokenJson("a", "r")),
    _ => jsonResponse(401, {
      "error": {"code": "unauthorized", "message": "nope"},
    }),
  };

  setUp(() {
    needsSetup = false;
    harness = ProviderHarness(httpClient: ScriptedClient(handle));
    router = GoRouter(
      initialLocation: AppRoutes.login,
      routes: [
        GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
        GoRoute(path: AppRoutes.files, builder: (_, _) => const Text("files-home")),
      ],
    );
  });

  tearDown(() {
    router.dispose();
    harness.dispose();
  });

  Future<void> connect(WidgetTester tester) async {
    await tester.pumpWidget(localizedRouterApp(harness.container, router));
    await tester.enterText(find.byKey(ServerStep.serverUrlFieldKey), "cloud.test");
    await tester.pump();
    await tester.tap(find.byKey(ServerStep.connectButtonKey));
    await tester.pumpAndSettle();
  }

  Future<void> submitCredentials(WidgetTester tester, String password) async {
    await tester.enterText(find.byKey(CredentialsStep.usernameFieldKey), "alice");
    await tester.enterText(find.byKey(CredentialsStep.passwordFieldKey), password);
    await tester.pump();
    await tester.tap(find.byKey(CredentialsStep.submitButtonKey));
    await tester.pumpAndSettle();
  }

  testWidgets("connect is disabled until a server address is entered", (tester) async {
    await tester.pumpWidget(localizedRouterApp(harness.container, router));

    final button = tester.widget<FilledButton>(
      find.descendant(of: find.byKey(ServerStep.connectButtonKey), matching: find.byType(FilledButton)),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets("connecting shows the sign-in form for the normalized server", (tester) async {
    await connect(tester);

    expect(find.byKey(CredentialsStep.usernameFieldKey), findsOneWidget);
    expect(find.text("https://cloud.test"), findsOneWidget);
    expect(find.text("Sign in"), findsOneWidget);
  });

  testWidgets("a server without users shows first-run setup", (tester) async {
    needsSetup = true;

    await connect(tester);

    expect(find.text("Create administrator"), findsOneWidget);
  });

  testWidgets("wrong credentials show an error", (tester) async {
    await connect(tester);

    await submitCredentials(tester, "wrong");

    expect(find.text("Wrong username or password."), findsOneWidget);
    expect(harness.container.read(currentAccountProvider), isNull);
  });

  testWidgets("signing in stores the account and navigates to files", (tester) async {
    await connect(tester);

    await submitCredentials(tester, "secret");

    expect(find.text("files-home"), findsOneWidget);
    expect(harness.container.read(currentAccountProvider)?.user.username, "alice");
  });

  testWidgets("the server form stays up while connecting", (tester) async {
    final answer = Completer<void>();
    harness.dispose();
    harness = ProviderHarness(
      httpClient: ScriptedClient((request) async {
        await answer.future;
        return handle(request);
      }),
    );
    await tester.pumpWidget(localizedRouterApp(harness.container, router));
    await tester.enterText(find.byKey(ServerStep.serverUrlFieldKey), "cloud.test");
    await tester.pump();
    await tester.tap(find.byKey(ServerStep.connectButtonKey));
    await tester.pump();

    expect(find.byKey(ServerStep.serverUrlFieldKey), findsOneWidget);

    answer.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(CredentialsStep.usernameFieldKey), findsOneWidget);
  });

  group("served by the server as its web client", () {
    Future<void> openHosted(WidgetTester tester, http.Client httpClient) async {
      harness.dispose();
      harness = ProviderHarness(httpClient: httpClient, hostedServerUrl: "https://cloud.test");
      await tester.pumpWidget(localizedRouterApp(harness.container, router));
      await tester.pumpAndSettle();
    }

    testWidgets("goes straight to sign-in for its own server", (tester) async {
      await openHosted(tester, ScriptedClient(handle));

      expect(find.byKey(ServerStep.serverUrlFieldKey), findsNothing);
      expect(find.byKey(CredentialsStep.usernameFieldKey), findsOneWidget);
      expect(find.text("https://cloud.test"), findsOneWidget);
      expect(find.text("Change"), findsNothing);

      await submitCredentials(tester, "secret");

      expect(find.text("files-home"), findsOneWidget);
    });

    testWidgets("asks for a server when its own origin isn't one", (tester) async {
      await openHosted(
        tester,
        ScriptedClient(
          (_) async => jsonResponse(404, {
            "error": {"code": "not_found", "message": "nope"},
          }),
        ),
      );

      expect(find.byKey(ServerStep.serverUrlFieldKey), findsOneWidget);
      expect(find.text("https://cloud.test"), findsOneWidget);
    });

    testWidgets("asks for a server when its origin answers with a web page", (tester) async {
      await openHosted(
        tester,
        ScriptedClient((_) async => textResponse(200, "<!DOCTYPE html><html></html>", contentType: "text/html")),
      );

      expect(find.byKey(ServerStep.serverUrlFieldKey), findsOneWidget);
    });
  });
}
