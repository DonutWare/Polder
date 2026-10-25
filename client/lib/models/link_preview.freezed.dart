// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'link_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LinkPreview {

 String get url; String get siteName; String? get title; String? get description; bool get hasImage; bool get hasIcon;
/// Create a copy of LinkPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkPreviewCopyWith<LinkPreview> get copyWith => _$LinkPreviewCopyWithImpl<LinkPreview>(this as LinkPreview, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LinkPreview;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkPreview&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.siteName, _this.siteName) || other.siteName == _this.siteName)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.hasImage, _this.hasImage) || other.hasImage == _this.hasImage)&&(identical(other.hasIcon, _this.hasIcon) || other.hasIcon == _this.hasIcon));
}


@override
int get hashCode {
  final _this = this as LinkPreview;
  return Object.hash(runtimeType,_this.url,_this.siteName,_this.title,_this.description,_this.hasImage,_this.hasIcon);
}

@override
String toString() {
  final _this = this as LinkPreview;
  return 'LinkPreview(url: ${_this.url}, siteName: ${_this.siteName}, title: ${_this.title}, description: ${_this.description}, hasImage: ${_this.hasImage}, hasIcon: ${_this.hasIcon})';
}


}

/// @nodoc
abstract mixin class $LinkPreviewCopyWith<$Res>  {
  factory $LinkPreviewCopyWith(LinkPreview value, $Res Function(LinkPreview) _then) = _$LinkPreviewCopyWithImpl;
@useResult
$Res call({
 String url, String siteName, String? title, String? description, bool hasImage, bool hasIcon
});




}
/// @nodoc
class _$LinkPreviewCopyWithImpl<$Res>
    implements $LinkPreviewCopyWith<$Res> {
  _$LinkPreviewCopyWithImpl(this._self, this._then);

  final LinkPreview _self;
  final $Res Function(LinkPreview) _then;

/// Create a copy of LinkPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? siteName = null,Object? title = freezed,Object? description = freezed,Object? hasImage = null,Object? hasIcon = null,}) {
  return _then(LinkPreview(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,siteName: null == siteName ? _self.siteName : siteName // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,hasImage: null == hasImage ? _self.hasImage : hasImage // ignore: cast_nullable_to_non_nullable
as bool,hasIcon: null == hasIcon ? _self.hasIcon : hasIcon // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LinkPreview].
extension LinkPreviewPatterns on LinkPreview {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LinkPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LinkPreview() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LinkPreview value)  $default,){
final _that = this;
switch (_that) {
case _LinkPreview():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LinkPreview value)?  $default,){
final _that = this;
switch (_that) {
case _LinkPreview() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String siteName,  String? title,  String? description,  bool hasImage,  bool hasIcon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LinkPreview() when $default != null:
return $default(_that.url,_that.siteName,_that.title,_that.description,_that.hasImage,_that.hasIcon);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String siteName,  String? title,  String? description,  bool hasImage,  bool hasIcon)  $default,) {final _that = this;
switch (_that) {
case _LinkPreview():
return $default(_that.url,_that.siteName,_that.title,_that.description,_that.hasImage,_that.hasIcon);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String siteName,  String? title,  String? description,  bool hasImage,  bool hasIcon)?  $default,) {final _that = this;
switch (_that) {
case _LinkPreview() when $default != null:
return $default(_that.url,_that.siteName,_that.title,_that.description,_that.hasImage,_that.hasIcon);case _:
  return null;

}
}

}

/// @nodoc


class _LinkPreview implements LinkPreview {
  const _LinkPreview({required this.url, required this.siteName, this.title, this.description, this.hasImage = false, this.hasIcon = false});
  

@override final  String url;
@override final  String siteName;
@override final  String? title;
@override final  String? description;
@override@JsonKey() final  bool hasImage;
@override@JsonKey() final  bool hasIcon;

/// Create a copy of LinkPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LinkPreviewCopyWith<_LinkPreview> get copyWith => __$LinkPreviewCopyWithImpl<_LinkPreview>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LinkPreview&&(identical(other.url, url) || other.url == url)&&(identical(other.siteName, siteName) || other.siteName == siteName)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.hasImage, hasImage) || other.hasImage == hasImage)&&(identical(other.hasIcon, hasIcon) || other.hasIcon == hasIcon));
}


@override
int get hashCode {
    return Object.hash(runtimeType,url,siteName,title,description,hasImage,hasIcon);
}

@override
String toString() {
    return 'LinkPreview(url: $url, siteName: $siteName, title: $title, description: $description, hasImage: $hasImage, hasIcon: $hasIcon)';
}


}

/// @nodoc
abstract mixin class _$LinkPreviewCopyWith<$Res> implements $LinkPreviewCopyWith<$Res> {
  factory _$LinkPreviewCopyWith(_LinkPreview value, $Res Function(_LinkPreview) _then) = __$LinkPreviewCopyWithImpl;
@override @useResult
$Res call({
 String url, String siteName, String? title, String? description, bool hasImage, bool hasIcon
});




}
/// @nodoc
class __$LinkPreviewCopyWithImpl<$Res>
    implements _$LinkPreviewCopyWith<$Res> {
  __$LinkPreviewCopyWithImpl(this._self, this._then);

  final _LinkPreview _self;
  final $Res Function(_LinkPreview) _then;

/// Create a copy of LinkPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? siteName = null,Object? title = freezed,Object? description = freezed,Object? hasImage = null,Object? hasIcon = null,}) {
  return _then(_LinkPreview(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,siteName: null == siteName ? _self.siteName : siteName // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,hasImage: null == hasImage ? _self.hasImage : hasImage // ignore: cast_nullable_to_non_nullable
as bool,hasIcon: null == hasIcon ? _self.hasIcon : hasIcon // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
