// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchFilter {

 SearchKey get key; SearchOp get op; List<String> get values; TextRange get range;
/// Create a copy of SearchFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchFilterCopyWith<SearchFilter> get copyWith => _$SearchFilterCopyWithImpl<SearchFilter>(this as SearchFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SearchFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchFilter&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.op, _this.op) || other.op == _this.op)&&const DeepCollectionEquality().equals(other.values, _this.values)&&(identical(other.range, _this.range) || other.range == _this.range));
}


@override
int get hashCode {
  final _this = this as SearchFilter;
  return Object.hash(runtimeType,_this.key,_this.op,const DeepCollectionEquality().hash(_this.values),_this.range);
}

@override
String toString() {
  final _this = this as SearchFilter;
  return 'SearchFilter(key: ${_this.key}, op: ${_this.op}, values: ${_this.values}, range: ${_this.range})';
}


}

/// @nodoc
abstract mixin class $SearchFilterCopyWith<$Res>  {
  factory $SearchFilterCopyWith(SearchFilter value, $Res Function(SearchFilter) _then) = _$SearchFilterCopyWithImpl;
@useResult
$Res call({
 SearchKey key, SearchOp op, List<String> values, TextRange range
});




}
/// @nodoc
class _$SearchFilterCopyWithImpl<$Res>
    implements $SearchFilterCopyWith<$Res> {
  _$SearchFilterCopyWithImpl(this._self, this._then);

  final SearchFilter _self;
  final $Res Function(SearchFilter) _then;

/// Create a copy of SearchFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? op = null,Object? values = null,Object? range = null,}) {
  return _then(SearchFilter(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as SearchKey,op: null == op ? _self.op : op // ignore: cast_nullable_to_non_nullable
as SearchOp,values: null == values ? _self.values : values // ignore: cast_nullable_to_non_nullable
as List<String>,range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as TextRange,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchFilter].
extension SearchFilterPatterns on SearchFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchFilter value)  $default,){
final _that = this;
switch (_that) {
case _SearchFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchFilter value)?  $default,){
final _that = this;
switch (_that) {
case _SearchFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SearchKey key,  SearchOp op,  List<String> values,  TextRange range)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchFilter() when $default != null:
return $default(_that.key,_that.op,_that.values,_that.range);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SearchKey key,  SearchOp op,  List<String> values,  TextRange range)  $default,) {final _that = this;
switch (_that) {
case _SearchFilter():
return $default(_that.key,_that.op,_that.values,_that.range);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SearchKey key,  SearchOp op,  List<String> values,  TextRange range)?  $default,) {final _that = this;
switch (_that) {
case _SearchFilter() when $default != null:
return $default(_that.key,_that.op,_that.values,_that.range);case _:
  return null;

}
}

}

/// @nodoc


class _SearchFilter implements SearchFilter {
  const _SearchFilter({required this.key, required this.op,  List<String> values = const <String>[], this.range = TextRange.empty}): _values = values;
  

@override final  SearchKey key;
@override final  SearchOp op;
 final  List<String> _values;
@override@JsonKey() List<String> get values {
  if (_values is EqualUnmodifiableListView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_values);
}

@override@JsonKey() final  TextRange range;

/// Create a copy of SearchFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchFilterCopyWith<_SearchFilter> get copyWith => __$SearchFilterCopyWithImpl<_SearchFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchFilter&&(identical(other.key, key) || other.key == key)&&(identical(other.op, op) || other.op == op)&&const DeepCollectionEquality().equals(other.values, _values)&&(identical(other.range, range) || other.range == range));
}


@override
int get hashCode {
    return Object.hash(runtimeType,key,op,const DeepCollectionEquality().hash(_values),range);
}

@override
String toString() {
    return 'SearchFilter(key: $key, op: $op, values: $values, range: $range)';
}


}

/// @nodoc
abstract mixin class _$SearchFilterCopyWith<$Res> implements $SearchFilterCopyWith<$Res> {
  factory _$SearchFilterCopyWith(_SearchFilter value, $Res Function(_SearchFilter) _then) = __$SearchFilterCopyWithImpl;
@override @useResult
$Res call({
 SearchKey key, SearchOp op, List<String> values, TextRange range
});




}
/// @nodoc
class __$SearchFilterCopyWithImpl<$Res>
    implements _$SearchFilterCopyWith<$Res> {
  __$SearchFilterCopyWithImpl(this._self, this._then);

  final _SearchFilter _self;
  final $Res Function(_SearchFilter) _then;

/// Create a copy of SearchFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? op = null,Object? values = null,Object? range = null,}) {
  return _then(_SearchFilter(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as SearchKey,op: null == op ? _self.op : op // ignore: cast_nullable_to_non_nullable
as SearchOp,values: null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as List<String>,range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as TextRange,
  ));
}


}

