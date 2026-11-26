enum ServerStorage { ok, full, readOnly, unknown }

enum ServerReachability { connecting, online, offline }

enum OfflineCause { noNetwork, serverUnreachable }

typedef ServerHealth = ({bool healthy, ServerStorage storage});

class ServerConnection {
  const ServerConnection({
    this.reachability = ServerReachability.connecting,
    this.cause,
    this.storage = ServerStorage.unknown,
  });

  final ServerReachability reachability;
  final OfflineCause? cause;
  final ServerStorage storage;

  bool get isOnline => reachability == ServerReachability.online;

  bool get isOffline => reachability == ServerReachability.offline;

  ServerConnection offline(OfflineCause cause) =>
      ServerConnection(reachability: ServerReachability.offline, cause: cause, storage: storage);

  @override
  bool operator ==(Object other) =>
      other is ServerConnection &&
      other.reachability == reachability &&
      other.cause == cause &&
      other.storage == storage;

  @override
  int get hashCode => Object.hash(reachability, cause, storage);
}
