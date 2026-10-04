// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'directory_listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DirectoryListing _$DirectoryListingFromJson(Map<String, dynamic> json) =>
    _DirectoryListing(
      path: json['path'] as String,
      entries:
          (json['entries'] as List<dynamic>?)
              ?.map((e) => FileEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <FileEntry>[],
    );

Map<String, dynamic> _$DirectoryListingToJson(_DirectoryListing instance) =>
    <String, dynamic>{
      'path': instance.path,
      'entries': instance.entries.map((e) => e.toJson()).toList(),
    };