/// @nodoc
mixin _$SearchHit {

 FileEntry get entry; double get score; List<TextRange> get nameMatches; String? get snippet;
/// Create a copy of SearchHit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchHitCopyWith<SearchHit> get copyWith => _$SearchHitCopyWithImpl<SearchHit>(this as SearchHit, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SearchHit;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchHit&&(identical(other.entry, _this.entry) || other.entry == _this.entry)&&(identical(other.score, _this.score) || other.score == _this.score)&&const DeepCollectionEquality().equals(other.nameMatches, _this.nameMatches)&&(identical(other.snippet, _this.snippet) || other.snippet == _this.snippet));
}


@override
int get hashCode {
  final _this = this as SearchHit;
  return Object.hash(runtimeType,_this.entry,_this.score,const DeepCollectionEquality().hash(_this.nameMatches),_this.snippet);
}

@override
String toString() {
  final _this = this as SearchHit;
  return 'SearchHit(entry: ${_this.entry}, score: ${_this.score}, nameMatches: ${_this.nameMatches}, snippet: ${_this.snippet})';
}


}

/// @nodoc
abstract mixin class $SearchHitCopyWith<$Res>  {
  factory $SearchHitCopyWith(SearchHit value, $Res Function(SearchHit) _then) = _$SearchHitCopyWithImpl;
@useResult
$Res call({
 FileEntry entry, double score, List<TextRange> nameMatches, String? snippet
});


$FileEntryCopyWith<$Res> get entry;

}
/// @nodoc
class _$SearchHitCopyWithImpl<$Res>
    implements $SearchHitCopyWith<$Res> {
  _$SearchHitCopyWithImpl(this._self, this._then);

  final SearchHit _self;
  final $Res Function(SearchHit) _then;

/// Create a copy of SearchHit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entry = null,Object? score = null,Object? nameMatches = null,Object? snippet = freezed,}) {
  return _then(SearchHit(
entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as FileEntry,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,nameMatches: null == nameMatches ? _self.nameMatches : nameMatches // ignore: cast_nullable_to_non_nullable
as List<TextRange>,snippet: freezed == snippet ? _self.snippet : snippet // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of SearchHit
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res> get entry {
  
  return $FileEntryCopyWith<$Res>(_self.entry, (value) {
    return _then(_self.copyWith(entry: value));
  });
}
}


/// Adds pattern-matching-related methods to [SearchHit].
extension SearchHitPatterns on SearchHit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchHit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchHit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchHit value)  $default,){
final _that = this;
switch (_that) {
case _SearchHit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchHit value)?  $default,){
final _that = this;
switch (_that) {
case _SearchHit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FileEntry entry,  double score,  List<TextRange> nameMatches,  String? snippet)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchHit() when $default != null:
return $default(_that.entry,_that.score,_that.nameMatches,_that.snippet);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FileEntry entry,  double score,  List<TextRange> nameMatches,  String? snippet)  $default,) {final _that = this;
switch (_that) {
case _SearchHit():
return $default(_that.entry,_that.score,_that.nameMatches,_that.snippet);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FileEntry entry,  double score,  List<TextRange> nameMatches,  String? snippet)?  $default,) {final _that = this;
switch (_that) {
case _SearchHit() when $default != null:
return $default(_that.entry,_that.score,_that.nameMatches,_that.snippet);case _:
  return null;

}
}

}

/// @nodoc


class _SearchHit implements SearchHit {
  const _SearchHit({required this.entry, this.score = 0,  List<TextRange> nameMatches = const <TextRange>[], this.snippet}): _nameMatches = nameMatches;
  

@override final  FileEntry entry;
@override@JsonKey() final  double score;
 final  List<TextRange> _nameMatches;
@override@JsonKey() List<TextRange> get nameMatches {
  if (_nameMatches is EqualUnmodifiableListView) return _nameMatches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_nameMatches);
}

@override final  String? snippet;

/// Create a copy of SearchHit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchHitCopyWith<_SearchHit> get copyWith => __$SearchHitCopyWithImpl<_SearchHit>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchHit&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.score, score) || other.score == score)&&const DeepCollectionEquality().equals(other.nameMatches, _nameMatches)&&(identical(other.snippet, snippet) || other.snippet == snippet));
}


