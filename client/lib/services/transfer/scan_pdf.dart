import "dart:io";
import "dart:isolate";
import "dart:typed_data";

import "package:pdf/pdf.dart";
import "package:pdf/widgets.dart" as pw;

abstract final class ScanPdf {
  static Future<Uint8List> build(List<String> pages) => Isolate.run(() async {
    final document = pw.Document();
    for (final page in pages) {
      final image = pw.MemoryImage(await File(page).readAsBytes());
      final width = PdfPageFormat.a4.width;
      final height = width * image.height! / image.width!;
      document.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(width, height),
          margin: pw.EdgeInsets.zero,
          build: (_) => pw.Image(image, fit: pw.BoxFit.fill),
        ),
      );
    }
    return document.save();
  });
}
