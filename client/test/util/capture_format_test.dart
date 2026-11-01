import "package:flutter_test/flutter_test.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/util/capture_format.dart";

FileEntry _photo(Map<String, dynamic> meta) =>
    FileEntry(path: "/photo.jpg", name: "photo.jpg", mtime: DateTime(2024), meta: meta);

void main() {
  test("drops the make when the model already names the brand", () {
    expect(CaptureFormat.camera(_photo({"cameraMake": "NIKON CORPORATION", "cameraModel": "NIKON D2H"})), "NIKON D2H");
    expect(
      CaptureFormat.camera(_photo({"cameraMake": "Apple", "cameraModel": "iPhone 15 Pro"})),
      "Apple iPhone 15 Pro",
    );
    expect(CaptureFormat.camera(_photo({"cameraMake": "Canon"})), "Canon");
    expect(CaptureFormat.camera(_photo({})), isNull);
  });

  test("shows short exposures as fractions of a second", () {
    expect(CaptureFormat.exposureTime(0.008), "1/125 s");
    expect(CaptureFormat.exposureTime(2.5), "2.5 s");
  });

  test("formats photo and video settings with their units", () {
    expect(CaptureFormat.aperture(1.8), "ƒ/1.8");
    expect(CaptureFormat.focalLength(23.33), "23.3 mm");
    expect(CaptureFormat.frameRate(29.97), "29.97 fps");
    expect(CaptureFormat.bitrate(8123456), "8.1 Mbps");
    expect(CaptureFormat.coordinates(52.3702, 4.8952), "52.37020, 4.89520");
  });

  test("reads location only when both coordinates are present", () {
    expect(_photo({"latitude": 52.37, "longitude": 4.89}).location, (latitude: 52.37, longitude: 4.89));
    expect(_photo({"latitude": 52.37}).location, isNull);
  });
}
