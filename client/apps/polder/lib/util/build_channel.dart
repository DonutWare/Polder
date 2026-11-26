enum BuildChannel {
  stable,
  nightly,
  dev;

  static BuildChannel parse(String value) => switch (value) {
    "stable" => stable,
    "nightly" => nightly,
    _ => dev,
  };

  bool get receivesUpdates => this != dev;
}

const _channel = String.fromEnvironment("POLDER_CHANNEL");

final currentBuildChannel = BuildChannel.parse(_channel);
