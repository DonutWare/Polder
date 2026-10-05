import "dart:async";
import "dart:io";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;

import "package:polder/models/scan_session.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/browser/transfers_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/services/transfer/file_picker_service.dart";
import "package:polder/services/transfer/scan_pdf.dart";
import "package:polder/util/remote_path.dart";

final scanSessionProvider = NotifierProvider.autoDispose.family<ScanSessionNotifier, ScanSession, ScanRequest>(
  ScanSessionNotifier.new,
);

class ScanSessionNotifier extends Notifier<ScanSession> {
  ScanSessionNotifier(this.request);

  final ScanRequest request;

  final Set<String> _scannedFiles = {};
  var _handedOff = false;

  @override
  ScanSession build() {
    _scannedFiles.addAll(request.pages);
    ref.onDispose(() {
      if (!_handedOff) unawaited(_deleteFiles(_scannedFiles));
    });
    return ScanSession(
      directory: request.directory,
      name: ScanSession.defaultName(DateTime.now()),
      pages: request.pages,
    );
  }

  void addPages(List<String> pages) {
    _scannedFiles.addAll(pages);
    state = state.copyWith(pages: [...state.pages, ...pages]);
  }

  void removePage(int index) => state = state.copyWith(pages: [...state.pages]..removeAt(index));

  void reorderPage(int oldIndex, int newIndex) {
    final pages = [...state.pages];
    pages.insert(newIndex, pages.removeAt(oldIndex));
    state = state.copyWith(pages: pages);
  }

  void setName(String name) => state = state.copyWith(name: name);

  void setFormat(ScanFormat format) => state = state.copyWith(format: format);

  void setDirectory(String directory) => state = state.copyWith(directory: directory);

  // Completes once the upload is queued; the upload itself outlives this session.
  Future<void> save() async {
    final session = state;
    final transfers = ref.read(transfersProvider.notifier);
    final files = Set.of(_scannedFiles);
    switch (session.format) {
      case ScanFormat.pdf:
        final pdf = BytesPickedFile(session.fileName, await ScanPdf.build(session.pages));
        _handedOff = true;
        unawaited(_deleteFiles(files));
        unawaited(transfers.upload(session.directory, pdf));
      case ScanFormat.images:
        final folder = RemotePath.join(session.directory, session.fileName);
        await ref.read(polderApiProvider).mkdir(folder);
        ref.invalidate(directoryProvider(session.directory));
        _handedOff = true;
        unawaited(_uploadPages(transfers, folder, session.pages, files));
    }
  }

  static Future<void> _uploadPages(
    TransfersNotifier transfers,
    String folder,
    List<String> pages,
    Set<String> files,
  ) async {
    try {
      for (final (index, page) in pages.indexed) {
        await transfers.upload(folder, LocalPickedFile(page, name: pageFileName(index, page)));
      }
    } finally {
      await _deleteFiles(files);
    }
  }

  static String pageFileName(int index, String path) =>
      "Page ${(index + 1).toString().padLeft(2, "0")}${p.extension(path).toLowerCase()}";

  static Future<void> _deleteFiles(Iterable<String> paths) async {
    for (final path in paths) {
      try {
        await File(path).delete();
      } on FileSystemException {
        // Already gone, or the OS cleaned the cache first.
      }
    }
  }
}
