import "package:flutter/material.dart";

import "package:freezed_annotation/freezed_annotation.dart";

import "package:polder/models/branding.dart";

part "user.freezed.dart";
part "user.g.dart";

enum UserRole { admin, user }

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    @Default("") String firstName,
    @Default("") String lastName,
    @Default("") String displayName,
    @Default("") String email,
    int? age,
    @Default("") String address,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}

@freezed
abstract class User with _$User {
  const User._();

  const factory User({
    required int id,
    required String username,
    @JsonKey(unknownEnumValue: UserRole.user) @Default(UserRole.user) UserRole role,
    @Default(0) int quotaBytes,
    @Default(0) int usedBytes,
    @Default(0) int historyBytes,
    @Default(false) bool disabled,
    DateTime? createdAt,
    @Default(UserProfile()) UserProfile profile,
    ServerImage? avatar,
    ThemeMode? theme,
    @ColorConverter() Color? accent,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  bool get isAdmin => role == UserRole.admin;

  bool get hasQuota => quotaBytes > 0;

  double get usedFraction => hasQuota ? (usedBytes / quotaBytes).clamp(0, 1).toDouble() : 0;

  bool get hasChosenAppearance => theme != null || accent != null;

  String get firstName => profile.firstName.isEmpty ? username : profile.firstName;

  String get displayName => profile.displayName.isEmpty ? firstName : profile.displayName;

  String get initials {
    final fullName = "${profile.firstName} ${profile.lastName}".trim();
    final source = [profile.displayName, fullName, username].firstWhere((name) => name.trim().isNotEmpty);
    final words = source.split(RegExp(r"[\s._-]+")).where((word) => word.isNotEmpty).toList();
    if (words.isEmpty) return "";
    return [words.first, if (words.length > 1) words.last].map((word) => word.characters.first).join().toUpperCase();
  }

  String? avatarUrl(String serverUrl) => avatar == null ? null : "$serverUrl/api/v1/users/$id/avatar/${avatar!.id}";
}
