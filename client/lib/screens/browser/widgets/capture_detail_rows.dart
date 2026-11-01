import "package:flutter/material.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/util/capture_format.dart";
import "package:polder/util/external_link.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/detail_row.dart";

class CaptureDetailRows extends StatelessWidget {
  const CaptureDetailRows({required this.entry, super.key});

  final FileEntry entry;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final locale = context.localeName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (CaptureFormat.camera(entry) case final camera?) DetailRow(label: localized.cameraLabel, value: camera),
        if (entry.lens case final lens?) DetailRow(label: localized.lensLabel, value: lens),
        if (entry.aperture case final aperture?)
          DetailRow(
            label: localized.apertureLabel,
            value: CaptureFormat.aperture(aperture, locale: locale),
          ),
        if (entry.exposureTime case final exposureTime?)
          DetailRow(
            label: localized.shutterSpeedLabel,
            value: CaptureFormat.exposureTime(exposureTime, locale: locale),
          ),
        if (entry.focalLength case final focalLength?)
          DetailRow(
            label: localized.focalLengthLabel,
            value: CaptureFormat.focalLength(focalLength, locale: locale),
          ),
        if (entry.iso case final iso?) DetailRow(label: localized.isoLabel, value: "$iso"),
        if (entry.location case (:final latitude, :final longitude))
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => openExternalLink(CaptureFormat.mapUrl(latitude, longitude)),
            child: DetailRow(
              label: localized.locationLabel,
              value: CaptureFormat.coordinates(latitude, longitude, locale: locale),
              valueColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        if (entry.videoCodec case final codec?) DetailRow(label: localized.videoCodecLabel, value: codec.toUpperCase()),
        if (entry.frameRate case final frameRate?)
          DetailRow(
            label: localized.frameRateLabel,
            value: CaptureFormat.frameRate(frameRate, locale: locale),
          ),
        if (entry.audioCodec case final codec?) DetailRow(label: localized.audioCodecLabel, value: codec.toUpperCase()),
        if (entry.bitrate case final bitrate?)
          DetailRow(
            label: localized.bitrateLabel,
            value: CaptureFormat.bitrate(bitrate, locale: locale),
          ),
      ],
    );
  }
}
