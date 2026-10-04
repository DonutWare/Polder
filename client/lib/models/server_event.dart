import "package:freezed_annotation/freezed_annotation.dart";

import "package:nomad/models/activity.dart";

part "server_event.freezed.dart";

enum TransferPhase { started, progress, finished }

@freezed
sealed class ServerEvent with _$ServerEvent {
  const ServerEvent._();

  const factory ServerEvent.ready() = ReadyEvent;

  const factory ServerEvent.snapshot(List<LiveTransfer> transfers) = SnapshotEvent;

  const factory ServerEvent.transfer(TransferPhase phase, LiveTransfer transfer) = TransferEvent;

  const factory ServerEvent.activityCreated(ActivityEntry entry) = ActivityCreatedEvent;

  const factory ServerEvent.filesChanged(int userId, List<String> dirs) = FilesChangedEvent;

  const factory ServerEvent.error(String code, String message) = ServerErrorEvent;

  const factory ServerEvent.disconnected() = DisconnectedEvent;
}
