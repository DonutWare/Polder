import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder_core/util/guarded_refresh.dart";

class _Answers {
  final local = <String?>[];
  final remote = <Completer<String>>[];
}

final _answersProvider = Provider((ref) => _Answers());

final _valueProvider = AsyncNotifierProvider<_ValueNotifier, String>(_ValueNotifier.new);

class _ValueNotifier extends AsyncNotifier<String> with GuardedRefresh {
  _Answers get _answers => ref.read(_answersProvider);

  @override
  Future<String> build() => localFirst(local: () async => _answers.local.removeAt(0), remote: _remote);

  Future<void> refresh() => refreshWith(_remote);

  Future<String> _remote() {
    final answer = Completer<String>();
    _answers.remote.add(answer);
    return answer.future;
  }
}

void main() {
  late ProviderContainer container;
  late _Answers answers;

  setUp(() {
    container = ProviderContainer();
    answers = container.read(_answersProvider);
  });

  tearDown(() => container.dispose());

  String? value() => container.read(_valueProvider).value;

  Future<void> start(String? local) async {
    answers.local.add(local);
    container.listen(_valueProvider, (_, _) {});
    await pumpEventQueue();
  }

  test("the local value is shown first and replaced by the server's", () async {
    await start("local");

    expect(value(), "local");
    answers.remote.single.complete("server");
    await pumpEventQueue();

    expect(value(), "server");
  });

  test("without a local value the server is waited for", () async {
    await start(null);

    answers.remote.single.complete("server");

    expect(await container.read(_valueProvider.future), "server");
  });

  test("a failing background refresh keeps the local value", () async {
    await start("local");

    answers.remote.single.completeError(StateError("offline"));
    await pumpEventQueue();

    expect(value(), "local");
  });

  test("an older refresh that answers last does not replace a newer one", () async {
    await start("local");
    final background = answers.remote.single;

    final newer = container.read(_valueProvider.notifier).refresh();
    answers.remote.last.complete("newer");
    await newer;
    background.complete("older");
    await pumpEventQueue();

    expect(value(), "newer");
  });

  test("a settled value is not replaced by a refresh that started before it", () async {
    await start("local");

    container.read(_valueProvider.notifier).settle("chosen");
    answers.remote.single.complete("older");
    await pumpEventQueue();

    expect(value(), "chosen");
  });
}