@override
int get hashCode {
    return Object.hash(runtimeType,entry,score,const DeepCollectionEquality().hash(_nameMatches),snippet);
}

@override
String toString() {
    return 'SearchHit(entry: $entry, score: $score, nameMatches: $nameMatches, snippet: $snippet)';
}


}

/// @nodoc
abstract mixin class _$SearchHitCopyWith<$Res> implements $SearchHitCopyWith<$Res> {
  factory _$SearchHitCopyWith(_SearchHit value, $Res Function(_SearchHit) _then) = __$SearchHitCopyWithImpl;
@override @useResult
$Res call({
 FileEntry entry, double score, List<TextRange> nameMatches, String? snippet
});


@override $FileEntryCopyWith<$Res> get entry;

}
/// @nodoc
class __$SearchHitCopyWithImpl<$Res>
    implements _$SearchHitCopyWith<$Res> {
  __$SearchHitCopyWithImpl(this._self, this._then);

  final _SearchHit _self;
  final $Res Function(_SearchHit) _then;

/// Create a copy of SearchHit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entry = null,Object? score = null,Object? nameMatches = null,Object? snippet = freezed,}) {
  return _then(_SearchHit(
entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as FileEntry,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,nameMatches: null == nameMatches ? _self._nameMatches : nameMatches // ignore: cast_nullable_to_non_nullable
as List<TextRange>,snippet: freezed == snippet ? _self.snippet : snippet // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of SearchHit
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res> get entry {
  
  return $FileEntryCopyWith<$Res>(_self.entry, (value) {
    return _then(_self.copyWith(entry: value));
  });
}
}

/// @nodoc
mixin _$SearchFacet {

 String get value; int get count;
/// Create a copy of SearchFacet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchFacetCopyWith<SearchFacet> get copyWith => _$SearchFacetCopyWithImpl<SearchFacet>(this as SearchFacet, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SearchFacet;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchFacet&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.count, _this.count) || other.count == _this.count));
}


@override
int get hashCode {
  final _this = this as SearchFacet;
  return Object.hash(runtimeType,_this.value,_this.count);
}

@override
String toString() {
  final _this = this as SearchFacet;
  return 'SearchFacet(value: ${_this.value}, count: ${_this.count})';
}


}

/// @nodoc
abstract mixin class $SearchFacetCopyWith<$Res>  {
  factory $SearchFacetCopyWith(SearchFacet value, $Res Function(SearchFacet) _then) = _$SearchFacetCopyWithImpl;
@useResult
$Res call({
 String value, int count
});




}
/// @nodoc
class _$SearchFacetCopyWithImpl<$Res>
    implements $SearchFacetCopyWith<$Res> {
  _$SearchFacetCopyWithImpl(this._self, this._then);

  final SearchFacet _self;
  final $Res Function(SearchFacet) _then;

/// Create a copy of SearchFacet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? count = null,}) {
  return _then(SearchFacet(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchFacet].
extension SearchFacetPatterns on SearchFacet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchFacet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchFacet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchFacet value)  $default,){
final _that = this;
switch (_that) {
case _SearchFacet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchFacet value)?  $default,){
final _that = this;
switch (_that) {
case _SearchFacet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchFacet() when $default != null:
return $default(_that.value,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value,  int count)  $default,) {final _that = this;
switch (_that) {
case _SearchFacet():
return $default(_that.value,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value,  int count)?  $default,) {final _that = this;
switch (_that) {
case _SearchFacet() when $default != null:
return $default(_that.value,_that.count);case _:
  return null;

}
}

}

/// @nodoc


class _SearchFacet implements SearchFacet {
  const _SearchFacet({required this.value, required this.count});
  

@override final  String value;
@override final  int count;

/// Create a copy of SearchFacet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchFacetCopyWith<_SearchFacet> get copyWith => __$SearchFacetCopyWithImpl<_SearchFacet>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchFacet&&(identical(other.value, value) || other.value == value)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode {
    return Object.hash(runtimeType,value,count);
}

@override
String toString() {
    return 'SearchFacet(value: $value, count: $count)';
}


}

/// @nodoc
abstract mixin class _$SearchFacetCopyWith<$Res> implements $SearchFacetCopyWith<$Res> {
  factory _$SearchFacetCopyWith(_SearchFacet value, $Res Function(_SearchFacet) _then) = __$SearchFacetCopyWithImpl;
@override @useResult
$Res call({
 String value, int count
});




}
/// @nodoc
class __$SearchFacetCopyWithImpl<$Res>
    implements _$SearchFacetCopyWith<$Res> {
  __$SearchFacetCopyWithImpl(this._self, this._then);

  final _SearchFacet _self;
  final $Res Function(_SearchFacet) _then;

/// Create a copy of SearchFacet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? count = null,}) {
  return _then(_SearchFacet(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$SearchWarning {

 TextRange get range; String get message;
/// Create a copy of SearchWarning
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchWarningCopyWith<SearchWarning> get copyWith => _$SearchWarningCopyWithImpl<SearchWarning>(this as SearchWarning, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SearchWarning;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchWarning&&(identical(other.range, _this.range) || other.range == _this.range)&&(identical(other.message, _this.message) || other.message == _this.message));
}


@override
int get hashCode {
  final _this = this as SearchWarning;
  return Object.hash(runtimeType,_this.range,_this.message);
}

@override
String toString() {
  final _this = this as SearchWarning;
  return 'SearchWarning(range: ${_this.range}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $SearchWarningCopyWith<$Res>  {
  factory $SearchWarningCopyWith(SearchWarning value, $Res Function(SearchWarning) _then) = _$SearchWarningCopyWithImpl;
@useResult
$Res call({
 TextRange range, String message
});




}
/// @nodoc
class _$SearchWarningCopyWithImpl<$Res>
    implements $SearchWarningCopyWith<$Res> {
  _$SearchWarningCopyWithImpl(this._self, this._then);

  final SearchWarning _self;
  final $Res Function(SearchWarning) _then;

/// Create a copy of SearchWarning
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? range = null,Object? message = null,}) {
  return _then(SearchWarning(
range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as TextRange,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchWarning].
extension SearchWarningPatterns on SearchWarning {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchWarning value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchWarning() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchWarning value)  $default,){
final _that = this;
switch (_that) {
case _SearchWarning():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchWarning value)?  $default,){
final _that = this;
switch (_that) {
case _SearchWarning() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TextRange range,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchWarning() when $default != null:
return $default(_that.range,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TextRange range,  String message)  $default,) {final _that = this;
switch (_that) {
case _SearchWarning():
return $default(_that.range,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TextRange range,  String message)?  $default,) {final _that = this;
switch (_that) {
case _SearchWarning() when $default != null:
return $default(_that.range,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _SearchWarning implements SearchWarning {
  const _SearchWarning({required this.range, required this.message});
  

@override final  TextRange range;
@override final  String message;

/// Create a copy of SearchWarning
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchWarningCopyWith<_SearchWarning> get copyWith => __$SearchWarningCopyWithImpl<_SearchWarning>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchWarning&&(identical(other.range, range) || other.range == range)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,range,message);
}

@override
String toString() {
    return 'SearchWarning(range: $range, message: $message)';
}


}

/// @nodoc
abstract mixin class _$SearchWarningCopyWith<$Res> implements $SearchWarningCopyWith<$Res> {
  factory _$SearchWarningCopyWith(_SearchWarning value, $Res Function(_SearchWarning) _then) = __$SearchWarningCopyWithImpl;
@override @useResult
$Res call({
 TextRange range, String message
});




}
/// @nodoc
class __$SearchWarningCopyWithImpl<$Res>
    implements _$SearchWarningCopyWith<$Res> {
  __$SearchWarningCopyWithImpl(this._self, this._then);

  final _SearchWarning _self;
  final $Res Function(_SearchWarning) _then;

/// Create a copy of SearchWarning
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? range = null,Object? message = null,}) {
  return _then(_SearchWarning(
range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as TextRange,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$SearchResults {

 String get query; int get total; List<SearchHit> get hits; List<SearchFilter> get filters; List<SearchFacet> get typeFacets; List<SearchFacet> get extFacets; List<SearchWarning> get warnings;
/// Create a copy of SearchResults
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchResultsCopyWith<SearchResults> get copyWith => _$SearchResultsCopyWithImpl<SearchResults>(this as SearchResults, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SearchResults;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchResults&&(identical(other.query, _this.query) || other.query == _this.query)&&(identical(other.total, _this.total) || other.total == _this.total)&&const DeepCollectionEquality().equals(other.hits, _this.hits)&&const DeepCollectionEquality().equals(other.filters, _this.filters)&&const DeepCollectionEquality().equals(other.typeFacets, _this.typeFacets)&&const DeepCollectionEquality().equals(other.extFacets, _this.extFacets)&&const DeepCollectionEquality().equals(other.warnings, _this.warnings));
}


@override
int get hashCode {
  final _this = this as SearchResults;
  return Object.hash(runtimeType,_this.query,_this.total,const DeepCollectionEquality().hash(_this.hits),const DeepCollectionEquality().hash(_this.filters),const DeepCollectionEquality().hash(_this.typeFacets),const DeepCollectionEquality().hash(_this.extFacets),const DeepCollectionEquality().hash(_this.warnings));
}

@override
String toString() {
  final _this = this as SearchResults;
  return 'SearchResults(query: ${_this.query}, total: ${_this.total}, hits: ${_this.hits}, filters: ${_this.filters}, typeFacets: ${_this.typeFacets}, extFacets: ${_this.extFacets}, warnings: ${_this.warnings})';
}


}

/// @nodoc
abstract mixin class $SearchResultsCopyWith<$Res>  {
  factory $SearchResultsCopyWith(SearchResults value, $Res Function(SearchResults) _then) = _$SearchResultsCopyWithImpl;
@useResult
$Res call({
 String query, int total, List<SearchHit> hits, List<SearchFilter> filters, List<SearchFacet> typeFacets, List<SearchFacet> extFacets, List<SearchWarning> warnings
});




}
/// @nodoc
class _$SearchResultsCopyWithImpl<$Res>
    implements $SearchResultsCopyWith<$Res> {
  _$SearchResultsCopyWithImpl(this._self, this._then);

  final SearchResults _self;
  final $Res Function(SearchResults) _then;

/// Create a copy of SearchResults
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? total = null,Object? hits = null,Object? filters = null,Object? typeFacets = null,Object? extFacets = null,Object? warnings = null,}) {
  return _then(SearchResults(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,hits: null == hits ? _self.hits : hits // ignore: cast_nullable_to_non_nullable
as List<SearchHit>,filters: null == filters ? _self.filters : filters // ignore: cast_nullable_to_non_nullable
as List<SearchFilter>,typeFacets: null == typeFacets ? _self.typeFacets : typeFacets // ignore: cast_nullable_to_non_nullable
as List<SearchFacet>,extFacets: null == extFacets ? _self.extFacets : extFacets // ignore: cast_nullable_to_non_nullable
as List<SearchFacet>,warnings: null == warnings ? _self.warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<SearchWarning>,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchResults].
extension SearchResultsPatterns on SearchResults {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchResults value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchResults() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchResults value)  $default,){
final _that = this;
switch (_that) {
case _SearchResults():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchResults value)?  $default,){
final _that = this;
switch (_that) {
case _SearchResults() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  int total,  List<SearchHit> hits,  List<SearchFilter> filters,  List<SearchFacet> typeFacets,  List<SearchFacet> extFacets,  List<SearchWarning> warnings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchResults() when $default != null:
return $default(_that.query,_that.total,_that.hits,_that.filters,_that.typeFacets,_that.extFacets,_that.warnings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  int total,  List<SearchHit> hits,  List<SearchFilter> filters,  List<SearchFacet> typeFacets,  List<SearchFacet> extFacets,  List<SearchWarning> warnings)  $default,) {final _that = this;
switch (_that) {
case _SearchResults():
return $default(_that.query,_that.total,_that.hits,_that.filters,_that.typeFacets,_that.extFacets,_that.warnings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  int total,  List<SearchHit> hits,  List<SearchFilter> filters,  List<SearchFacet> typeFacets,  List<SearchFacet> extFacets,  List<SearchWarning> warnings)?  $default,) {final _that = this;
switch (_that) {
case _SearchResults() when $default != null:
return $default(_that.query,_that.total,_that.hits,_that.filters,_that.typeFacets,_that.extFacets,_that.warnings);case _:
  return null;

}
}

}

/// @nodoc


class _SearchResults extends SearchResults {
  const _SearchResults({required this.query, this.total = 0,  List<SearchHit> hits = const <SearchHit>[],  List<SearchFilter> filters = const <SearchFilter>[],  List<SearchFacet> typeFacets = const <SearchFacet>[],  List<SearchFacet> extFacets = const <SearchFacet>[],  List<SearchWarning> warnings = const <SearchWarning>[]}): _hits = hits,_filters = filters,_typeFacets = typeFacets,_extFacets = extFacets,_warnings = warnings,super._();
  

@override final  String query;
@override@JsonKey() final  int total;
 final  List<SearchHit> _hits;
@override@JsonKey() List<SearchHit> get hits {
  if (_hits is EqualUnmodifiableListView) return _hits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hits);
}

 final  List<SearchFilter> _filters;
@override@JsonKey() List<SearchFilter> get filters {
  if (_filters is EqualUnmodifiableListView) return _filters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_filters);
}

 final  List<SearchFacet> _typeFacets;
@override@JsonKey() List<SearchFacet> get typeFacets {
  if (_typeFacets is EqualUnmodifiableListView) return _typeFacets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_typeFacets);
}

 final  List<SearchFacet> _extFacets;
@override@JsonKey() List<SearchFacet> get extFacets {
  if (_extFacets is EqualUnmodifiableListView) return _extFacets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_extFacets);
}

 final  List<SearchWarning> _warnings;
@override@JsonKey() List<SearchWarning> get warnings {
  if (_warnings is EqualUnmodifiableListView) return _warnings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_warnings);
}


/// Create a copy of SearchResults
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchResultsCopyWith<_SearchResults> get copyWith => __$SearchResultsCopyWithImpl<_SearchResults>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchResults&&(identical(other.query, query) || other.query == query)&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other.hits, _hits)&&const DeepCollectionEquality().equals(other.filters, _filters)&&const DeepCollectionEquality().equals(other.typeFacets, _typeFacets)&&const DeepCollectionEquality().equals(other.extFacets, _extFacets)&&const DeepCollectionEquality().equals(other.warnings, _warnings));
}


@override
int get hashCode {
    return Object.hash(runtimeType,query,total,const DeepCollectionEquality().hash(_hits),const DeepCollectionEquality().hash(_filters),const DeepCollectionEquality().hash(_typeFacets),const DeepCollectionEquality().hash(_extFacets),const DeepCollectionEquality().hash(_warnings));
}

@override
String toString() {
    return 'SearchResults(query: $query, total: $total, hits: $hits, filters: $filters, typeFacets: $typeFacets, extFacets: $extFacets, warnings: $warnings)';
}


}

/// @nodoc
abstract mixin class _$SearchResultsCopyWith<$Res> implements $SearchResultsCopyWith<$Res> {
  factory _$SearchResultsCopyWith(_SearchResults value, $Res Function(_SearchResults) _then) = __$SearchResultsCopyWithImpl;
@override @useResult
$Res call({
 String query, int total, List<SearchHit> hits, List<SearchFilter> filters, List<SearchFacet> typeFacets, List<SearchFacet> extFacets, List<SearchWarning> warnings
});




}
/// @nodoc
class __$SearchResultsCopyWithImpl<$Res>
    implements _$SearchResultsCopyWith<$Res> {
  __$SearchResultsCopyWithImpl(this._self, this._then);

  final _SearchResults _self;
  final $Res Function(_SearchResults) _then;

/// Create a copy of SearchResults
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? total = null,Object? hits = null,Object? filters = null,Object? typeFacets = null,Object? extFacets = null,Object? warnings = null,}) {
  return _then(_SearchResults(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,hits: null == hits ? _self._hits : hits // ignore: cast_nullable_to_non_nullable
as List<SearchHit>,filters: null == filters ? _self._filters : filters // ignore: cast_nullable_to_non_nullable
as List<SearchFilter>,typeFacets: null == typeFacets ? _self._typeFacets : typeFacets // ignore: cast_nullable_to_non_nullable
as List<SearchFacet>,extFacets: null == extFacets ? _self._extFacets : extFacets // ignore: cast_nullable_to_non_nullable
as List<SearchFacet>,warnings: null == warnings ? _self._warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<SearchWarning>,
  ));
}


}

