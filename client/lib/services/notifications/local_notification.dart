import "dart:convert";

enum NotificationChannel { uploads, calendar, sharing }

enum NotificationActionId {
  accept,
  decline;

  static NotificationActionId? parse(String? id) => values.asNameMap()[id];
}

class NotificationAction {
  const NotificationAction(this.id, this.label, {this.destructive = false});

  final NotificationActionId id;
  final String label;
  final bool destructive;
}

class LocalNotification {
  const LocalNotification({
    required this.id,
    required this.channel,
    required this.title,
    this.body = "",
    this.location,
    this.actions = const [],
    this.data = const {},
    this.progress,
    this.ongoing = false,
    this.silent = false,
  });

  final int id;
  final NotificationChannel channel;
  final String title;
  final String body;
  final String? location;
  final List<NotificationAction> actions;
  final Map<String, Object?> data;
  final double? progress;
  final bool ongoing;
  final bool silent;

  String get payload => jsonEncode({"location": ?location, "data": data});
}

class NotificationTap {
  const NotificationTap({this.location, this.action, this.data = const {}});

  factory NotificationTap.decode(String? payload, String? actionId) {
    final action = NotificationActionId.parse(actionId);
    if (payload == null || payload.isEmpty) return NotificationTap(action: action);
    final Object? decoded;
    try {
      decoded = jsonDecode(payload);
    } on FormatException {
      return NotificationTap(action: action);
    }
    if (decoded is! Map<String, dynamic>) return NotificationTap(action: action);
    return NotificationTap(
      location: decoded["location"] as String?,
      action: action,
      data: (decoded["data"] as Map<String, dynamic>?) ?? const {},
    );
  }

  final String? location;
  final NotificationActionId? action;
  final Map<String, dynamic> data;
}

abstract final class NotificationIds {
  static const upload = 1;
  static const uploadCheck = 2;
  static const _feed = 0x10000000;
  static const _calendar = 0x20000000;
  static const _mask = 0x0FFFFFFF;

  static int feed(int notificationId) => _feed | (notificationId & _mask);

  static int calendar(String key) => _calendar | (stableHash(key) & _mask);

  static bool isCalendar(int id) => id & ~_mask == _calendar;

  static int stableHash(String value) {
    var hash = 0x811c9dc5;
    for (final byte in utf8.encode(value)) {
      hash = ((hash ^ byte) * 0x01000193) & 0xFFFFFFFF;
    }
    return hash;
  }
}
