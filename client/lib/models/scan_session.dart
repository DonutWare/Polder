import "package:freezed_annotation/freezed_annotation.dart";
import "package:intl/intl.dart";

import "package:polder/util/remote_path.dart";

part "scan_session.freezed.dart";

enum ScanFormat { pdf, images }

class ScanRequest {
  const ScanRequest({required this.directory, required this.pages});

  final String directory;
  final List<String> pages;
}

@freezed
abstract class ScanSession with _$ScanSession {
  const ScanSession._();

  const factory ScanSession({
    required String directory,
    required String name,
    @Default([]) List<String> pages,
    @Default(ScanFormat.pdf) ScanFormat format,
  }) = _ScanSession;

  static String defaultName(DateTime time) => "Scan ${DateFormat("yyyy-MM-dd HH.mm").format(time)}";

  String get fileName => format == ScanFormat.pdf ? "${name.trim()}.pdf" : name.trim();

  bool get canSave => pages.isNotEmpty && RemotePath.isValidName(fileName);
}
