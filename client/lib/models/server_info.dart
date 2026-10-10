class ServerInfo {
  final String version;
  final String buildNumber;

  ServerInfo({required this.version, required this.buildNumber});

  factory ServerInfo.fromJson(Map<String, dynamic> json) {
    return ServerInfo(version: json["version"] as String, buildNumber: json["buildNumber"] as String);
  }
}