/// @nodoc
mixin _$SearchSuggestion {

 String get value; String get insert; bool get isKey; int get count;
/// Create a copy of SearchSuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchSuggestionCopyWith<SearchSuggestion> get copyWith => _$SearchSuggestionCopyWithImpl<SearchSuggestion>(this as SearchSuggestion, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SearchSuggestion;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchSuggestion&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.insert, _this.insert) || other.insert == _this.insert)&&(identical(other.isKey, _this.isKey) || other.isKey == _this.isKey)&&(identical(other.count, _this.count) || other.count == _this.count));
}


@override
int get hashCode {
  final _this = this as SearchSuggestion;
  return Object.hash(runtimeType,_this.value,_this.insert,_this.isKey,_this.count);
}

@override
String toString() {
  final _this = this as SearchSuggestion;
  return 'SearchSuggestion(value: ${_this.value}, insert: ${_this.insert}, isKey: ${_this.isKey}, count: ${_this.count})';
}


}

/// @nodoc
abstract mixin class $SearchSuggestionCopyWith<$Res>  {
  factory $SearchSuggestionCopyWith(SearchSuggestion value, $Res Function(SearchSuggestion) _then) = _$SearchSuggestionCopyWithImpl;
@useResult
$Res call({
 String value, String insert, bool isKey, int count
});




}
/// @nodoc
class _$SearchSuggestionCopyWithImpl<$Res>
    implements $SearchSuggestionCopyWith<$Res> {
  _$SearchSuggestionCopyWithImpl(this._self, this._then);

  final SearchSuggestion _self;
  final $Res Function(SearchSuggestion) _then;

/// Create a copy of SearchSuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? insert = null,Object? isKey = null,Object? count = null,}) {
  return _then(SearchSuggestion(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,insert: null == insert ? _self.insert : insert // ignore: cast_nullable_to_non_nullable
as String,isKey: null == isKey ? _self.isKey : isKey // ignore: cast_nullable_to_non_nullable
as bool,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchSuggestion].
extension SearchSuggestionPatterns on SearchSuggestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchSuggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchSuggestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchSuggestion value)  $default,){
final _that = this;
switch (_that) {
case _SearchSuggestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchSuggestion value)?  $default,){
final _that = this;
switch (_that) {
case _SearchSuggestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value,  String insert,  bool isKey,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchSuggestion() when $default != null:
return $default(_that.value,_that.insert,_that.isKey,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value,  String insert,  bool isKey,  int count)  $default,) {final _that = this;
switch (_that) {
case _SearchSuggestion():
return $default(_that.value,_that.insert,_that.isKey,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value,  String insert,  bool isKey,  int count)?  $default,) {final _that = this;
switch (_that) {
case _SearchSuggestion() when $default != null:
return $default(_that.value,_that.insert,_that.isKey,_that.count);case _:
  return null;

}
}

}

/// @nodoc


class _SearchSuggestion implements SearchSuggestion {
  const _SearchSuggestion({required this.value, required this.insert, this.isKey = false, this.count = 0});
  

@override final  String value;
@override final  String insert;
@override@JsonKey() final  bool isKey;
@override@JsonKey() final  int count;

/// Create a copy of SearchSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchSuggestionCopyWith<_SearchSuggestion> get copyWith => __$SearchSuggestionCopyWithImpl<_SearchSuggestion>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchSuggestion&&(identical(other.value, value) || other.value == value)&&(identical(other.insert, insert) || other.insert == insert)&&(identical(other.isKey, isKey) || other.isKey == isKey)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode {
    return Object.hash(runtimeType,value,insert,isKey,count);
}

@override
String toString() {
    return 'SearchSuggestion(value: $value, insert: $insert, isKey: $isKey, count: $count)';
}


}

/// @nodoc
abstract mixin class _$SearchSuggestionCopyWith<$Res> implements $SearchSuggestionCopyWith<$Res> {
  factory _$SearchSuggestionCopyWith(_SearchSuggestion value, $Res Function(_SearchSuggestion) _then) = __$SearchSuggestionCopyWithImpl;
@override @useResult
$Res call({
 String value, String insert, bool isKey, int count
});




}
/// @nodoc
class __$SearchSuggestionCopyWithImpl<$Res>
    implements _$SearchSuggestionCopyWith<$Res> {
  __$SearchSuggestionCopyWithImpl(this._self, this._then);

  final _SearchSuggestion _self;
  final $Res Function(_SearchSuggestion) _then;

/// Create a copy of SearchSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? insert = null,Object? isKey = null,Object? count = null,}) {
  return _then(_SearchSuggestion(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,insert: null == insert ? _self.insert : insert // ignore: cast_nullable_to_non_nullable
as String,isKey: null == isKey ? _self.isKey : isKey // ignore: cast_nullable_to_non_nullable
as bool,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$SearchSuggestions {

 TextRange get range; List<SearchSuggestion> get suggestions;
/// Create a copy of SearchSuggestions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchSuggestionsCopyWith<SearchSuggestions> get copyWith => _$SearchSuggestionsCopyWithImpl<SearchSuggestions>(this as SearchSuggestions, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SearchSuggestions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchSuggestions&&(identical(other.range, _this.range) || other.range == _this.range)&&const DeepCollectionEquality().equals(other.suggestions, _this.suggestions));
}


@override
int get hashCode {
  final _this = this as SearchSuggestions;
  return Object.hash(runtimeType,_this.range,const DeepCollectionEquality().hash(_this.suggestions));
}

@override
String toString() {
  final _this = this as SearchSuggestions;
  return 'SearchSuggestions(range: ${_this.range}, suggestions: ${_this.suggestions})';
}


}

/// @nodoc
abstract mixin class $SearchSuggestionsCopyWith<$Res>  {
  factory $SearchSuggestionsCopyWith(SearchSuggestions value, $Res Function(SearchSuggestions) _then) = _$SearchSuggestionsCopyWithImpl;
@useResult
$Res call({
 TextRange range, List<SearchSuggestion> suggestions
});




}
/// @nodoc
class _$SearchSuggestionsCopyWithImpl<$Res>
    implements $SearchSuggestionsCopyWith<$Res> {
  _$SearchSuggestionsCopyWithImpl(this._self, this._then);

  final SearchSuggestions _self;
  final $Res Function(SearchSuggestions) _then;

/// Create a copy of SearchSuggestions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? range = null,Object? suggestions = null,}) {
  return _then(SearchSuggestions(
range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as TextRange,suggestions: null == suggestions ? _self.suggestions : suggestions // ignore: cast_nullable_to_non_nullable
as List<SearchSuggestion>,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchSuggestions].
extension SearchSuggestionsPatterns on SearchSuggestions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchSuggestions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchSuggestions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchSuggestions value)  $default,){
final _that = this;
switch (_that) {
case _SearchSuggestions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchSuggestions value)?  $default,){
final _that = this;
switch (_that) {
case _SearchSuggestions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TextRange range,  List<SearchSuggestion> suggestions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchSuggestions() when $default != null:
return $default(_that.range,_that.suggestions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TextRange range,  List<SearchSuggestion> suggestions)  $default,) {final _that = this;
switch (_that) {
case _SearchSuggestions():
return $default(_that.range,_that.suggestions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TextRange range,  List<SearchSuggestion> suggestions)?  $default,) {final _that = this;
switch (_that) {
case _SearchSuggestions() when $default != null:
return $default(_that.range,_that.suggestions);case _:
  return null;

}
}

}

/// @nodoc


class _SearchSuggestions implements SearchSuggestions {
  const _SearchSuggestions({this.range = TextRange.empty,  List<SearchSuggestion> suggestions = const <SearchSuggestion>[]}): _suggestions = suggestions;
  

@override@JsonKey() final  TextRange range;
 final  List<SearchSuggestion> _suggestions;
@override@JsonKey() List<SearchSuggestion> get suggestions {
  if (_suggestions is EqualUnmodifiableListView) return _suggestions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_suggestions);
}


/// Create a copy of SearchSuggestions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchSuggestionsCopyWith<_SearchSuggestions> get copyWith => __$SearchSuggestionsCopyWithImpl<_SearchSuggestions>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchSuggestions&&(identical(other.range, range) || other.range == range)&&const DeepCollectionEquality().equals(other.suggestions, _suggestions));
}


@override
int get hashCode {
    return Object.hash(runtimeType,range,const DeepCollectionEquality().hash(_suggestions));
}

@override
String toString() {
    return 'SearchSuggestions(range: $range, suggestions: $suggestions)';
}


}

/// @nodoc
abstract mixin class _$SearchSuggestionsCopyWith<$Res> implements $SearchSuggestionsCopyWith<$Res> {
  factory _$SearchSuggestionsCopyWith(_SearchSuggestions value, $Res Function(_SearchSuggestions) _then) = __$SearchSuggestionsCopyWithImpl;
@override @useResult
$Res call({
 TextRange range, List<SearchSuggestion> suggestions
});




}
/// @nodoc
class __$SearchSuggestionsCopyWithImpl<$Res>
    implements _$SearchSuggestionsCopyWith<$Res> {
  __$SearchSuggestionsCopyWithImpl(this._self, this._then);

  final _SearchSuggestions _self;
  final $Res Function(_SearchSuggestions) _then;

/// Create a copy of SearchSuggestions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? range = null,Object? suggestions = null,}) {
  return _then(_SearchSuggestions(
range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as TextRange,suggestions: null == suggestions ? _self._suggestions : suggestions // ignore: cast_nullable_to_non_nullable
as List<SearchSuggestion>,
  ));
}


}

// dart format on
