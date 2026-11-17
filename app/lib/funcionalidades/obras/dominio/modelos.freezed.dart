// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'modelos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ObraResumo {

 String get id; String get titulo; String? get subtitulo; List<String> get autores; String? get capaUrl; String? get isbn13; String? get faixaFinal; String get statusFicha; String get origem; bool get demonstracao;
/// Create a copy of ObraResumo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ObraResumoCopyWith<ObraResumo> get copyWith => _$ObraResumoCopyWithImpl<ObraResumo>(this as ObraResumo, _$identity);

  /// Serializes this ObraResumo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ObraResumo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ObraResumo&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.titulo, _this.titulo) || other.titulo == _this.titulo)&&(identical(other.subtitulo, _this.subtitulo) || other.subtitulo == _this.subtitulo)&&const DeepCollectionEquality().equals(other.autores, _this.autores)&&(identical(other.capaUrl, _this.capaUrl) || other.capaUrl == _this.capaUrl)&&(identical(other.isbn13, _this.isbn13) || other.isbn13 == _this.isbn13)&&(identical(other.faixaFinal, _this.faixaFinal) || other.faixaFinal == _this.faixaFinal)&&(identical(other.statusFicha, _this.statusFicha) || other.statusFicha == _this.statusFicha)&&(identical(other.origem, _this.origem) || other.origem == _this.origem)&&(identical(other.demonstracao, _this.demonstracao) || other.demonstracao == _this.demonstracao));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ObraResumo;
  return Object.hash(runtimeType,_this.id,_this.titulo,_this.subtitulo,const DeepCollectionEquality().hash(_this.autores),_this.capaUrl,_this.isbn13,_this.faixaFinal,_this.statusFicha,_this.origem,_this.demonstracao);
}

@override
String toString() {
  final _this = this as ObraResumo;
  return 'ObraResumo(id: ${_this.id}, titulo: ${_this.titulo}, subtitulo: ${_this.subtitulo}, autores: ${_this.autores}, capaUrl: ${_this.capaUrl}, isbn13: ${_this.isbn13}, faixaFinal: ${_this.faixaFinal}, statusFicha: ${_this.statusFicha}, origem: ${_this.origem}, demonstracao: ${_this.demonstracao})';
}


}

/// @nodoc
abstract mixin class $ObraResumoCopyWith<$Res>  {
  factory $ObraResumoCopyWith(ObraResumo value, $Res Function(ObraResumo) _then) = _$ObraResumoCopyWithImpl;
@useResult
$Res call({
 String id, String titulo, String? subtitulo, List<String> autores, String? capaUrl, String? isbn13, String? faixaFinal, String statusFicha, String origem, bool demonstracao
});




}
/// @nodoc
class _$ObraResumoCopyWithImpl<$Res>
    implements $ObraResumoCopyWith<$Res> {
  _$ObraResumoCopyWithImpl(this._self, this._then);

  final ObraResumo _self;
  final $Res Function(ObraResumo) _then;

/// Create a copy of ObraResumo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? titulo = null,Object? subtitulo = freezed,Object? autores = null,Object? capaUrl = freezed,Object? isbn13 = freezed,Object? faixaFinal = freezed,Object? statusFicha = null,Object? origem = null,Object? demonstracao = null,}) {
  return _then(ObraResumo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,titulo: null == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String,subtitulo: freezed == subtitulo ? _self.subtitulo : subtitulo // ignore: cast_nullable_to_non_nullable
as String?,autores: null == autores ? _self.autores : autores // ignore: cast_nullable_to_non_nullable
as List<String>,capaUrl: freezed == capaUrl ? _self.capaUrl : capaUrl // ignore: cast_nullable_to_non_nullable
as String?,isbn13: freezed == isbn13 ? _self.isbn13 : isbn13 // ignore: cast_nullable_to_non_nullable
as String?,faixaFinal: freezed == faixaFinal ? _self.faixaFinal : faixaFinal // ignore: cast_nullable_to_non_nullable
as String?,statusFicha: null == statusFicha ? _self.statusFicha : statusFicha // ignore: cast_nullable_to_non_nullable
as String,origem: null == origem ? _self.origem : origem // ignore: cast_nullable_to_non_nullable
as String,demonstracao: null == demonstracao ? _self.demonstracao : demonstracao // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ObraResumo].
extension ObraResumoPatterns on ObraResumo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ObraResumo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ObraResumo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ObraResumo value)  $default,){
final _that = this;
switch (_that) {
case _ObraResumo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ObraResumo value)?  $default,){
final _that = this;
switch (_that) {
case _ObraResumo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String titulo,  String? subtitulo,  List<String> autores,  String? capaUrl,  String? isbn13,  String? faixaFinal,  String statusFicha,  String origem,  bool demonstracao)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ObraResumo() when $default != null:
return $default(_that.id,_that.titulo,_that.subtitulo,_that.autores,_that.capaUrl,_that.isbn13,_that.faixaFinal,_that.statusFicha,_that.origem,_that.demonstracao);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String titulo,  String? subtitulo,  List<String> autores,  String? capaUrl,  String? isbn13,  String? faixaFinal,  String statusFicha,  String origem,  bool demonstracao)  $default,) {final _that = this;
switch (_that) {
case _ObraResumo():
return $default(_that.id,_that.titulo,_that.subtitulo,_that.autores,_that.capaUrl,_that.isbn13,_that.faixaFinal,_that.statusFicha,_that.origem,_that.demonstracao);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String titulo,  String? subtitulo,  List<String> autores,  String? capaUrl,  String? isbn13,  String? faixaFinal,  String statusFicha,  String origem,  bool demonstracao)?  $default,) {final _that = this;
switch (_that) {
case _ObraResumo() when $default != null:
return $default(_that.id,_that.titulo,_that.subtitulo,_that.autores,_that.capaUrl,_that.isbn13,_that.faixaFinal,_that.statusFicha,_that.origem,_that.demonstracao);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ObraResumo implements ObraResumo {
  const _ObraResumo({required this.id, required this.titulo, this.subtitulo,  List<String> autores = const <String>[], this.capaUrl, this.isbn13, this.faixaFinal, this.statusFicha = 'sem_ficha', this.origem = 'base_entrelinhas', this.demonstracao = false}): _autores = autores;
  factory _ObraResumo.fromJson(Map<String, dynamic> json) => _$ObraResumoFromJson(json);

@override final  String id;
@override final  String titulo;
@override final  String? subtitulo;
 final  List<String> _autores;
@override@JsonKey() List<String> get autores {
  if (_autores is EqualUnmodifiableListView) return _autores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_autores);
}

@override final  String? capaUrl;
@override final  String? isbn13;
@override final  String? faixaFinal;
@override@JsonKey() final  String statusFicha;
@override@JsonKey() final  String origem;
@override@JsonKey() final  bool demonstracao;

/// Create a copy of ObraResumo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ObraResumoCopyWith<_ObraResumo> get copyWith => __$ObraResumoCopyWithImpl<_ObraResumo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ObraResumoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ObraResumo&&(identical(other.id, id) || other.id == id)&&(identical(other.titulo, titulo) || other.titulo == titulo)&&(identical(other.subtitulo, subtitulo) || other.subtitulo == subtitulo)&&const DeepCollectionEquality().equals(other.autores, _autores)&&(identical(other.capaUrl, capaUrl) || other.capaUrl == capaUrl)&&(identical(other.isbn13, isbn13) || other.isbn13 == isbn13)&&(identical(other.faixaFinal, faixaFinal) || other.faixaFinal == faixaFinal)&&(identical(other.statusFicha, statusFicha) || other.statusFicha == statusFicha)&&(identical(other.origem, origem) || other.origem == origem)&&(identical(other.demonstracao, demonstracao) || other.demonstracao == demonstracao));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,titulo,subtitulo,const DeepCollectionEquality().hash(_autores),capaUrl,isbn13,faixaFinal,statusFicha,origem,demonstracao);
}

@override
String toString() {
    return 'ObraResumo(id: $id, titulo: $titulo, subtitulo: $subtitulo, autores: $autores, capaUrl: $capaUrl, isbn13: $isbn13, faixaFinal: $faixaFinal, statusFicha: $statusFicha, origem: $origem, demonstracao: $demonstracao)';
}


}

/// @nodoc
abstract mixin class _$ObraResumoCopyWith<$Res> implements $ObraResumoCopyWith<$Res> {
  factory _$ObraResumoCopyWith(_ObraResumo value, $Res Function(_ObraResumo) _then) = __$ObraResumoCopyWithImpl;
@override @useResult
$Res call({
 String id, String titulo, String? subtitulo, List<String> autores, String? capaUrl, String? isbn13, String? faixaFinal, String statusFicha, String origem, bool demonstracao
});




}
/// @nodoc
class __$ObraResumoCopyWithImpl<$Res>
    implements _$ObraResumoCopyWith<$Res> {
  __$ObraResumoCopyWithImpl(this._self, this._then);

  final _ObraResumo _self;
  final $Res Function(_ObraResumo) _then;

/// Create a copy of ObraResumo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? titulo = null,Object? subtitulo = freezed,Object? autores = null,Object? capaUrl = freezed,Object? isbn13 = freezed,Object? faixaFinal = freezed,Object? statusFicha = null,Object? origem = null,Object? demonstracao = null,}) {
  return _then(_ObraResumo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,titulo: null == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String,subtitulo: freezed == subtitulo ? _self.subtitulo : subtitulo // ignore: cast_nullable_to_non_nullable
as String?,autores: null == autores ? _self._autores : autores // ignore: cast_nullable_to_non_nullable
as List<String>,capaUrl: freezed == capaUrl ? _self.capaUrl : capaUrl // ignore: cast_nullable_to_non_nullable
as String?,isbn13: freezed == isbn13 ? _self.isbn13 : isbn13 // ignore: cast_nullable_to_non_nullable
as String?,faixaFinal: freezed == faixaFinal ? _self.faixaFinal : faixaFinal // ignore: cast_nullable_to_non_nullable
as String?,statusFicha: null == statusFicha ? _self.statusFicha : statusFicha // ignore: cast_nullable_to_non_nullable
as String,origem: null == origem ? _self.origem : origem // ignore: cast_nullable_to_non_nullable
as String,demonstracao: null == demonstracao ? _self.demonstracao : demonstracao // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Edicao {

 String get id; String? get isbn13; String? get isbn10; String? get editora; int? get ano; String? get capaUrl;
/// Create a copy of Edicao
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EdicaoCopyWith<Edicao> get copyWith => _$EdicaoCopyWithImpl<Edicao>(this as Edicao, _$identity);

  /// Serializes this Edicao to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Edicao;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Edicao&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.isbn13, _this.isbn13) || other.isbn13 == _this.isbn13)&&(identical(other.isbn10, _this.isbn10) || other.isbn10 == _this.isbn10)&&(identical(other.editora, _this.editora) || other.editora == _this.editora)&&(identical(other.ano, _this.ano) || other.ano == _this.ano)&&(identical(other.capaUrl, _this.capaUrl) || other.capaUrl == _this.capaUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Edicao;
  return Object.hash(runtimeType,_this.id,_this.isbn13,_this.isbn10,_this.editora,_this.ano,_this.capaUrl);
}

@override
String toString() {
  final _this = this as Edicao;
  return 'Edicao(id: ${_this.id}, isbn13: ${_this.isbn13}, isbn10: ${_this.isbn10}, editora: ${_this.editora}, ano: ${_this.ano}, capaUrl: ${_this.capaUrl})';
}


}

/// @nodoc
abstract mixin class $EdicaoCopyWith<$Res>  {
  factory $EdicaoCopyWith(Edicao value, $Res Function(Edicao) _then) = _$EdicaoCopyWithImpl;
@useResult
$Res call({
 String id, String? isbn13, String? isbn10, String? editora, int? ano, String? capaUrl
});




}
/// @nodoc
class _$EdicaoCopyWithImpl<$Res>
    implements $EdicaoCopyWith<$Res> {
  _$EdicaoCopyWithImpl(this._self, this._then);

  final Edicao _self;
  final $Res Function(Edicao) _then;

/// Create a copy of Edicao
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? isbn13 = freezed,Object? isbn10 = freezed,Object? editora = freezed,Object? ano = freezed,Object? capaUrl = freezed,}) {
  return _then(Edicao(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isbn13: freezed == isbn13 ? _self.isbn13 : isbn13 // ignore: cast_nullable_to_non_nullable
as String?,isbn10: freezed == isbn10 ? _self.isbn10 : isbn10 // ignore: cast_nullable_to_non_nullable
as String?,editora: freezed == editora ? _self.editora : editora // ignore: cast_nullable_to_non_nullable
as String?,ano: freezed == ano ? _self.ano : ano // ignore: cast_nullable_to_non_nullable
as int?,capaUrl: freezed == capaUrl ? _self.capaUrl : capaUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Edicao].
extension EdicaoPatterns on Edicao {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Edicao value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Edicao() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Edicao value)  $default,){
final _that = this;
switch (_that) {
case _Edicao():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Edicao value)?  $default,){
final _that = this;
switch (_that) {
case _Edicao() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? isbn13,  String? isbn10,  String? editora,  int? ano,  String? capaUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Edicao() when $default != null:
return $default(_that.id,_that.isbn13,_that.isbn10,_that.editora,_that.ano,_that.capaUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? isbn13,  String? isbn10,  String? editora,  int? ano,  String? capaUrl)  $default,) {final _that = this;
switch (_that) {
case _Edicao():
return $default(_that.id,_that.isbn13,_that.isbn10,_that.editora,_that.ano,_that.capaUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? isbn13,  String? isbn10,  String? editora,  int? ano,  String? capaUrl)?  $default,) {final _that = this;
switch (_that) {
case _Edicao() when $default != null:
return $default(_that.id,_that.isbn13,_that.isbn10,_that.editora,_that.ano,_that.capaUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Edicao implements Edicao {
  const _Edicao({required this.id, this.isbn13, this.isbn10, this.editora, this.ano, this.capaUrl});
  factory _Edicao.fromJson(Map<String, dynamic> json) => _$EdicaoFromJson(json);

@override final  String id;
@override final  String? isbn13;
@override final  String? isbn10;
@override final  String? editora;
@override final  int? ano;
@override final  String? capaUrl;

/// Create a copy of Edicao
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EdicaoCopyWith<_Edicao> get copyWith => __$EdicaoCopyWithImpl<_Edicao>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EdicaoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Edicao&&(identical(other.id, id) || other.id == id)&&(identical(other.isbn13, isbn13) || other.isbn13 == isbn13)&&(identical(other.isbn10, isbn10) || other.isbn10 == isbn10)&&(identical(other.editora, editora) || other.editora == editora)&&(identical(other.ano, ano) || other.ano == ano)&&(identical(other.capaUrl, capaUrl) || other.capaUrl == capaUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,isbn13,isbn10,editora,ano,capaUrl);
}

@override
String toString() {
    return 'Edicao(id: $id, isbn13: $isbn13, isbn10: $isbn10, editora: $editora, ano: $ano, capaUrl: $capaUrl)';
}


}

/// @nodoc
abstract mixin class _$EdicaoCopyWith<$Res> implements $EdicaoCopyWith<$Res> {
  factory _$EdicaoCopyWith(_Edicao value, $Res Function(_Edicao) _then) = __$EdicaoCopyWithImpl;
@override @useResult
$Res call({
 String id, String? isbn13, String? isbn10, String? editora, int? ano, String? capaUrl
});




}
/// @nodoc
class __$EdicaoCopyWithImpl<$Res>
    implements _$EdicaoCopyWith<$Res> {
  __$EdicaoCopyWithImpl(this._self, this._then);

  final _Edicao _self;
  final $Res Function(_Edicao) _then;

/// Create a copy of Edicao
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? isbn13 = freezed,Object? isbn10 = freezed,Object? editora = freezed,Object? ano = freezed,Object? capaUrl = freezed,}) {
  return _then(_Edicao(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isbn13: freezed == isbn13 ? _self.isbn13 : isbn13 // ignore: cast_nullable_to_non_nullable
as String?,isbn10: freezed == isbn10 ? _self.isbn10 : isbn10 // ignore: cast_nullable_to_non_nullable
as String?,editora: freezed == editora ? _self.editora : editora // ignore: cast_nullable_to_non_nullable
as String?,ano: freezed == ano ? _self.ano : ano // ignore: cast_nullable_to_non_nullable
as int?,capaUrl: freezed == capaUrl ? _self.capaUrl : capaUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ObraDetalhe {

 String get id; String get titulo; String? get subtitulo; List<String> get autores; String? get capaUrl; String? get isbn13; String? get faixaFinal; String get statusFicha; String get origem; bool get demonstracao; String? get sinopse; String? get genero; int? get paginas; String? get idioma; List<Edicao> get edicoes;
/// Create a copy of ObraDetalhe
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ObraDetalheCopyWith<ObraDetalhe> get copyWith => _$ObraDetalheCopyWithImpl<ObraDetalhe>(this as ObraDetalhe, _$identity);

  /// Serializes this ObraDetalhe to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ObraDetalhe;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ObraDetalhe&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.titulo, _this.titulo) || other.titulo == _this.titulo)&&(identical(other.subtitulo, _this.subtitulo) || other.subtitulo == _this.subtitulo)&&const DeepCollectionEquality().equals(other.autores, _this.autores)&&(identical(other.capaUrl, _this.capaUrl) || other.capaUrl == _this.capaUrl)&&(identical(other.isbn13, _this.isbn13) || other.isbn13 == _this.isbn13)&&(identical(other.faixaFinal, _this.faixaFinal) || other.faixaFinal == _this.faixaFinal)&&(identical(other.statusFicha, _this.statusFicha) || other.statusFicha == _this.statusFicha)&&(identical(other.origem, _this.origem) || other.origem == _this.origem)&&(identical(other.demonstracao, _this.demonstracao) || other.demonstracao == _this.demonstracao)&&(identical(other.sinopse, _this.sinopse) || other.sinopse == _this.sinopse)&&(identical(other.genero, _this.genero) || other.genero == _this.genero)&&(identical(other.paginas, _this.paginas) || other.paginas == _this.paginas)&&(identical(other.idioma, _this.idioma) || other.idioma == _this.idioma)&&const DeepCollectionEquality().equals(other.edicoes, _this.edicoes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ObraDetalhe;
  return Object.hash(runtimeType,_this.id,_this.titulo,_this.subtitulo,const DeepCollectionEquality().hash(_this.autores),_this.capaUrl,_this.isbn13,_this.faixaFinal,_this.statusFicha,_this.origem,_this.demonstracao,_this.sinopse,_this.genero,_this.paginas,_this.idioma,const DeepCollectionEquality().hash(_this.edicoes));
}

@override
String toString() {
  final _this = this as ObraDetalhe;
  return 'ObraDetalhe(id: ${_this.id}, titulo: ${_this.titulo}, subtitulo: ${_this.subtitulo}, autores: ${_this.autores}, capaUrl: ${_this.capaUrl}, isbn13: ${_this.isbn13}, faixaFinal: ${_this.faixaFinal}, statusFicha: ${_this.statusFicha}, origem: ${_this.origem}, demonstracao: ${_this.demonstracao}, sinopse: ${_this.sinopse}, genero: ${_this.genero}, paginas: ${_this.paginas}, idioma: ${_this.idioma}, edicoes: ${_this.edicoes})';
}


}

/// @nodoc
abstract mixin class $ObraDetalheCopyWith<$Res>  {
  factory $ObraDetalheCopyWith(ObraDetalhe value, $Res Function(ObraDetalhe) _then) = _$ObraDetalheCopyWithImpl;
@useResult
$Res call({
 String id, String titulo, String? subtitulo, List<String> autores, String? capaUrl, String? isbn13, String? faixaFinal, String statusFicha, String origem, bool demonstracao, String? sinopse, String? genero, int? paginas, String? idioma, List<Edicao> edicoes
});




}
/// @nodoc
class _$ObraDetalheCopyWithImpl<$Res>
    implements $ObraDetalheCopyWith<$Res> {
  _$ObraDetalheCopyWithImpl(this._self, this._then);

  final ObraDetalhe _self;
  final $Res Function(ObraDetalhe) _then;

/// Create a copy of ObraDetalhe
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? titulo = null,Object? subtitulo = freezed,Object? autores = null,Object? capaUrl = freezed,Object? isbn13 = freezed,Object? faixaFinal = freezed,Object? statusFicha = null,Object? origem = null,Object? demonstracao = null,Object? sinopse = freezed,Object? genero = freezed,Object? paginas = freezed,Object? idioma = freezed,Object? edicoes = null,}) {
  return _then(ObraDetalhe(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,titulo: null == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String,subtitulo: freezed == subtitulo ? _self.subtitulo : subtitulo // ignore: cast_nullable_to_non_nullable
as String?,autores: null == autores ? _self.autores : autores // ignore: cast_nullable_to_non_nullable
as List<String>,capaUrl: freezed == capaUrl ? _self.capaUrl : capaUrl // ignore: cast_nullable_to_non_nullable
as String?,isbn13: freezed == isbn13 ? _self.isbn13 : isbn13 // ignore: cast_nullable_to_non_nullable
as String?,faixaFinal: freezed == faixaFinal ? _self.faixaFinal : faixaFinal // ignore: cast_nullable_to_non_nullable
as String?,statusFicha: null == statusFicha ? _self.statusFicha : statusFicha // ignore: cast_nullable_to_non_nullable
as String,origem: null == origem ? _self.origem : origem // ignore: cast_nullable_to_non_nullable
as String,demonstracao: null == demonstracao ? _self.demonstracao : demonstracao // ignore: cast_nullable_to_non_nullable
as bool,sinopse: freezed == sinopse ? _self.sinopse : sinopse // ignore: cast_nullable_to_non_nullable
as String?,genero: freezed == genero ? _self.genero : genero // ignore: cast_nullable_to_non_nullable
as String?,paginas: freezed == paginas ? _self.paginas : paginas // ignore: cast_nullable_to_non_nullable
as int?,idioma: freezed == idioma ? _self.idioma : idioma // ignore: cast_nullable_to_non_nullable
as String?,edicoes: null == edicoes ? _self.edicoes : edicoes // ignore: cast_nullable_to_non_nullable
as List<Edicao>,
  ));
}

}


/// Adds pattern-matching-related methods to [ObraDetalhe].
extension ObraDetalhePatterns on ObraDetalhe {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ObraDetalhe value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ObraDetalhe() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ObraDetalhe value)  $default,){
final _that = this;
switch (_that) {
case _ObraDetalhe():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ObraDetalhe value)?  $default,){
final _that = this;
switch (_that) {
case _ObraDetalhe() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String titulo,  String? subtitulo,  List<String> autores,  String? capaUrl,  String? isbn13,  String? faixaFinal,  String statusFicha,  String origem,  bool demonstracao,  String? sinopse,  String? genero,  int? paginas,  String? idioma,  List<Edicao> edicoes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ObraDetalhe() when $default != null:
return $default(_that.id,_that.titulo,_that.subtitulo,_that.autores,_that.capaUrl,_that.isbn13,_that.faixaFinal,_that.statusFicha,_that.origem,_that.demonstracao,_that.sinopse,_that.genero,_that.paginas,_that.idioma,_that.edicoes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String titulo,  String? subtitulo,  List<String> autores,  String? capaUrl,  String? isbn13,  String? faixaFinal,  String statusFicha,  String origem,  bool demonstracao,  String? sinopse,  String? genero,  int? paginas,  String? idioma,  List<Edicao> edicoes)  $default,) {final _that = this;
switch (_that) {
case _ObraDetalhe():
return $default(_that.id,_that.titulo,_that.subtitulo,_that.autores,_that.capaUrl,_that.isbn13,_that.faixaFinal,_that.statusFicha,_that.origem,_that.demonstracao,_that.sinopse,_that.genero,_that.paginas,_that.idioma,_that.edicoes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String titulo,  String? subtitulo,  List<String> autores,  String? capaUrl,  String? isbn13,  String? faixaFinal,  String statusFicha,  String origem,  bool demonstracao,  String? sinopse,  String? genero,  int? paginas,  String? idioma,  List<Edicao> edicoes)?  $default,) {final _that = this;
switch (_that) {
case _ObraDetalhe() when $default != null:
return $default(_that.id,_that.titulo,_that.subtitulo,_that.autores,_that.capaUrl,_that.isbn13,_that.faixaFinal,_that.statusFicha,_that.origem,_that.demonstracao,_that.sinopse,_that.genero,_that.paginas,_that.idioma,_that.edicoes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ObraDetalhe extends ObraDetalhe {
  const _ObraDetalhe({required this.id, required this.titulo, this.subtitulo,  List<String> autores = const <String>[], this.capaUrl, this.isbn13, this.faixaFinal, this.statusFicha = 'sem_ficha', this.origem = 'base_entrelinhas', this.demonstracao = false, this.sinopse, this.genero, this.paginas, this.idioma,  List<Edicao> edicoes = const <Edicao>[]}): _autores = autores,_edicoes = edicoes,super._();
  factory _ObraDetalhe.fromJson(Map<String, dynamic> json) => _$ObraDetalheFromJson(json);

@override final  String id;
@override final  String titulo;
@override final  String? subtitulo;
 final  List<String> _autores;
@override@JsonKey() List<String> get autores {
  if (_autores is EqualUnmodifiableListView) return _autores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_autores);
}

@override final  String? capaUrl;
@override final  String? isbn13;
@override final  String? faixaFinal;
@override@JsonKey() final  String statusFicha;
@override@JsonKey() final  String origem;
@override@JsonKey() final  bool demonstracao;
@override final  String? sinopse;
@override final  String? genero;
@override final  int? paginas;
@override final  String? idioma;
 final  List<Edicao> _edicoes;
@override@JsonKey() List<Edicao> get edicoes {
  if (_edicoes is EqualUnmodifiableListView) return _edicoes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_edicoes);
}


/// Create a copy of ObraDetalhe
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ObraDetalheCopyWith<_ObraDetalhe> get copyWith => __$ObraDetalheCopyWithImpl<_ObraDetalhe>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ObraDetalheToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ObraDetalhe&&(identical(other.id, id) || other.id == id)&&(identical(other.titulo, titulo) || other.titulo == titulo)&&(identical(other.subtitulo, subtitulo) || other.subtitulo == subtitulo)&&const DeepCollectionEquality().equals(other.autores, _autores)&&(identical(other.capaUrl, capaUrl) || other.capaUrl == capaUrl)&&(identical(other.isbn13, isbn13) || other.isbn13 == isbn13)&&(identical(other.faixaFinal, faixaFinal) || other.faixaFinal == faixaFinal)&&(identical(other.statusFicha, statusFicha) || other.statusFicha == statusFicha)&&(identical(other.origem, origem) || other.origem == origem)&&(identical(other.demonstracao, demonstracao) || other.demonstracao == demonstracao)&&(identical(other.sinopse, sinopse) || other.sinopse == sinopse)&&(identical(other.genero, genero) || other.genero == genero)&&(identical(other.paginas, paginas) || other.paginas == paginas)&&(identical(other.idioma, idioma) || other.idioma == idioma)&&const DeepCollectionEquality().equals(other.edicoes, _edicoes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,titulo,subtitulo,const DeepCollectionEquality().hash(_autores),capaUrl,isbn13,faixaFinal,statusFicha,origem,demonstracao,sinopse,genero,paginas,idioma,const DeepCollectionEquality().hash(_edicoes));
}

@override
String toString() {
    return 'ObraDetalhe(id: $id, titulo: $titulo, subtitulo: $subtitulo, autores: $autores, capaUrl: $capaUrl, isbn13: $isbn13, faixaFinal: $faixaFinal, statusFicha: $statusFicha, origem: $origem, demonstracao: $demonstracao, sinopse: $sinopse, genero: $genero, paginas: $paginas, idioma: $idioma, edicoes: $edicoes)';
}


}

/// @nodoc
abstract mixin class _$ObraDetalheCopyWith<$Res> implements $ObraDetalheCopyWith<$Res> {
  factory _$ObraDetalheCopyWith(_ObraDetalhe value, $Res Function(_ObraDetalhe) _then) = __$ObraDetalheCopyWithImpl;
@override @useResult
$Res call({
 String id, String titulo, String? subtitulo, List<String> autores, String? capaUrl, String? isbn13, String? faixaFinal, String statusFicha, String origem, bool demonstracao, String? sinopse, String? genero, int? paginas, String? idioma, List<Edicao> edicoes
});




}
/// @nodoc
class __$ObraDetalheCopyWithImpl<$Res>
    implements _$ObraDetalheCopyWith<$Res> {
  __$ObraDetalheCopyWithImpl(this._self, this._then);

  final _ObraDetalhe _self;
  final $Res Function(_ObraDetalhe) _then;

/// Create a copy of ObraDetalhe
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? titulo = null,Object? subtitulo = freezed,Object? autores = null,Object? capaUrl = freezed,Object? isbn13 = freezed,Object? faixaFinal = freezed,Object? statusFicha = null,Object? origem = null,Object? demonstracao = null,Object? sinopse = freezed,Object? genero = freezed,Object? paginas = freezed,Object? idioma = freezed,Object? edicoes = null,}) {
  return _then(_ObraDetalhe(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,titulo: null == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String,subtitulo: freezed == subtitulo ? _self.subtitulo : subtitulo // ignore: cast_nullable_to_non_nullable
as String?,autores: null == autores ? _self._autores : autores // ignore: cast_nullable_to_non_nullable
as List<String>,capaUrl: freezed == capaUrl ? _self.capaUrl : capaUrl // ignore: cast_nullable_to_non_nullable
as String?,isbn13: freezed == isbn13 ? _self.isbn13 : isbn13 // ignore: cast_nullable_to_non_nullable
as String?,faixaFinal: freezed == faixaFinal ? _self.faixaFinal : faixaFinal // ignore: cast_nullable_to_non_nullable
as String?,statusFicha: null == statusFicha ? _self.statusFicha : statusFicha // ignore: cast_nullable_to_non_nullable
as String,origem: null == origem ? _self.origem : origem // ignore: cast_nullable_to_non_nullable
as String,demonstracao: null == demonstracao ? _self.demonstracao : demonstracao // ignore: cast_nullable_to_non_nullable
as bool,sinopse: freezed == sinopse ? _self.sinopse : sinopse // ignore: cast_nullable_to_non_nullable
as String?,genero: freezed == genero ? _self.genero : genero // ignore: cast_nullable_to_non_nullable
as String?,paginas: freezed == paginas ? _self.paginas : paginas // ignore: cast_nullable_to_non_nullable
as int?,idioma: freezed == idioma ? _self.idioma : idioma // ignore: cast_nullable_to_non_nullable
as String?,edicoes: null == edicoes ? _self._edicoes : edicoes // ignore: cast_nullable_to_non_nullable
as List<Edicao>,
  ));
}


}


/// @nodoc
mixin _$ResultadoBusca {

 List<ObraResumo> get resultados; String? get isbn; bool get fontesExternasIndisponiveis;
/// Create a copy of ResultadoBusca
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResultadoBuscaCopyWith<ResultadoBusca> get copyWith => _$ResultadoBuscaCopyWithImpl<ResultadoBusca>(this as ResultadoBusca, _$identity);

  /// Serializes this ResultadoBusca to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ResultadoBusca;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResultadoBusca&&const DeepCollectionEquality().equals(other.resultados, _this.resultados)&&(identical(other.isbn, _this.isbn) || other.isbn == _this.isbn)&&(identical(other.fontesExternasIndisponiveis, _this.fontesExternasIndisponiveis) || other.fontesExternasIndisponiveis == _this.fontesExternasIndisponiveis));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ResultadoBusca;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.resultados),_this.isbn,_this.fontesExternasIndisponiveis);
}

@override
String toString() {
  final _this = this as ResultadoBusca;
  return 'ResultadoBusca(resultados: ${_this.resultados}, isbn: ${_this.isbn}, fontesExternasIndisponiveis: ${_this.fontesExternasIndisponiveis})';
}


}

/// @nodoc
abstract mixin class $ResultadoBuscaCopyWith<$Res>  {
  factory $ResultadoBuscaCopyWith(ResultadoBusca value, $Res Function(ResultadoBusca) _then) = _$ResultadoBuscaCopyWithImpl;
@useResult
$Res call({
 List<ObraResumo> resultados, String? isbn, bool fontesExternasIndisponiveis
});




}
/// @nodoc
class _$ResultadoBuscaCopyWithImpl<$Res>
    implements $ResultadoBuscaCopyWith<$Res> {
  _$ResultadoBuscaCopyWithImpl(this._self, this._then);

  final ResultadoBusca _self;
  final $Res Function(ResultadoBusca) _then;

/// Create a copy of ResultadoBusca
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? resultados = null,Object? isbn = freezed,Object? fontesExternasIndisponiveis = null,}) {
  return _then(ResultadoBusca(
resultados: null == resultados ? _self.resultados : resultados // ignore: cast_nullable_to_non_nullable
as List<ObraResumo>,isbn: freezed == isbn ? _self.isbn : isbn // ignore: cast_nullable_to_non_nullable
as String?,fontesExternasIndisponiveis: null == fontesExternasIndisponiveis ? _self.fontesExternasIndisponiveis : fontesExternasIndisponiveis // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ResultadoBusca].
extension ResultadoBuscaPatterns on ResultadoBusca {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResultadoBusca value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResultadoBusca() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResultadoBusca value)  $default,){
final _that = this;
switch (_that) {
case _ResultadoBusca():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResultadoBusca value)?  $default,){
final _that = this;
switch (_that) {
case _ResultadoBusca() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ObraResumo> resultados,  String? isbn,  bool fontesExternasIndisponiveis)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResultadoBusca() when $default != null:
return $default(_that.resultados,_that.isbn,_that.fontesExternasIndisponiveis);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ObraResumo> resultados,  String? isbn,  bool fontesExternasIndisponiveis)  $default,) {final _that = this;
switch (_that) {
case _ResultadoBusca():
return $default(_that.resultados,_that.isbn,_that.fontesExternasIndisponiveis);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ObraResumo> resultados,  String? isbn,  bool fontesExternasIndisponiveis)?  $default,) {final _that = this;
switch (_that) {
case _ResultadoBusca() when $default != null:
return $default(_that.resultados,_that.isbn,_that.fontesExternasIndisponiveis);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResultadoBusca implements ResultadoBusca {
  const _ResultadoBusca({ List<ObraResumo> resultados = const <ObraResumo>[], this.isbn, this.fontesExternasIndisponiveis = false}): _resultados = resultados;
  factory _ResultadoBusca.fromJson(Map<String, dynamic> json) => _$ResultadoBuscaFromJson(json);

 final  List<ObraResumo> _resultados;
@override@JsonKey() List<ObraResumo> get resultados {
  if (_resultados is EqualUnmodifiableListView) return _resultados;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_resultados);
}

@override final  String? isbn;
@override@JsonKey() final  bool fontesExternasIndisponiveis;

/// Create a copy of ResultadoBusca
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResultadoBuscaCopyWith<_ResultadoBusca> get copyWith => __$ResultadoBuscaCopyWithImpl<_ResultadoBusca>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResultadoBuscaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResultadoBusca&&const DeepCollectionEquality().equals(other.resultados, _resultados)&&(identical(other.isbn, isbn) || other.isbn == isbn)&&(identical(other.fontesExternasIndisponiveis, fontesExternasIndisponiveis) || other.fontesExternasIndisponiveis == fontesExternasIndisponiveis));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_resultados),isbn,fontesExternasIndisponiveis);
}

@override
String toString() {
    return 'ResultadoBusca(resultados: $resultados, isbn: $isbn, fontesExternasIndisponiveis: $fontesExternasIndisponiveis)';
}


}

/// @nodoc
abstract mixin class _$ResultadoBuscaCopyWith<$Res> implements $ResultadoBuscaCopyWith<$Res> {
  factory _$ResultadoBuscaCopyWith(_ResultadoBusca value, $Res Function(_ResultadoBusca) _then) = __$ResultadoBuscaCopyWithImpl;
@override @useResult
$Res call({
 List<ObraResumo> resultados, String? isbn, bool fontesExternasIndisponiveis
});




}
/// @nodoc
class __$ResultadoBuscaCopyWithImpl<$Res>
    implements _$ResultadoBuscaCopyWith<$Res> {
  __$ResultadoBuscaCopyWithImpl(this._self, this._then);

  final _ResultadoBusca _self;
  final $Res Function(_ResultadoBusca) _then;

/// Create a copy of ResultadoBusca
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? resultados = null,Object? isbn = freezed,Object? fontesExternasIndisponiveis = null,}) {
  return _then(_ResultadoBusca(
resultados: null == resultados ? _self._resultados : resultados // ignore: cast_nullable_to_non_nullable
as List<ObraResumo>,isbn: freezed == isbn ? _self.isbn : isbn // ignore: cast_nullable_to_non_nullable
as String?,fontesExternasIndisponiveis: null == fontesExternasIndisponiveis ? _self.fontesExternasIndisponiveis : fontesExternasIndisponiveis // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$EixoFicha {

 int get nivel; String get faixa; String get justificativa;
/// Create a copy of EixoFicha
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EixoFichaCopyWith<EixoFicha> get copyWith => _$EixoFichaCopyWithImpl<EixoFicha>(this as EixoFicha, _$identity);

  /// Serializes this EixoFicha to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EixoFicha;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EixoFicha&&(identical(other.nivel, _this.nivel) || other.nivel == _this.nivel)&&(identical(other.faixa, _this.faixa) || other.faixa == _this.faixa)&&(identical(other.justificativa, _this.justificativa) || other.justificativa == _this.justificativa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EixoFicha;
  return Object.hash(runtimeType,_this.nivel,_this.faixa,_this.justificativa);
}

@override
String toString() {
  final _this = this as EixoFicha;
  return 'EixoFicha(nivel: ${_this.nivel}, faixa: ${_this.faixa}, justificativa: ${_this.justificativa})';
}


}

/// @nodoc
abstract mixin class $EixoFichaCopyWith<$Res>  {
  factory $EixoFichaCopyWith(EixoFicha value, $Res Function(EixoFicha) _then) = _$EixoFichaCopyWithImpl;
@useResult
$Res call({
 int nivel, String faixa, String justificativa
});




}
/// @nodoc
class _$EixoFichaCopyWithImpl<$Res>
    implements $EixoFichaCopyWith<$Res> {
  _$EixoFichaCopyWithImpl(this._self, this._then);

  final EixoFicha _self;
  final $Res Function(EixoFicha) _then;

/// Create a copy of EixoFicha
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nivel = null,Object? faixa = null,Object? justificativa = null,}) {
  return _then(EixoFicha(
nivel: null == nivel ? _self.nivel : nivel // ignore: cast_nullable_to_non_nullable
as int,faixa: null == faixa ? _self.faixa : faixa // ignore: cast_nullable_to_non_nullable
as String,justificativa: null == justificativa ? _self.justificativa : justificativa // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EixoFicha].
extension EixoFichaPatterns on EixoFicha {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EixoFicha value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EixoFicha() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EixoFicha value)  $default,){
final _that = this;
switch (_that) {
case _EixoFicha():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EixoFicha value)?  $default,){
final _that = this;
switch (_that) {
case _EixoFicha() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int nivel,  String faixa,  String justificativa)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EixoFicha() when $default != null:
return $default(_that.nivel,_that.faixa,_that.justificativa);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int nivel,  String faixa,  String justificativa)  $default,) {final _that = this;
switch (_that) {
case _EixoFicha():
return $default(_that.nivel,_that.faixa,_that.justificativa);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int nivel,  String faixa,  String justificativa)?  $default,) {final _that = this;
switch (_that) {
case _EixoFicha() when $default != null:
return $default(_that.nivel,_that.faixa,_that.justificativa);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EixoFicha implements EixoFicha {
  const _EixoFicha({required this.nivel, required this.faixa, this.justificativa = ''});
  factory _EixoFicha.fromJson(Map<String, dynamic> json) => _$EixoFichaFromJson(json);

@override final  int nivel;
@override final  String faixa;
@override@JsonKey() final  String justificativa;

/// Create a copy of EixoFicha
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EixoFichaCopyWith<_EixoFicha> get copyWith => __$EixoFichaCopyWithImpl<_EixoFicha>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EixoFichaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EixoFicha&&(identical(other.nivel, nivel) || other.nivel == nivel)&&(identical(other.faixa, faixa) || other.faixa == faixa)&&(identical(other.justificativa, justificativa) || other.justificativa == justificativa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,nivel,faixa,justificativa);
}

@override
String toString() {
    return 'EixoFicha(nivel: $nivel, faixa: $faixa, justificativa: $justificativa)';
}


}

/// @nodoc
abstract mixin class _$EixoFichaCopyWith<$Res> implements $EixoFichaCopyWith<$Res> {
  factory _$EixoFichaCopyWith(_EixoFicha value, $Res Function(_EixoFicha) _then) = __$EixoFichaCopyWithImpl;
@override @useResult
$Res call({
 int nivel, String faixa, String justificativa
});




}
/// @nodoc
class __$EixoFichaCopyWithImpl<$Res>
    implements _$EixoFichaCopyWith<$Res> {
  __$EixoFichaCopyWithImpl(this._self, this._then);

  final _EixoFicha _self;
  final $Res Function(_EixoFicha) _then;

/// Create a copy of EixoFicha
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nivel = null,Object? faixa = null,Object? justificativa = null,}) {
  return _then(_EixoFicha(
nivel: null == nivel ? _self.nivel : nivel // ignore: cast_nullable_to_non_nullable
as int,faixa: null == faixa ? _self.faixa : faixa // ignore: cast_nullable_to_non_nullable
as String,justificativa: null == justificativa ? _self.justificativa : justificativa // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Evidencia {

 String get eixo; String get parafrase; String? get trechoLiteral; String? get fonte; String? get localizacao;
/// Create a copy of Evidencia
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EvidenciaCopyWith<Evidencia> get copyWith => _$EvidenciaCopyWithImpl<Evidencia>(this as Evidencia, _$identity);

  /// Serializes this Evidencia to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Evidencia;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Evidencia&&(identical(other.eixo, _this.eixo) || other.eixo == _this.eixo)&&(identical(other.parafrase, _this.parafrase) || other.parafrase == _this.parafrase)&&(identical(other.trechoLiteral, _this.trechoLiteral) || other.trechoLiteral == _this.trechoLiteral)&&(identical(other.fonte, _this.fonte) || other.fonte == _this.fonte)&&(identical(other.localizacao, _this.localizacao) || other.localizacao == _this.localizacao));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Evidencia;
  return Object.hash(runtimeType,_this.eixo,_this.parafrase,_this.trechoLiteral,_this.fonte,_this.localizacao);
}

@override
String toString() {
  final _this = this as Evidencia;
  return 'Evidencia(eixo: ${_this.eixo}, parafrase: ${_this.parafrase}, trechoLiteral: ${_this.trechoLiteral}, fonte: ${_this.fonte}, localizacao: ${_this.localizacao})';
}


}

/// @nodoc
abstract mixin class $EvidenciaCopyWith<$Res>  {
  factory $EvidenciaCopyWith(Evidencia value, $Res Function(Evidencia) _then) = _$EvidenciaCopyWithImpl;
@useResult
$Res call({
 String eixo, String parafrase, String? trechoLiteral, String? fonte, String? localizacao
});




}
/// @nodoc
class _$EvidenciaCopyWithImpl<$Res>
    implements $EvidenciaCopyWith<$Res> {
  _$EvidenciaCopyWithImpl(this._self, this._then);

  final Evidencia _self;
  final $Res Function(Evidencia) _then;

/// Create a copy of Evidencia
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? eixo = null,Object? parafrase = null,Object? trechoLiteral = freezed,Object? fonte = freezed,Object? localizacao = freezed,}) {
  return _then(Evidencia(
eixo: null == eixo ? _self.eixo : eixo // ignore: cast_nullable_to_non_nullable
as String,parafrase: null == parafrase ? _self.parafrase : parafrase // ignore: cast_nullable_to_non_nullable
as String,trechoLiteral: freezed == trechoLiteral ? _self.trechoLiteral : trechoLiteral // ignore: cast_nullable_to_non_nullable
as String?,fonte: freezed == fonte ? _self.fonte : fonte // ignore: cast_nullable_to_non_nullable
as String?,localizacao: freezed == localizacao ? _self.localizacao : localizacao // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Evidencia].
extension EvidenciaPatterns on Evidencia {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Evidencia value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Evidencia() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Evidencia value)  $default,){
final _that = this;
switch (_that) {
case _Evidencia():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Evidencia value)?  $default,){
final _that = this;
switch (_that) {
case _Evidencia() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String eixo,  String parafrase,  String? trechoLiteral,  String? fonte,  String? localizacao)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Evidencia() when $default != null:
return $default(_that.eixo,_that.parafrase,_that.trechoLiteral,_that.fonte,_that.localizacao);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String eixo,  String parafrase,  String? trechoLiteral,  String? fonte,  String? localizacao)  $default,) {final _that = this;
switch (_that) {
case _Evidencia():
return $default(_that.eixo,_that.parafrase,_that.trechoLiteral,_that.fonte,_that.localizacao);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String eixo,  String parafrase,  String? trechoLiteral,  String? fonte,  String? localizacao)?  $default,) {final _that = this;
switch (_that) {
case _Evidencia() when $default != null:
return $default(_that.eixo,_that.parafrase,_that.trechoLiteral,_that.fonte,_that.localizacao);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Evidencia implements Evidencia {
  const _Evidencia({required this.eixo, this.parafrase = '', this.trechoLiteral, this.fonte, this.localizacao});
  factory _Evidencia.fromJson(Map<String, dynamic> json) => _$EvidenciaFromJson(json);

@override final  String eixo;
@override@JsonKey() final  String parafrase;
@override final  String? trechoLiteral;
@override final  String? fonte;
@override final  String? localizacao;

/// Create a copy of Evidencia
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EvidenciaCopyWith<_Evidencia> get copyWith => __$EvidenciaCopyWithImpl<_Evidencia>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EvidenciaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Evidencia&&(identical(other.eixo, eixo) || other.eixo == eixo)&&(identical(other.parafrase, parafrase) || other.parafrase == parafrase)&&(identical(other.trechoLiteral, trechoLiteral) || other.trechoLiteral == trechoLiteral)&&(identical(other.fonte, fonte) || other.fonte == fonte)&&(identical(other.localizacao, localizacao) || other.localizacao == localizacao));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,eixo,parafrase,trechoLiteral,fonte,localizacao);
}

@override
String toString() {
    return 'Evidencia(eixo: $eixo, parafrase: $parafrase, trechoLiteral: $trechoLiteral, fonte: $fonte, localizacao: $localizacao)';
}


}

/// @nodoc
abstract mixin class _$EvidenciaCopyWith<$Res> implements $EvidenciaCopyWith<$Res> {
  factory _$EvidenciaCopyWith(_Evidencia value, $Res Function(_Evidencia) _then) = __$EvidenciaCopyWithImpl;
@override @useResult
$Res call({
 String eixo, String parafrase, String? trechoLiteral, String? fonte, String? localizacao
});




}
/// @nodoc
class __$EvidenciaCopyWithImpl<$Res>
    implements _$EvidenciaCopyWith<$Res> {
  __$EvidenciaCopyWithImpl(this._self, this._then);

  final _Evidencia _self;
  final $Res Function(_Evidencia) _then;

/// Create a copy of Evidencia
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eixo = null,Object? parafrase = null,Object? trechoLiteral = freezed,Object? fonte = freezed,Object? localizacao = freezed,}) {
  return _then(_Evidencia(
eixo: null == eixo ? _self.eixo : eixo // ignore: cast_nullable_to_non_nullable
as String,parafrase: null == parafrase ? _self.parafrase : parafrase // ignore: cast_nullable_to_non_nullable
as String,trechoLiteral: freezed == trechoLiteral ? _self.trechoLiteral : trechoLiteral // ignore: cast_nullable_to_non_nullable
as String?,fonte: freezed == fonte ? _self.fonte : fonte // ignore: cast_nullable_to_non_nullable
as String?,localizacao: freezed == localizacao ? _self.localizacao : localizacao // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CamadaB {

 List<String> get flags; Map<String, String> get justificativas;
/// Create a copy of CamadaB
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CamadaBCopyWith<CamadaB> get copyWith => _$CamadaBCopyWithImpl<CamadaB>(this as CamadaB, _$identity);

  /// Serializes this CamadaB to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CamadaB;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CamadaB&&const DeepCollectionEquality().equals(other.flags, _this.flags)&&const DeepCollectionEquality().equals(other.justificativas, _this.justificativas));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CamadaB;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.flags),const DeepCollectionEquality().hash(_this.justificativas));
}

@override
String toString() {
  final _this = this as CamadaB;
  return 'CamadaB(flags: ${_this.flags}, justificativas: ${_this.justificativas})';
}


}

/// @nodoc
abstract mixin class $CamadaBCopyWith<$Res>  {
  factory $CamadaBCopyWith(CamadaB value, $Res Function(CamadaB) _then) = _$CamadaBCopyWithImpl;
@useResult
$Res call({
 List<String> flags, Map<String, String> justificativas
});




}
/// @nodoc
class _$CamadaBCopyWithImpl<$Res>
    implements $CamadaBCopyWith<$Res> {
  _$CamadaBCopyWithImpl(this._self, this._then);

  final CamadaB _self;
  final $Res Function(CamadaB) _then;

/// Create a copy of CamadaB
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? flags = null,Object? justificativas = null,}) {
  return _then(CamadaB(
flags: null == flags ? _self.flags : flags // ignore: cast_nullable_to_non_nullable
as List<String>,justificativas: null == justificativas ? _self.justificativas : justificativas // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CamadaB].
extension CamadaBPatterns on CamadaB {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CamadaB value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CamadaB() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CamadaB value)  $default,){
final _that = this;
switch (_that) {
case _CamadaB():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CamadaB value)?  $default,){
final _that = this;
switch (_that) {
case _CamadaB() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> flags,  Map<String, String> justificativas)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CamadaB() when $default != null:
return $default(_that.flags,_that.justificativas);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> flags,  Map<String, String> justificativas)  $default,) {final _that = this;
switch (_that) {
case _CamadaB():
return $default(_that.flags,_that.justificativas);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> flags,  Map<String, String> justificativas)?  $default,) {final _that = this;
switch (_that) {
case _CamadaB() when $default != null:
return $default(_that.flags,_that.justificativas);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CamadaB implements CamadaB {
  const _CamadaB({ List<String> flags = const <String>[],  Map<String, String> justificativas = const <String, String>{}}): _flags = flags,_justificativas = justificativas;
  factory _CamadaB.fromJson(Map<String, dynamic> json) => _$CamadaBFromJson(json);

 final  List<String> _flags;
@override@JsonKey() List<String> get flags {
  if (_flags is EqualUnmodifiableListView) return _flags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_flags);
}

 final  Map<String, String> _justificativas;
@override@JsonKey() Map<String, String> get justificativas {
  if (_justificativas is EqualUnmodifiableMapView) return _justificativas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_justificativas);
}


/// Create a copy of CamadaB
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CamadaBCopyWith<_CamadaB> get copyWith => __$CamadaBCopyWithImpl<_CamadaB>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CamadaBToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CamadaB&&const DeepCollectionEquality().equals(other.flags, _flags)&&const DeepCollectionEquality().equals(other.justificativas, _justificativas));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_flags),const DeepCollectionEquality().hash(_justificativas));
}

@override
String toString() {
    return 'CamadaB(flags: $flags, justificativas: $justificativas)';
}


}

/// @nodoc
abstract mixin class _$CamadaBCopyWith<$Res> implements $CamadaBCopyWith<$Res> {
  factory _$CamadaBCopyWith(_CamadaB value, $Res Function(_CamadaB) _then) = __$CamadaBCopyWithImpl;
@override @useResult
$Res call({
 List<String> flags, Map<String, String> justificativas
});




}
/// @nodoc
class __$CamadaBCopyWithImpl<$Res>
    implements _$CamadaBCopyWith<$Res> {
  __$CamadaBCopyWithImpl(this._self, this._then);

  final _CamadaB _self;
  final $Res Function(_CamadaB) _then;

/// Create a copy of CamadaB
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flags = null,Object? justificativas = null,}) {
  return _then(_CamadaB(
flags: null == flags ? _self._flags : flags // ignore: cast_nullable_to_non_nullable
as List<String>,justificativas: null == justificativas ? _self._justificativas : justificativas // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}


/// @nodoc
mixin _$ValorFormativo {

 String get nivel; List<String> get marcadores; String get justificativa;
/// Create a copy of ValorFormativo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValorFormativoCopyWith<ValorFormativo> get copyWith => _$ValorFormativoCopyWithImpl<ValorFormativo>(this as ValorFormativo, _$identity);

  /// Serializes this ValorFormativo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ValorFormativo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValorFormativo&&(identical(other.nivel, _this.nivel) || other.nivel == _this.nivel)&&const DeepCollectionEquality().equals(other.marcadores, _this.marcadores)&&(identical(other.justificativa, _this.justificativa) || other.justificativa == _this.justificativa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ValorFormativo;
  return Object.hash(runtimeType,_this.nivel,const DeepCollectionEquality().hash(_this.marcadores),_this.justificativa);
}

@override
String toString() {
  final _this = this as ValorFormativo;
  return 'ValorFormativo(nivel: ${_this.nivel}, marcadores: ${_this.marcadores}, justificativa: ${_this.justificativa})';
}


}

/// @nodoc
abstract mixin class $ValorFormativoCopyWith<$Res>  {
  factory $ValorFormativoCopyWith(ValorFormativo value, $Res Function(ValorFormativo) _then) = _$ValorFormativoCopyWithImpl;
@useResult
$Res call({
 String nivel, List<String> marcadores, String justificativa
});




}
/// @nodoc
class _$ValorFormativoCopyWithImpl<$Res>
    implements $ValorFormativoCopyWith<$Res> {
  _$ValorFormativoCopyWithImpl(this._self, this._then);

  final ValorFormativo _self;
  final $Res Function(ValorFormativo) _then;

/// Create a copy of ValorFormativo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nivel = null,Object? marcadores = null,Object? justificativa = null,}) {
  return _then(ValorFormativo(
nivel: null == nivel ? _self.nivel : nivel // ignore: cast_nullable_to_non_nullable
as String,marcadores: null == marcadores ? _self.marcadores : marcadores // ignore: cast_nullable_to_non_nullable
as List<String>,justificativa: null == justificativa ? _self.justificativa : justificativa // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ValorFormativo].
extension ValorFormativoPatterns on ValorFormativo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ValorFormativo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ValorFormativo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ValorFormativo value)  $default,){
final _that = this;
switch (_that) {
case _ValorFormativo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ValorFormativo value)?  $default,){
final _that = this;
switch (_that) {
case _ValorFormativo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String nivel,  List<String> marcadores,  String justificativa)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ValorFormativo() when $default != null:
return $default(_that.nivel,_that.marcadores,_that.justificativa);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String nivel,  List<String> marcadores,  String justificativa)  $default,) {final _that = this;
switch (_that) {
case _ValorFormativo():
return $default(_that.nivel,_that.marcadores,_that.justificativa);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String nivel,  List<String> marcadores,  String justificativa)?  $default,) {final _that = this;
switch (_that) {
case _ValorFormativo() when $default != null:
return $default(_that.nivel,_that.marcadores,_that.justificativa);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ValorFormativo implements ValorFormativo {
  const _ValorFormativo({required this.nivel,  List<String> marcadores = const <String>[], this.justificativa = ''}): _marcadores = marcadores;
  factory _ValorFormativo.fromJson(Map<String, dynamic> json) => _$ValorFormativoFromJson(json);

@override final  String nivel;
 final  List<String> _marcadores;
@override@JsonKey() List<String> get marcadores {
  if (_marcadores is EqualUnmodifiableListView) return _marcadores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_marcadores);
}

@override@JsonKey() final  String justificativa;

/// Create a copy of ValorFormativo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ValorFormativoCopyWith<_ValorFormativo> get copyWith => __$ValorFormativoCopyWithImpl<_ValorFormativo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ValorFormativoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ValorFormativo&&(identical(other.nivel, nivel) || other.nivel == nivel)&&const DeepCollectionEquality().equals(other.marcadores, _marcadores)&&(identical(other.justificativa, justificativa) || other.justificativa == justificativa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,nivel,const DeepCollectionEquality().hash(_marcadores),justificativa);
}

@override
String toString() {
    return 'ValorFormativo(nivel: $nivel, marcadores: $marcadores, justificativa: $justificativa)';
}


}

/// @nodoc
abstract mixin class _$ValorFormativoCopyWith<$Res> implements $ValorFormativoCopyWith<$Res> {
  factory _$ValorFormativoCopyWith(_ValorFormativo value, $Res Function(_ValorFormativo) _then) = __$ValorFormativoCopyWithImpl;
@override @useResult
$Res call({
 String nivel, List<String> marcadores, String justificativa
});




}
/// @nodoc
class __$ValorFormativoCopyWithImpl<$Res>
    implements _$ValorFormativoCopyWith<$Res> {
  __$ValorFormativoCopyWithImpl(this._self, this._then);

  final _ValorFormativo _self;
  final $Res Function(_ValorFormativo) _then;

/// Create a copy of ValorFormativo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nivel = null,Object? marcadores = null,Object? justificativa = null,}) {
  return _then(_ValorFormativo(
nivel: null == nivel ? _self.nivel : nivel // ignore: cast_nullable_to_non_nullable
as String,marcadores: null == marcadores ? _self._marcadores : marcadores // ignore: cast_nullable_to_non_nullable
as List<String>,justificativa: null == justificativa ? _self.justificativa : justificativa // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CamadaC {

 int get vocabulario; int get estruturaNarrativa; int get densidadeTematica; int? get extensao; int get nivelLeitura; String get rotuloNivelLeitura; List<String> get exigenciaRepertorio; ValorFormativo get valorFormativo;
/// Create a copy of CamadaC
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CamadaCCopyWith<CamadaC> get copyWith => _$CamadaCCopyWithImpl<CamadaC>(this as CamadaC, _$identity);

  /// Serializes this CamadaC to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CamadaC;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CamadaC&&(identical(other.vocabulario, _this.vocabulario) || other.vocabulario == _this.vocabulario)&&(identical(other.estruturaNarrativa, _this.estruturaNarrativa) || other.estruturaNarrativa == _this.estruturaNarrativa)&&(identical(other.densidadeTematica, _this.densidadeTematica) || other.densidadeTematica == _this.densidadeTematica)&&(identical(other.extensao, _this.extensao) || other.extensao == _this.extensao)&&(identical(other.nivelLeitura, _this.nivelLeitura) || other.nivelLeitura == _this.nivelLeitura)&&(identical(other.rotuloNivelLeitura, _this.rotuloNivelLeitura) || other.rotuloNivelLeitura == _this.rotuloNivelLeitura)&&const DeepCollectionEquality().equals(other.exigenciaRepertorio, _this.exigenciaRepertorio)&&(identical(other.valorFormativo, _this.valorFormativo) || other.valorFormativo == _this.valorFormativo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CamadaC;
  return Object.hash(runtimeType,_this.vocabulario,_this.estruturaNarrativa,_this.densidadeTematica,_this.extensao,_this.nivelLeitura,_this.rotuloNivelLeitura,const DeepCollectionEquality().hash(_this.exigenciaRepertorio),_this.valorFormativo);
}

@override
String toString() {
  final _this = this as CamadaC;
  return 'CamadaC(vocabulario: ${_this.vocabulario}, estruturaNarrativa: ${_this.estruturaNarrativa}, densidadeTematica: ${_this.densidadeTematica}, extensao: ${_this.extensao}, nivelLeitura: ${_this.nivelLeitura}, rotuloNivelLeitura: ${_this.rotuloNivelLeitura}, exigenciaRepertorio: ${_this.exigenciaRepertorio}, valorFormativo: ${_this.valorFormativo})';
}


}

/// @nodoc
abstract mixin class $CamadaCCopyWith<$Res>  {
  factory $CamadaCCopyWith(CamadaC value, $Res Function(CamadaC) _then) = _$CamadaCCopyWithImpl;
@useResult
$Res call({
 int vocabulario, int estruturaNarrativa, int densidadeTematica, int? extensao, int nivelLeitura, String rotuloNivelLeitura, List<String> exigenciaRepertorio, ValorFormativo valorFormativo
});


$ValorFormativoCopyWith<$Res> get valorFormativo;

}
/// @nodoc
class _$CamadaCCopyWithImpl<$Res>
    implements $CamadaCCopyWith<$Res> {
  _$CamadaCCopyWithImpl(this._self, this._then);

  final CamadaC _self;
  final $Res Function(CamadaC) _then;

/// Create a copy of CamadaC
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? vocabulario = null,Object? estruturaNarrativa = null,Object? densidadeTematica = null,Object? extensao = freezed,Object? nivelLeitura = null,Object? rotuloNivelLeitura = null,Object? exigenciaRepertorio = null,Object? valorFormativo = null,}) {
  return _then(CamadaC(
vocabulario: null == vocabulario ? _self.vocabulario : vocabulario // ignore: cast_nullable_to_non_nullable
as int,estruturaNarrativa: null == estruturaNarrativa ? _self.estruturaNarrativa : estruturaNarrativa // ignore: cast_nullable_to_non_nullable
as int,densidadeTematica: null == densidadeTematica ? _self.densidadeTematica : densidadeTematica // ignore: cast_nullable_to_non_nullable
as int,extensao: freezed == extensao ? _self.extensao : extensao // ignore: cast_nullable_to_non_nullable
as int?,nivelLeitura: null == nivelLeitura ? _self.nivelLeitura : nivelLeitura // ignore: cast_nullable_to_non_nullable
as int,rotuloNivelLeitura: null == rotuloNivelLeitura ? _self.rotuloNivelLeitura : rotuloNivelLeitura // ignore: cast_nullable_to_non_nullable
as String,exigenciaRepertorio: null == exigenciaRepertorio ? _self.exigenciaRepertorio : exigenciaRepertorio // ignore: cast_nullable_to_non_nullable
as List<String>,valorFormativo: null == valorFormativo ? _self.valorFormativo : valorFormativo // ignore: cast_nullable_to_non_nullable
as ValorFormativo,
  ));
}
/// Create a copy of CamadaC
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ValorFormativoCopyWith<$Res> get valorFormativo {
  
  return $ValorFormativoCopyWith<$Res>(_self.valorFormativo, (value) {
    return _then(_self.copyWith(valorFormativo: value));
  });
}
}


/// Adds pattern-matching-related methods to [CamadaC].
extension CamadaCPatterns on CamadaC {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CamadaC value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CamadaC() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CamadaC value)  $default,){
final _that = this;
switch (_that) {
case _CamadaC():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CamadaC value)?  $default,){
final _that = this;
switch (_that) {
case _CamadaC() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int vocabulario,  int estruturaNarrativa,  int densidadeTematica,  int? extensao,  int nivelLeitura,  String rotuloNivelLeitura,  List<String> exigenciaRepertorio,  ValorFormativo valorFormativo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CamadaC() when $default != null:
return $default(_that.vocabulario,_that.estruturaNarrativa,_that.densidadeTematica,_that.extensao,_that.nivelLeitura,_that.rotuloNivelLeitura,_that.exigenciaRepertorio,_that.valorFormativo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int vocabulario,  int estruturaNarrativa,  int densidadeTematica,  int? extensao,  int nivelLeitura,  String rotuloNivelLeitura,  List<String> exigenciaRepertorio,  ValorFormativo valorFormativo)  $default,) {final _that = this;
switch (_that) {
case _CamadaC():
return $default(_that.vocabulario,_that.estruturaNarrativa,_that.densidadeTematica,_that.extensao,_that.nivelLeitura,_that.rotuloNivelLeitura,_that.exigenciaRepertorio,_that.valorFormativo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int vocabulario,  int estruturaNarrativa,  int densidadeTematica,  int? extensao,  int nivelLeitura,  String rotuloNivelLeitura,  List<String> exigenciaRepertorio,  ValorFormativo valorFormativo)?  $default,) {final _that = this;
switch (_that) {
case _CamadaC() when $default != null:
return $default(_that.vocabulario,_that.estruturaNarrativa,_that.densidadeTematica,_that.extensao,_that.nivelLeitura,_that.rotuloNivelLeitura,_that.exigenciaRepertorio,_that.valorFormativo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CamadaC implements CamadaC {
  const _CamadaC({required this.vocabulario, required this.estruturaNarrativa, required this.densidadeTematica, this.extensao, required this.nivelLeitura, required this.rotuloNivelLeitura,  List<String> exigenciaRepertorio = const <String>[], required this.valorFormativo}): _exigenciaRepertorio = exigenciaRepertorio;
  factory _CamadaC.fromJson(Map<String, dynamic> json) => _$CamadaCFromJson(json);

@override final  int vocabulario;
@override final  int estruturaNarrativa;
@override final  int densidadeTematica;
@override final  int? extensao;
@override final  int nivelLeitura;
@override final  String rotuloNivelLeitura;
 final  List<String> _exigenciaRepertorio;
@override@JsonKey() List<String> get exigenciaRepertorio {
  if (_exigenciaRepertorio is EqualUnmodifiableListView) return _exigenciaRepertorio;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exigenciaRepertorio);
}

@override final  ValorFormativo valorFormativo;

/// Create a copy of CamadaC
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CamadaCCopyWith<_CamadaC> get copyWith => __$CamadaCCopyWithImpl<_CamadaC>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CamadaCToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CamadaC&&(identical(other.vocabulario, vocabulario) || other.vocabulario == vocabulario)&&(identical(other.estruturaNarrativa, estruturaNarrativa) || other.estruturaNarrativa == estruturaNarrativa)&&(identical(other.densidadeTematica, densidadeTematica) || other.densidadeTematica == densidadeTematica)&&(identical(other.extensao, extensao) || other.extensao == extensao)&&(identical(other.nivelLeitura, nivelLeitura) || other.nivelLeitura == nivelLeitura)&&(identical(other.rotuloNivelLeitura, rotuloNivelLeitura) || other.rotuloNivelLeitura == rotuloNivelLeitura)&&const DeepCollectionEquality().equals(other.exigenciaRepertorio, _exigenciaRepertorio)&&(identical(other.valorFormativo, valorFormativo) || other.valorFormativo == valorFormativo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,vocabulario,estruturaNarrativa,densidadeTematica,extensao,nivelLeitura,rotuloNivelLeitura,const DeepCollectionEquality().hash(_exigenciaRepertorio),valorFormativo);
}

@override
String toString() {
    return 'CamadaC(vocabulario: $vocabulario, estruturaNarrativa: $estruturaNarrativa, densidadeTematica: $densidadeTematica, extensao: $extensao, nivelLeitura: $nivelLeitura, rotuloNivelLeitura: $rotuloNivelLeitura, exigenciaRepertorio: $exigenciaRepertorio, valorFormativo: $valorFormativo)';
}


}

/// @nodoc
abstract mixin class _$CamadaCCopyWith<$Res> implements $CamadaCCopyWith<$Res> {
  factory _$CamadaCCopyWith(_CamadaC value, $Res Function(_CamadaC) _then) = __$CamadaCCopyWithImpl;
@override @useResult
$Res call({
 int vocabulario, int estruturaNarrativa, int densidadeTematica, int? extensao, int nivelLeitura, String rotuloNivelLeitura, List<String> exigenciaRepertorio, ValorFormativo valorFormativo
});


@override $ValorFormativoCopyWith<$Res> get valorFormativo;

}
/// @nodoc
class __$CamadaCCopyWithImpl<$Res>
    implements _$CamadaCCopyWith<$Res> {
  __$CamadaCCopyWithImpl(this._self, this._then);

  final _CamadaC _self;
  final $Res Function(_CamadaC) _then;

/// Create a copy of CamadaC
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? vocabulario = null,Object? estruturaNarrativa = null,Object? densidadeTematica = null,Object? extensao = freezed,Object? nivelLeitura = null,Object? rotuloNivelLeitura = null,Object? exigenciaRepertorio = null,Object? valorFormativo = null,}) {
  return _then(_CamadaC(
vocabulario: null == vocabulario ? _self.vocabulario : vocabulario // ignore: cast_nullable_to_non_nullable
as int,estruturaNarrativa: null == estruturaNarrativa ? _self.estruturaNarrativa : estruturaNarrativa // ignore: cast_nullable_to_non_nullable
as int,densidadeTematica: null == densidadeTematica ? _self.densidadeTematica : densidadeTematica // ignore: cast_nullable_to_non_nullable
as int,extensao: freezed == extensao ? _self.extensao : extensao // ignore: cast_nullable_to_non_nullable
as int?,nivelLeitura: null == nivelLeitura ? _self.nivelLeitura : nivelLeitura // ignore: cast_nullable_to_non_nullable
as int,rotuloNivelLeitura: null == rotuloNivelLeitura ? _self.rotuloNivelLeitura : rotuloNivelLeitura // ignore: cast_nullable_to_non_nullable
as String,exigenciaRepertorio: null == exigenciaRepertorio ? _self._exigenciaRepertorio : exigenciaRepertorio // ignore: cast_nullable_to_non_nullable
as List<String>,valorFormativo: null == valorFormativo ? _self.valorFormativo : valorFormativo // ignore: cast_nullable_to_non_nullable
as ValorFormativo,
  ));
}

/// Create a copy of CamadaC
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ValorFormativoCopyWith<$Res> get valorFormativo {
  
  return $ValorFormativoCopyWith<$Res>(_self.valorFormativo, (value) {
    return _then(_self.copyWith(valorFormativo: value));
  });
}
}


/// @nodoc
mixin _$FonteProcedencia {

 String get tipo; String? get url;
/// Create a copy of FonteProcedencia
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FonteProcedenciaCopyWith<FonteProcedencia> get copyWith => _$FonteProcedenciaCopyWithImpl<FonteProcedencia>(this as FonteProcedencia, _$identity);

  /// Serializes this FonteProcedencia to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FonteProcedencia;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FonteProcedencia&&(identical(other.tipo, _this.tipo) || other.tipo == _this.tipo)&&(identical(other.url, _this.url) || other.url == _this.url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FonteProcedencia;
  return Object.hash(runtimeType,_this.tipo,_this.url);
}

@override
String toString() {
  final _this = this as FonteProcedencia;
  return 'FonteProcedencia(tipo: ${_this.tipo}, url: ${_this.url})';
}


}

/// @nodoc
abstract mixin class $FonteProcedenciaCopyWith<$Res>  {
  factory $FonteProcedenciaCopyWith(FonteProcedencia value, $Res Function(FonteProcedencia) _then) = _$FonteProcedenciaCopyWithImpl;
@useResult
$Res call({
 String tipo, String? url
});




}
/// @nodoc
class _$FonteProcedenciaCopyWithImpl<$Res>
    implements $FonteProcedenciaCopyWith<$Res> {
  _$FonteProcedenciaCopyWithImpl(this._self, this._then);

  final FonteProcedencia _self;
  final $Res Function(FonteProcedencia) _then;

/// Create a copy of FonteProcedencia
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tipo = null,Object? url = freezed,}) {
  return _then(FonteProcedencia(
tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FonteProcedencia].
extension FonteProcedenciaPatterns on FonteProcedencia {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FonteProcedencia value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FonteProcedencia() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FonteProcedencia value)  $default,){
final _that = this;
switch (_that) {
case _FonteProcedencia():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FonteProcedencia value)?  $default,){
final _that = this;
switch (_that) {
case _FonteProcedencia() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tipo,  String? url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FonteProcedencia() when $default != null:
return $default(_that.tipo,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tipo,  String? url)  $default,) {final _that = this;
switch (_that) {
case _FonteProcedencia():
return $default(_that.tipo,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tipo,  String? url)?  $default,) {final _that = this;
switch (_that) {
case _FonteProcedencia() when $default != null:
return $default(_that.tipo,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FonteProcedencia implements FonteProcedencia {
  const _FonteProcedencia({required this.tipo, this.url});
  factory _FonteProcedencia.fromJson(Map<String, dynamic> json) => _$FonteProcedenciaFromJson(json);

@override final  String tipo;
@override final  String? url;

/// Create a copy of FonteProcedencia
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FonteProcedenciaCopyWith<_FonteProcedencia> get copyWith => __$FonteProcedenciaCopyWithImpl<_FonteProcedencia>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FonteProcedenciaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FonteProcedencia&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,tipo,url);
}

@override
String toString() {
    return 'FonteProcedencia(tipo: $tipo, url: $url)';
}


}

/// @nodoc
abstract mixin class _$FonteProcedenciaCopyWith<$Res> implements $FonteProcedenciaCopyWith<$Res> {
  factory _$FonteProcedenciaCopyWith(_FonteProcedencia value, $Res Function(_FonteProcedencia) _then) = __$FonteProcedenciaCopyWithImpl;
@override @useResult
$Res call({
 String tipo, String? url
});




}
/// @nodoc
class __$FonteProcedenciaCopyWithImpl<$Res>
    implements _$FonteProcedenciaCopyWith<$Res> {
  __$FonteProcedenciaCopyWithImpl(this._self, this._then);

  final _FonteProcedencia _self;
  final $Res Function(_FonteProcedencia) _then;

/// Create a copy of FonteProcedencia
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tipo = null,Object? url = freezed,}) {
  return _then(_FonteProcedencia(
tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Procedencia {

 String get fonteDaAnalise; double get confianca; String? get modelo; List<FonteProcedencia> get fontes; bool get revisadaPorHumano; String? get revisadaEm;
/// Create a copy of Procedencia
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProcedenciaCopyWith<Procedencia> get copyWith => _$ProcedenciaCopyWithImpl<Procedencia>(this as Procedencia, _$identity);

  /// Serializes this Procedencia to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Procedencia;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Procedencia&&(identical(other.fonteDaAnalise, _this.fonteDaAnalise) || other.fonteDaAnalise == _this.fonteDaAnalise)&&(identical(other.confianca, _this.confianca) || other.confianca == _this.confianca)&&(identical(other.modelo, _this.modelo) || other.modelo == _this.modelo)&&const DeepCollectionEquality().equals(other.fontes, _this.fontes)&&(identical(other.revisadaPorHumano, _this.revisadaPorHumano) || other.revisadaPorHumano == _this.revisadaPorHumano)&&(identical(other.revisadaEm, _this.revisadaEm) || other.revisadaEm == _this.revisadaEm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Procedencia;
  return Object.hash(runtimeType,_this.fonteDaAnalise,_this.confianca,_this.modelo,const DeepCollectionEquality().hash(_this.fontes),_this.revisadaPorHumano,_this.revisadaEm);
}

@override
String toString() {
  final _this = this as Procedencia;
  return 'Procedencia(fonteDaAnalise: ${_this.fonteDaAnalise}, confianca: ${_this.confianca}, modelo: ${_this.modelo}, fontes: ${_this.fontes}, revisadaPorHumano: ${_this.revisadaPorHumano}, revisadaEm: ${_this.revisadaEm})';
}


}

/// @nodoc
abstract mixin class $ProcedenciaCopyWith<$Res>  {
  factory $ProcedenciaCopyWith(Procedencia value, $Res Function(Procedencia) _then) = _$ProcedenciaCopyWithImpl;
@useResult
$Res call({
 String fonteDaAnalise, double confianca, String? modelo, List<FonteProcedencia> fontes, bool revisadaPorHumano, String? revisadaEm
});




}
/// @nodoc
class _$ProcedenciaCopyWithImpl<$Res>
    implements $ProcedenciaCopyWith<$Res> {
  _$ProcedenciaCopyWithImpl(this._self, this._then);

  final Procedencia _self;
  final $Res Function(Procedencia) _then;

/// Create a copy of Procedencia
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fonteDaAnalise = null,Object? confianca = null,Object? modelo = freezed,Object? fontes = null,Object? revisadaPorHumano = null,Object? revisadaEm = freezed,}) {
  return _then(Procedencia(
fonteDaAnalise: null == fonteDaAnalise ? _self.fonteDaAnalise : fonteDaAnalise // ignore: cast_nullable_to_non_nullable
as String,confianca: null == confianca ? _self.confianca : confianca // ignore: cast_nullable_to_non_nullable
as double,modelo: freezed == modelo ? _self.modelo : modelo // ignore: cast_nullable_to_non_nullable
as String?,fontes: null == fontes ? _self.fontes : fontes // ignore: cast_nullable_to_non_nullable
as List<FonteProcedencia>,revisadaPorHumano: null == revisadaPorHumano ? _self.revisadaPorHumano : revisadaPorHumano // ignore: cast_nullable_to_non_nullable
as bool,revisadaEm: freezed == revisadaEm ? _self.revisadaEm : revisadaEm // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Procedencia].
extension ProcedenciaPatterns on Procedencia {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Procedencia value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Procedencia() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Procedencia value)  $default,){
final _that = this;
switch (_that) {
case _Procedencia():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Procedencia value)?  $default,){
final _that = this;
switch (_that) {
case _Procedencia() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fonteDaAnalise,  double confianca,  String? modelo,  List<FonteProcedencia> fontes,  bool revisadaPorHumano,  String? revisadaEm)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Procedencia() when $default != null:
return $default(_that.fonteDaAnalise,_that.confianca,_that.modelo,_that.fontes,_that.revisadaPorHumano,_that.revisadaEm);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fonteDaAnalise,  double confianca,  String? modelo,  List<FonteProcedencia> fontes,  bool revisadaPorHumano,  String? revisadaEm)  $default,) {final _that = this;
switch (_that) {
case _Procedencia():
return $default(_that.fonteDaAnalise,_that.confianca,_that.modelo,_that.fontes,_that.revisadaPorHumano,_that.revisadaEm);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fonteDaAnalise,  double confianca,  String? modelo,  List<FonteProcedencia> fontes,  bool revisadaPorHumano,  String? revisadaEm)?  $default,) {final _that = this;
switch (_that) {
case _Procedencia() when $default != null:
return $default(_that.fonteDaAnalise,_that.confianca,_that.modelo,_that.fontes,_that.revisadaPorHumano,_that.revisadaEm);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Procedencia implements Procedencia {
  const _Procedencia({required this.fonteDaAnalise, required this.confianca, this.modelo,  List<FonteProcedencia> fontes = const <FonteProcedencia>[], this.revisadaPorHumano = false, this.revisadaEm}): _fontes = fontes;
  factory _Procedencia.fromJson(Map<String, dynamic> json) => _$ProcedenciaFromJson(json);

@override final  String fonteDaAnalise;
@override final  double confianca;
@override final  String? modelo;
 final  List<FonteProcedencia> _fontes;
@override@JsonKey() List<FonteProcedencia> get fontes {
  if (_fontes is EqualUnmodifiableListView) return _fontes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fontes);
}

@override@JsonKey() final  bool revisadaPorHumano;
@override final  String? revisadaEm;

/// Create a copy of Procedencia
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProcedenciaCopyWith<_Procedencia> get copyWith => __$ProcedenciaCopyWithImpl<_Procedencia>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProcedenciaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Procedencia&&(identical(other.fonteDaAnalise, fonteDaAnalise) || other.fonteDaAnalise == fonteDaAnalise)&&(identical(other.confianca, confianca) || other.confianca == confianca)&&(identical(other.modelo, modelo) || other.modelo == modelo)&&const DeepCollectionEquality().equals(other.fontes, _fontes)&&(identical(other.revisadaPorHumano, revisadaPorHumano) || other.revisadaPorHumano == revisadaPorHumano)&&(identical(other.revisadaEm, revisadaEm) || other.revisadaEm == revisadaEm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,fonteDaAnalise,confianca,modelo,const DeepCollectionEquality().hash(_fontes),revisadaPorHumano,revisadaEm);
}

@override
String toString() {
    return 'Procedencia(fonteDaAnalise: $fonteDaAnalise, confianca: $confianca, modelo: $modelo, fontes: $fontes, revisadaPorHumano: $revisadaPorHumano, revisadaEm: $revisadaEm)';
}


}

/// @nodoc
abstract mixin class _$ProcedenciaCopyWith<$Res> implements $ProcedenciaCopyWith<$Res> {
  factory _$ProcedenciaCopyWith(_Procedencia value, $Res Function(_Procedencia) _then) = __$ProcedenciaCopyWithImpl;
@override @useResult
$Res call({
 String fonteDaAnalise, double confianca, String? modelo, List<FonteProcedencia> fontes, bool revisadaPorHumano, String? revisadaEm
});




}
/// @nodoc
class __$ProcedenciaCopyWithImpl<$Res>
    implements _$ProcedenciaCopyWith<$Res> {
  __$ProcedenciaCopyWithImpl(this._self, this._then);

  final _Procedencia _self;
  final $Res Function(_Procedencia) _then;

/// Create a copy of Procedencia
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fonteDaAnalise = null,Object? confianca = null,Object? modelo = freezed,Object? fontes = null,Object? revisadaPorHumano = null,Object? revisadaEm = freezed,}) {
  return _then(_Procedencia(
fonteDaAnalise: null == fonteDaAnalise ? _self.fonteDaAnalise : fonteDaAnalise // ignore: cast_nullable_to_non_nullable
as String,confianca: null == confianca ? _self.confianca : confianca // ignore: cast_nullable_to_non_nullable
as double,modelo: freezed == modelo ? _self.modelo : modelo // ignore: cast_nullable_to_non_nullable
as String?,fontes: null == fontes ? _self._fontes : fontes // ignore: cast_nullable_to_non_nullable
as List<FonteProcedencia>,revisadaPorHumano: null == revisadaPorHumano ? _self.revisadaPorHumano : revisadaPorHumano // ignore: cast_nullable_to_non_nullable
as bool,revisadaEm: freezed == revisadaEm ? _self.revisadaEm : revisadaEm // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Ficha {

 String get obraId; String get versaoRubrica; int get versaoFicha; String get status; String get faixaFinal; String get faixaBase; bool get agravanteAcumuloAplicado; String get eixoDeterminante; String get recomendacaoContextual; String get textoRecomendacao; Map<String, EixoFicha> get camadaA; List<Evidencia> get evidencias; CamadaB get camadaB; CamadaC get camadaC; Procedencia get procedencia; String get atualizadaEm; String? get slug; String? get avisoA5; String? get avisoEstimativa; String? get avisoIndependencia;
/// Create a copy of Ficha
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FichaCopyWith<Ficha> get copyWith => _$FichaCopyWithImpl<Ficha>(this as Ficha, _$identity);

  /// Serializes this Ficha to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Ficha;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Ficha&&(identical(other.obraId, _this.obraId) || other.obraId == _this.obraId)&&(identical(other.versaoRubrica, _this.versaoRubrica) || other.versaoRubrica == _this.versaoRubrica)&&(identical(other.versaoFicha, _this.versaoFicha) || other.versaoFicha == _this.versaoFicha)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.faixaFinal, _this.faixaFinal) || other.faixaFinal == _this.faixaFinal)&&(identical(other.faixaBase, _this.faixaBase) || other.faixaBase == _this.faixaBase)&&(identical(other.agravanteAcumuloAplicado, _this.agravanteAcumuloAplicado) || other.agravanteAcumuloAplicado == _this.agravanteAcumuloAplicado)&&(identical(other.eixoDeterminante, _this.eixoDeterminante) || other.eixoDeterminante == _this.eixoDeterminante)&&(identical(other.recomendacaoContextual, _this.recomendacaoContextual) || other.recomendacaoContextual == _this.recomendacaoContextual)&&(identical(other.textoRecomendacao, _this.textoRecomendacao) || other.textoRecomendacao == _this.textoRecomendacao)&&const DeepCollectionEquality().equals(other.camadaA, _this.camadaA)&&const DeepCollectionEquality().equals(other.evidencias, _this.evidencias)&&(identical(other.camadaB, _this.camadaB) || other.camadaB == _this.camadaB)&&(identical(other.camadaC, _this.camadaC) || other.camadaC == _this.camadaC)&&(identical(other.procedencia, _this.procedencia) || other.procedencia == _this.procedencia)&&(identical(other.atualizadaEm, _this.atualizadaEm) || other.atualizadaEm == _this.atualizadaEm)&&(identical(other.slug, _this.slug) || other.slug == _this.slug)&&(identical(other.avisoA5, _this.avisoA5) || other.avisoA5 == _this.avisoA5)&&(identical(other.avisoEstimativa, _this.avisoEstimativa) || other.avisoEstimativa == _this.avisoEstimativa)&&(identical(other.avisoIndependencia, _this.avisoIndependencia) || other.avisoIndependencia == _this.avisoIndependencia));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Ficha;
  return Object.hashAll([runtimeType,_this.obraId,_this.versaoRubrica,_this.versaoFicha,_this.status,_this.faixaFinal,_this.faixaBase,_this.agravanteAcumuloAplicado,_this.eixoDeterminante,_this.recomendacaoContextual,_this.textoRecomendacao,const DeepCollectionEquality().hash(_this.camadaA),const DeepCollectionEquality().hash(_this.evidencias),_this.camadaB,_this.camadaC,_this.procedencia,_this.atualizadaEm,_this.slug,_this.avisoA5,_this.avisoEstimativa,_this.avisoIndependencia]);
}

@override
String toString() {
  final _this = this as Ficha;
  return 'Ficha(obraId: ${_this.obraId}, versaoRubrica: ${_this.versaoRubrica}, versaoFicha: ${_this.versaoFicha}, status: ${_this.status}, faixaFinal: ${_this.faixaFinal}, faixaBase: ${_this.faixaBase}, agravanteAcumuloAplicado: ${_this.agravanteAcumuloAplicado}, eixoDeterminante: ${_this.eixoDeterminante}, recomendacaoContextual: ${_this.recomendacaoContextual}, textoRecomendacao: ${_this.textoRecomendacao}, camadaA: ${_this.camadaA}, evidencias: ${_this.evidencias}, camadaB: ${_this.camadaB}, camadaC: ${_this.camadaC}, procedencia: ${_this.procedencia}, atualizadaEm: ${_this.atualizadaEm}, slug: ${_this.slug}, avisoA5: ${_this.avisoA5}, avisoEstimativa: ${_this.avisoEstimativa}, avisoIndependencia: ${_this.avisoIndependencia})';
}


}

/// @nodoc
abstract mixin class $FichaCopyWith<$Res>  {
  factory $FichaCopyWith(Ficha value, $Res Function(Ficha) _then) = _$FichaCopyWithImpl;
@useResult
$Res call({
 String obraId, String versaoRubrica, int versaoFicha, String status, String faixaFinal, String faixaBase, bool agravanteAcumuloAplicado, String eixoDeterminante, String recomendacaoContextual, String textoRecomendacao, Map<String, EixoFicha> camadaA, List<Evidencia> evidencias, CamadaB camadaB, CamadaC camadaC, Procedencia procedencia, String atualizadaEm, String? slug, String? avisoA5, String? avisoEstimativa, String? avisoIndependencia
});


$CamadaBCopyWith<$Res> get camadaB;$CamadaCCopyWith<$Res> get camadaC;$ProcedenciaCopyWith<$Res> get procedencia;

}
/// @nodoc
class _$FichaCopyWithImpl<$Res>
    implements $FichaCopyWith<$Res> {
  _$FichaCopyWithImpl(this._self, this._then);

  final Ficha _self;
  final $Res Function(Ficha) _then;

/// Create a copy of Ficha
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? obraId = null,Object? versaoRubrica = null,Object? versaoFicha = null,Object? status = null,Object? faixaFinal = null,Object? faixaBase = null,Object? agravanteAcumuloAplicado = null,Object? eixoDeterminante = null,Object? recomendacaoContextual = null,Object? textoRecomendacao = null,Object? camadaA = null,Object? evidencias = null,Object? camadaB = null,Object? camadaC = null,Object? procedencia = null,Object? atualizadaEm = null,Object? slug = freezed,Object? avisoA5 = freezed,Object? avisoEstimativa = freezed,Object? avisoIndependencia = freezed,}) {
  return _then(Ficha(
obraId: null == obraId ? _self.obraId : obraId // ignore: cast_nullable_to_non_nullable
as String,versaoRubrica: null == versaoRubrica ? _self.versaoRubrica : versaoRubrica // ignore: cast_nullable_to_non_nullable
as String,versaoFicha: null == versaoFicha ? _self.versaoFicha : versaoFicha // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,faixaFinal: null == faixaFinal ? _self.faixaFinal : faixaFinal // ignore: cast_nullable_to_non_nullable
as String,faixaBase: null == faixaBase ? _self.faixaBase : faixaBase // ignore: cast_nullable_to_non_nullable
as String,agravanteAcumuloAplicado: null == agravanteAcumuloAplicado ? _self.agravanteAcumuloAplicado : agravanteAcumuloAplicado // ignore: cast_nullable_to_non_nullable
as bool,eixoDeterminante: null == eixoDeterminante ? _self.eixoDeterminante : eixoDeterminante // ignore: cast_nullable_to_non_nullable
as String,recomendacaoContextual: null == recomendacaoContextual ? _self.recomendacaoContextual : recomendacaoContextual // ignore: cast_nullable_to_non_nullable
as String,textoRecomendacao: null == textoRecomendacao ? _self.textoRecomendacao : textoRecomendacao // ignore: cast_nullable_to_non_nullable
as String,camadaA: null == camadaA ? _self.camadaA : camadaA // ignore: cast_nullable_to_non_nullable
as Map<String, EixoFicha>,evidencias: null == evidencias ? _self.evidencias : evidencias // ignore: cast_nullable_to_non_nullable
as List<Evidencia>,camadaB: null == camadaB ? _self.camadaB : camadaB // ignore: cast_nullable_to_non_nullable
as CamadaB,camadaC: null == camadaC ? _self.camadaC : camadaC // ignore: cast_nullable_to_non_nullable
as CamadaC,procedencia: null == procedencia ? _self.procedencia : procedencia // ignore: cast_nullable_to_non_nullable
as Procedencia,atualizadaEm: null == atualizadaEm ? _self.atualizadaEm : atualizadaEm // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,avisoA5: freezed == avisoA5 ? _self.avisoA5 : avisoA5 // ignore: cast_nullable_to_non_nullable
as String?,avisoEstimativa: freezed == avisoEstimativa ? _self.avisoEstimativa : avisoEstimativa // ignore: cast_nullable_to_non_nullable
as String?,avisoIndependencia: freezed == avisoIndependencia ? _self.avisoIndependencia : avisoIndependencia // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Ficha
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CamadaBCopyWith<$Res> get camadaB {
  
  return $CamadaBCopyWith<$Res>(_self.camadaB, (value) {
    return _then(_self.copyWith(camadaB: value));
  });
}/// Create a copy of Ficha
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CamadaCCopyWith<$Res> get camadaC {
  
  return $CamadaCCopyWith<$Res>(_self.camadaC, (value) {
    return _then(_self.copyWith(camadaC: value));
  });
}/// Create a copy of Ficha
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProcedenciaCopyWith<$Res> get procedencia {
  
  return $ProcedenciaCopyWith<$Res>(_self.procedencia, (value) {
    return _then(_self.copyWith(procedencia: value));
  });
}
}


/// Adds pattern-matching-related methods to [Ficha].
extension FichaPatterns on Ficha {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Ficha value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Ficha() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Ficha value)  $default,){
final _that = this;
switch (_that) {
case _Ficha():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Ficha value)?  $default,){
final _that = this;
switch (_that) {
case _Ficha() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String obraId,  String versaoRubrica,  int versaoFicha,  String status,  String faixaFinal,  String faixaBase,  bool agravanteAcumuloAplicado,  String eixoDeterminante,  String recomendacaoContextual,  String textoRecomendacao,  Map<String, EixoFicha> camadaA,  List<Evidencia> evidencias,  CamadaB camadaB,  CamadaC camadaC,  Procedencia procedencia,  String atualizadaEm,  String? slug,  String? avisoA5,  String? avisoEstimativa,  String? avisoIndependencia)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Ficha() when $default != null:
return $default(_that.obraId,_that.versaoRubrica,_that.versaoFicha,_that.status,_that.faixaFinal,_that.faixaBase,_that.agravanteAcumuloAplicado,_that.eixoDeterminante,_that.recomendacaoContextual,_that.textoRecomendacao,_that.camadaA,_that.evidencias,_that.camadaB,_that.camadaC,_that.procedencia,_that.atualizadaEm,_that.slug,_that.avisoA5,_that.avisoEstimativa,_that.avisoIndependencia);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String obraId,  String versaoRubrica,  int versaoFicha,  String status,  String faixaFinal,  String faixaBase,  bool agravanteAcumuloAplicado,  String eixoDeterminante,  String recomendacaoContextual,  String textoRecomendacao,  Map<String, EixoFicha> camadaA,  List<Evidencia> evidencias,  CamadaB camadaB,  CamadaC camadaC,  Procedencia procedencia,  String atualizadaEm,  String? slug,  String? avisoA5,  String? avisoEstimativa,  String? avisoIndependencia)  $default,) {final _that = this;
switch (_that) {
case _Ficha():
return $default(_that.obraId,_that.versaoRubrica,_that.versaoFicha,_that.status,_that.faixaFinal,_that.faixaBase,_that.agravanteAcumuloAplicado,_that.eixoDeterminante,_that.recomendacaoContextual,_that.textoRecomendacao,_that.camadaA,_that.evidencias,_that.camadaB,_that.camadaC,_that.procedencia,_that.atualizadaEm,_that.slug,_that.avisoA5,_that.avisoEstimativa,_that.avisoIndependencia);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String obraId,  String versaoRubrica,  int versaoFicha,  String status,  String faixaFinal,  String faixaBase,  bool agravanteAcumuloAplicado,  String eixoDeterminante,  String recomendacaoContextual,  String textoRecomendacao,  Map<String, EixoFicha> camadaA,  List<Evidencia> evidencias,  CamadaB camadaB,  CamadaC camadaC,  Procedencia procedencia,  String atualizadaEm,  String? slug,  String? avisoA5,  String? avisoEstimativa,  String? avisoIndependencia)?  $default,) {final _that = this;
switch (_that) {
case _Ficha() when $default != null:
return $default(_that.obraId,_that.versaoRubrica,_that.versaoFicha,_that.status,_that.faixaFinal,_that.faixaBase,_that.agravanteAcumuloAplicado,_that.eixoDeterminante,_that.recomendacaoContextual,_that.textoRecomendacao,_that.camadaA,_that.evidencias,_that.camadaB,_that.camadaC,_that.procedencia,_that.atualizadaEm,_that.slug,_that.avisoA5,_that.avisoEstimativa,_that.avisoIndependencia);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Ficha extends Ficha {
  const _Ficha({required this.obraId, required this.versaoRubrica, required this.versaoFicha, required this.status, required this.faixaFinal, required this.faixaBase, required this.agravanteAcumuloAplicado, required this.eixoDeterminante, required this.recomendacaoContextual, required this.textoRecomendacao, required  Map<String, EixoFicha> camadaA,  List<Evidencia> evidencias = const <Evidencia>[], required this.camadaB, required this.camadaC, required this.procedencia, required this.atualizadaEm, this.slug, this.avisoA5, this.avisoEstimativa, this.avisoIndependencia}): _camadaA = camadaA,_evidencias = evidencias,super._();
  factory _Ficha.fromJson(Map<String, dynamic> json) => _$FichaFromJson(json);

@override final  String obraId;
@override final  String versaoRubrica;
@override final  int versaoFicha;
@override final  String status;
@override final  String faixaFinal;
@override final  String faixaBase;
@override final  bool agravanteAcumuloAplicado;
@override final  String eixoDeterminante;
@override final  String recomendacaoContextual;
@override final  String textoRecomendacao;
 final  Map<String, EixoFicha> _camadaA;
@override Map<String, EixoFicha> get camadaA {
  if (_camadaA is EqualUnmodifiableMapView) return _camadaA;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_camadaA);
}

 final  List<Evidencia> _evidencias;
@override@JsonKey() List<Evidencia> get evidencias {
  if (_evidencias is EqualUnmodifiableListView) return _evidencias;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_evidencias);
}

@override final  CamadaB camadaB;
@override final  CamadaC camadaC;
@override final  Procedencia procedencia;
@override final  String atualizadaEm;
@override final  String? slug;
@override final  String? avisoA5;
@override final  String? avisoEstimativa;
@override final  String? avisoIndependencia;

/// Create a copy of Ficha
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FichaCopyWith<_Ficha> get copyWith => __$FichaCopyWithImpl<_Ficha>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FichaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Ficha&&(identical(other.obraId, obraId) || other.obraId == obraId)&&(identical(other.versaoRubrica, versaoRubrica) || other.versaoRubrica == versaoRubrica)&&(identical(other.versaoFicha, versaoFicha) || other.versaoFicha == versaoFicha)&&(identical(other.status, status) || other.status == status)&&(identical(other.faixaFinal, faixaFinal) || other.faixaFinal == faixaFinal)&&(identical(other.faixaBase, faixaBase) || other.faixaBase == faixaBase)&&(identical(other.agravanteAcumuloAplicado, agravanteAcumuloAplicado) || other.agravanteAcumuloAplicado == agravanteAcumuloAplicado)&&(identical(other.eixoDeterminante, eixoDeterminante) || other.eixoDeterminante == eixoDeterminante)&&(identical(other.recomendacaoContextual, recomendacaoContextual) || other.recomendacaoContextual == recomendacaoContextual)&&(identical(other.textoRecomendacao, textoRecomendacao) || other.textoRecomendacao == textoRecomendacao)&&const DeepCollectionEquality().equals(other.camadaA, _camadaA)&&const DeepCollectionEquality().equals(other.evidencias, _evidencias)&&(identical(other.camadaB, camadaB) || other.camadaB == camadaB)&&(identical(other.camadaC, camadaC) || other.camadaC == camadaC)&&(identical(other.procedencia, procedencia) || other.procedencia == procedencia)&&(identical(other.atualizadaEm, atualizadaEm) || other.atualizadaEm == atualizadaEm)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.avisoA5, avisoA5) || other.avisoA5 == avisoA5)&&(identical(other.avisoEstimativa, avisoEstimativa) || other.avisoEstimativa == avisoEstimativa)&&(identical(other.avisoIndependencia, avisoIndependencia) || other.avisoIndependencia == avisoIndependencia));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,obraId,versaoRubrica,versaoFicha,status,faixaFinal,faixaBase,agravanteAcumuloAplicado,eixoDeterminante,recomendacaoContextual,textoRecomendacao,const DeepCollectionEquality().hash(_camadaA),const DeepCollectionEquality().hash(_evidencias),camadaB,camadaC,procedencia,atualizadaEm,slug,avisoA5,avisoEstimativa,avisoIndependencia]);
}

@override
String toString() {
    return 'Ficha(obraId: $obraId, versaoRubrica: $versaoRubrica, versaoFicha: $versaoFicha, status: $status, faixaFinal: $faixaFinal, faixaBase: $faixaBase, agravanteAcumuloAplicado: $agravanteAcumuloAplicado, eixoDeterminante: $eixoDeterminante, recomendacaoContextual: $recomendacaoContextual, textoRecomendacao: $textoRecomendacao, camadaA: $camadaA, evidencias: $evidencias, camadaB: $camadaB, camadaC: $camadaC, procedencia: $procedencia, atualizadaEm: $atualizadaEm, slug: $slug, avisoA5: $avisoA5, avisoEstimativa: $avisoEstimativa, avisoIndependencia: $avisoIndependencia)';
}


}

/// @nodoc
abstract mixin class _$FichaCopyWith<$Res> implements $FichaCopyWith<$Res> {
  factory _$FichaCopyWith(_Ficha value, $Res Function(_Ficha) _then) = __$FichaCopyWithImpl;
@override @useResult
$Res call({
 String obraId, String versaoRubrica, int versaoFicha, String status, String faixaFinal, String faixaBase, bool agravanteAcumuloAplicado, String eixoDeterminante, String recomendacaoContextual, String textoRecomendacao, Map<String, EixoFicha> camadaA, List<Evidencia> evidencias, CamadaB camadaB, CamadaC camadaC, Procedencia procedencia, String atualizadaEm, String? slug, String? avisoA5, String? avisoEstimativa, String? avisoIndependencia
});


@override $CamadaBCopyWith<$Res> get camadaB;@override $CamadaCCopyWith<$Res> get camadaC;@override $ProcedenciaCopyWith<$Res> get procedencia;

}
/// @nodoc
class __$FichaCopyWithImpl<$Res>
    implements _$FichaCopyWith<$Res> {
  __$FichaCopyWithImpl(this._self, this._then);

  final _Ficha _self;
  final $Res Function(_Ficha) _then;

/// Create a copy of Ficha
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? obraId = null,Object? versaoRubrica = null,Object? versaoFicha = null,Object? status = null,Object? faixaFinal = null,Object? faixaBase = null,Object? agravanteAcumuloAplicado = null,Object? eixoDeterminante = null,Object? recomendacaoContextual = null,Object? textoRecomendacao = null,Object? camadaA = null,Object? evidencias = null,Object? camadaB = null,Object? camadaC = null,Object? procedencia = null,Object? atualizadaEm = null,Object? slug = freezed,Object? avisoA5 = freezed,Object? avisoEstimativa = freezed,Object? avisoIndependencia = freezed,}) {
  return _then(_Ficha(
obraId: null == obraId ? _self.obraId : obraId // ignore: cast_nullable_to_non_nullable
as String,versaoRubrica: null == versaoRubrica ? _self.versaoRubrica : versaoRubrica // ignore: cast_nullable_to_non_nullable
as String,versaoFicha: null == versaoFicha ? _self.versaoFicha : versaoFicha // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,faixaFinal: null == faixaFinal ? _self.faixaFinal : faixaFinal // ignore: cast_nullable_to_non_nullable
as String,faixaBase: null == faixaBase ? _self.faixaBase : faixaBase // ignore: cast_nullable_to_non_nullable
as String,agravanteAcumuloAplicado: null == agravanteAcumuloAplicado ? _self.agravanteAcumuloAplicado : agravanteAcumuloAplicado // ignore: cast_nullable_to_non_nullable
as bool,eixoDeterminante: null == eixoDeterminante ? _self.eixoDeterminante : eixoDeterminante // ignore: cast_nullable_to_non_nullable
as String,recomendacaoContextual: null == recomendacaoContextual ? _self.recomendacaoContextual : recomendacaoContextual // ignore: cast_nullable_to_non_nullable
as String,textoRecomendacao: null == textoRecomendacao ? _self.textoRecomendacao : textoRecomendacao // ignore: cast_nullable_to_non_nullable
as String,camadaA: null == camadaA ? _self._camadaA : camadaA // ignore: cast_nullable_to_non_nullable
as Map<String, EixoFicha>,evidencias: null == evidencias ? _self._evidencias : evidencias // ignore: cast_nullable_to_non_nullable
as List<Evidencia>,camadaB: null == camadaB ? _self.camadaB : camadaB // ignore: cast_nullable_to_non_nullable
as CamadaB,camadaC: null == camadaC ? _self.camadaC : camadaC // ignore: cast_nullable_to_non_nullable
as CamadaC,procedencia: null == procedencia ? _self.procedencia : procedencia // ignore: cast_nullable_to_non_nullable
as Procedencia,atualizadaEm: null == atualizadaEm ? _self.atualizadaEm : atualizadaEm // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,avisoA5: freezed == avisoA5 ? _self.avisoA5 : avisoA5 // ignore: cast_nullable_to_non_nullable
as String?,avisoEstimativa: freezed == avisoEstimativa ? _self.avisoEstimativa : avisoEstimativa // ignore: cast_nullable_to_non_nullable
as String?,avisoIndependencia: freezed == avisoIndependencia ? _self.avisoIndependencia : avisoIndependencia // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Ficha
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CamadaBCopyWith<$Res> get camadaB {
  
  return $CamadaBCopyWith<$Res>(_self.camadaB, (value) {
    return _then(_self.copyWith(camadaB: value));
  });
}/// Create a copy of Ficha
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CamadaCCopyWith<$Res> get camadaC {
  
  return $CamadaCCopyWith<$Res>(_self.camadaC, (value) {
    return _then(_self.copyWith(camadaC: value));
  });
}/// Create a copy of Ficha
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProcedenciaCopyWith<$Res> get procedencia {
  
  return $ProcedenciaCopyWith<$Res>(_self.procedencia, (value) {
    return _then(_self.copyWith(procedencia: value));
  });
}
}


/// @nodoc
mixin _$ResumoFicha {

 String get obraId; String get slug; String get status; String? get faixaFinal; String? get recomendacaoContextual; String? get textoRecomendacao; String? get fonteDaAnalise; String? get textoFonteAnalise; double? get confianca; bool get revisadaPorHumano;
/// Create a copy of ResumoFicha
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResumoFichaCopyWith<ResumoFicha> get copyWith => _$ResumoFichaCopyWithImpl<ResumoFicha>(this as ResumoFicha, _$identity);

  /// Serializes this ResumoFicha to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ResumoFicha;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResumoFicha&&(identical(other.obraId, _this.obraId) || other.obraId == _this.obraId)&&(identical(other.slug, _this.slug) || other.slug == _this.slug)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.faixaFinal, _this.faixaFinal) || other.faixaFinal == _this.faixaFinal)&&(identical(other.recomendacaoContextual, _this.recomendacaoContextual) || other.recomendacaoContextual == _this.recomendacaoContextual)&&(identical(other.textoRecomendacao, _this.textoRecomendacao) || other.textoRecomendacao == _this.textoRecomendacao)&&(identical(other.fonteDaAnalise, _this.fonteDaAnalise) || other.fonteDaAnalise == _this.fonteDaAnalise)&&(identical(other.textoFonteAnalise, _this.textoFonteAnalise) || other.textoFonteAnalise == _this.textoFonteAnalise)&&(identical(other.confianca, _this.confianca) || other.confianca == _this.confianca)&&(identical(other.revisadaPorHumano, _this.revisadaPorHumano) || other.revisadaPorHumano == _this.revisadaPorHumano));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ResumoFicha;
  return Object.hash(runtimeType,_this.obraId,_this.slug,_this.status,_this.faixaFinal,_this.recomendacaoContextual,_this.textoRecomendacao,_this.fonteDaAnalise,_this.textoFonteAnalise,_this.confianca,_this.revisadaPorHumano);
}

@override
String toString() {
  final _this = this as ResumoFicha;
  return 'ResumoFicha(obraId: ${_this.obraId}, slug: ${_this.slug}, status: ${_this.status}, faixaFinal: ${_this.faixaFinal}, recomendacaoContextual: ${_this.recomendacaoContextual}, textoRecomendacao: ${_this.textoRecomendacao}, fonteDaAnalise: ${_this.fonteDaAnalise}, textoFonteAnalise: ${_this.textoFonteAnalise}, confianca: ${_this.confianca}, revisadaPorHumano: ${_this.revisadaPorHumano})';
}


}

/// @nodoc
abstract mixin class $ResumoFichaCopyWith<$Res>  {
  factory $ResumoFichaCopyWith(ResumoFicha value, $Res Function(ResumoFicha) _then) = _$ResumoFichaCopyWithImpl;
@useResult
$Res call({
 String obraId, String slug, String status, String? faixaFinal, String? recomendacaoContextual, String? textoRecomendacao, String? fonteDaAnalise, String? textoFonteAnalise, double? confianca, bool revisadaPorHumano
});




}
/// @nodoc
class _$ResumoFichaCopyWithImpl<$Res>
    implements $ResumoFichaCopyWith<$Res> {
  _$ResumoFichaCopyWithImpl(this._self, this._then);

  final ResumoFicha _self;
  final $Res Function(ResumoFicha) _then;

/// Create a copy of ResumoFicha
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? obraId = null,Object? slug = null,Object? status = null,Object? faixaFinal = freezed,Object? recomendacaoContextual = freezed,Object? textoRecomendacao = freezed,Object? fonteDaAnalise = freezed,Object? textoFonteAnalise = freezed,Object? confianca = freezed,Object? revisadaPorHumano = null,}) {
  return _then(ResumoFicha(
obraId: null == obraId ? _self.obraId : obraId // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,faixaFinal: freezed == faixaFinal ? _self.faixaFinal : faixaFinal // ignore: cast_nullable_to_non_nullable
as String?,recomendacaoContextual: freezed == recomendacaoContextual ? _self.recomendacaoContextual : recomendacaoContextual // ignore: cast_nullable_to_non_nullable
as String?,textoRecomendacao: freezed == textoRecomendacao ? _self.textoRecomendacao : textoRecomendacao // ignore: cast_nullable_to_non_nullable
as String?,fonteDaAnalise: freezed == fonteDaAnalise ? _self.fonteDaAnalise : fonteDaAnalise // ignore: cast_nullable_to_non_nullable
as String?,textoFonteAnalise: freezed == textoFonteAnalise ? _self.textoFonteAnalise : textoFonteAnalise // ignore: cast_nullable_to_non_nullable
as String?,confianca: freezed == confianca ? _self.confianca : confianca // ignore: cast_nullable_to_non_nullable
as double?,revisadaPorHumano: null == revisadaPorHumano ? _self.revisadaPorHumano : revisadaPorHumano // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ResumoFicha].
extension ResumoFichaPatterns on ResumoFicha {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResumoFicha value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResumoFicha() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResumoFicha value)  $default,){
final _that = this;
switch (_that) {
case _ResumoFicha():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResumoFicha value)?  $default,){
final _that = this;
switch (_that) {
case _ResumoFicha() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String obraId,  String slug,  String status,  String? faixaFinal,  String? recomendacaoContextual,  String? textoRecomendacao,  String? fonteDaAnalise,  String? textoFonteAnalise,  double? confianca,  bool revisadaPorHumano)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResumoFicha() when $default != null:
return $default(_that.obraId,_that.slug,_that.status,_that.faixaFinal,_that.recomendacaoContextual,_that.textoRecomendacao,_that.fonteDaAnalise,_that.textoFonteAnalise,_that.confianca,_that.revisadaPorHumano);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String obraId,  String slug,  String status,  String? faixaFinal,  String? recomendacaoContextual,  String? textoRecomendacao,  String? fonteDaAnalise,  String? textoFonteAnalise,  double? confianca,  bool revisadaPorHumano)  $default,) {final _that = this;
switch (_that) {
case _ResumoFicha():
return $default(_that.obraId,_that.slug,_that.status,_that.faixaFinal,_that.recomendacaoContextual,_that.textoRecomendacao,_that.fonteDaAnalise,_that.textoFonteAnalise,_that.confianca,_that.revisadaPorHumano);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String obraId,  String slug,  String status,  String? faixaFinal,  String? recomendacaoContextual,  String? textoRecomendacao,  String? fonteDaAnalise,  String? textoFonteAnalise,  double? confianca,  bool revisadaPorHumano)?  $default,) {final _that = this;
switch (_that) {
case _ResumoFicha() when $default != null:
return $default(_that.obraId,_that.slug,_that.status,_that.faixaFinal,_that.recomendacaoContextual,_that.textoRecomendacao,_that.fonteDaAnalise,_that.textoFonteAnalise,_that.confianca,_that.revisadaPorHumano);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResumoFicha implements ResumoFicha {
  const _ResumoFicha({required this.obraId, required this.slug, required this.status, this.faixaFinal, this.recomendacaoContextual, this.textoRecomendacao, this.fonteDaAnalise, this.textoFonteAnalise, this.confianca, this.revisadaPorHumano = false});
  factory _ResumoFicha.fromJson(Map<String, dynamic> json) => _$ResumoFichaFromJson(json);

@override final  String obraId;
@override final  String slug;
@override final  String status;
@override final  String? faixaFinal;
@override final  String? recomendacaoContextual;
@override final  String? textoRecomendacao;
@override final  String? fonteDaAnalise;
@override final  String? textoFonteAnalise;
@override final  double? confianca;
@override@JsonKey() final  bool revisadaPorHumano;

/// Create a copy of ResumoFicha
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResumoFichaCopyWith<_ResumoFicha> get copyWith => __$ResumoFichaCopyWithImpl<_ResumoFicha>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResumoFichaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResumoFicha&&(identical(other.obraId, obraId) || other.obraId == obraId)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.status, status) || other.status == status)&&(identical(other.faixaFinal, faixaFinal) || other.faixaFinal == faixaFinal)&&(identical(other.recomendacaoContextual, recomendacaoContextual) || other.recomendacaoContextual == recomendacaoContextual)&&(identical(other.textoRecomendacao, textoRecomendacao) || other.textoRecomendacao == textoRecomendacao)&&(identical(other.fonteDaAnalise, fonteDaAnalise) || other.fonteDaAnalise == fonteDaAnalise)&&(identical(other.textoFonteAnalise, textoFonteAnalise) || other.textoFonteAnalise == textoFonteAnalise)&&(identical(other.confianca, confianca) || other.confianca == confianca)&&(identical(other.revisadaPorHumano, revisadaPorHumano) || other.revisadaPorHumano == revisadaPorHumano));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,obraId,slug,status,faixaFinal,recomendacaoContextual,textoRecomendacao,fonteDaAnalise,textoFonteAnalise,confianca,revisadaPorHumano);
}

@override
String toString() {
    return 'ResumoFicha(obraId: $obraId, slug: $slug, status: $status, faixaFinal: $faixaFinal, recomendacaoContextual: $recomendacaoContextual, textoRecomendacao: $textoRecomendacao, fonteDaAnalise: $fonteDaAnalise, textoFonteAnalise: $textoFonteAnalise, confianca: $confianca, revisadaPorHumano: $revisadaPorHumano)';
}


}

/// @nodoc
abstract mixin class _$ResumoFichaCopyWith<$Res> implements $ResumoFichaCopyWith<$Res> {
  factory _$ResumoFichaCopyWith(_ResumoFicha value, $Res Function(_ResumoFicha) _then) = __$ResumoFichaCopyWithImpl;
@override @useResult
$Res call({
 String obraId, String slug, String status, String? faixaFinal, String? recomendacaoContextual, String? textoRecomendacao, String? fonteDaAnalise, String? textoFonteAnalise, double? confianca, bool revisadaPorHumano
});




}
/// @nodoc
class __$ResumoFichaCopyWithImpl<$Res>
    implements _$ResumoFichaCopyWith<$Res> {
  __$ResumoFichaCopyWithImpl(this._self, this._then);

  final _ResumoFicha _self;
  final $Res Function(_ResumoFicha) _then;

/// Create a copy of ResumoFicha
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? obraId = null,Object? slug = null,Object? status = null,Object? faixaFinal = freezed,Object? recomendacaoContextual = freezed,Object? textoRecomendacao = freezed,Object? fonteDaAnalise = freezed,Object? textoFonteAnalise = freezed,Object? confianca = freezed,Object? revisadaPorHumano = null,}) {
  return _then(_ResumoFicha(
obraId: null == obraId ? _self.obraId : obraId // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,faixaFinal: freezed == faixaFinal ? _self.faixaFinal : faixaFinal // ignore: cast_nullable_to_non_nullable
as String?,recomendacaoContextual: freezed == recomendacaoContextual ? _self.recomendacaoContextual : recomendacaoContextual // ignore: cast_nullable_to_non_nullable
as String?,textoRecomendacao: freezed == textoRecomendacao ? _self.textoRecomendacao : textoRecomendacao // ignore: cast_nullable_to_non_nullable
as String?,fonteDaAnalise: freezed == fonteDaAnalise ? _self.fonteDaAnalise : fonteDaAnalise // ignore: cast_nullable_to_non_nullable
as String?,textoFonteAnalise: freezed == textoFonteAnalise ? _self.textoFonteAnalise : textoFonteAnalise // ignore: cast_nullable_to_non_nullable
as String?,confianca: freezed == confianca ? _self.confianca : confianca // ignore: cast_nullable_to_non_nullable
as double?,revisadaPorHumano: null == revisadaPorHumano ? _self.revisadaPorHumano : revisadaPorHumano // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Uso {

 String get plano; String? get origem; String? get validaAte; String? get organizacaoId; int get consultasUsadas; int? get consultasLimite;
/// Create a copy of Uso
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UsoCopyWith<Uso> get copyWith => _$UsoCopyWithImpl<Uso>(this as Uso, _$identity);

  /// Serializes this Uso to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Uso;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Uso&&(identical(other.plano, _this.plano) || other.plano == _this.plano)&&(identical(other.origem, _this.origem) || other.origem == _this.origem)&&(identical(other.validaAte, _this.validaAte) || other.validaAte == _this.validaAte)&&(identical(other.organizacaoId, _this.organizacaoId) || other.organizacaoId == _this.organizacaoId)&&(identical(other.consultasUsadas, _this.consultasUsadas) || other.consultasUsadas == _this.consultasUsadas)&&(identical(other.consultasLimite, _this.consultasLimite) || other.consultasLimite == _this.consultasLimite));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Uso;
  return Object.hash(runtimeType,_this.plano,_this.origem,_this.validaAte,_this.organizacaoId,_this.consultasUsadas,_this.consultasLimite);
}

@override
String toString() {
  final _this = this as Uso;
  return 'Uso(plano: ${_this.plano}, origem: ${_this.origem}, validaAte: ${_this.validaAte}, organizacaoId: ${_this.organizacaoId}, consultasUsadas: ${_this.consultasUsadas}, consultasLimite: ${_this.consultasLimite})';
}


}

/// @nodoc
abstract mixin class $UsoCopyWith<$Res>  {
  factory $UsoCopyWith(Uso value, $Res Function(Uso) _then) = _$UsoCopyWithImpl;
@useResult
$Res call({
 String plano, String? origem, String? validaAte, String? organizacaoId, int consultasUsadas, int? consultasLimite
});




}
/// @nodoc
class _$UsoCopyWithImpl<$Res>
    implements $UsoCopyWith<$Res> {
  _$UsoCopyWithImpl(this._self, this._then);

  final Uso _self;
  final $Res Function(Uso) _then;

/// Create a copy of Uso
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? plano = null,Object? origem = freezed,Object? validaAte = freezed,Object? organizacaoId = freezed,Object? consultasUsadas = null,Object? consultasLimite = freezed,}) {
  return _then(Uso(
plano: null == plano ? _self.plano : plano // ignore: cast_nullable_to_non_nullable
as String,origem: freezed == origem ? _self.origem : origem // ignore: cast_nullable_to_non_nullable
as String?,validaAte: freezed == validaAte ? _self.validaAte : validaAte // ignore: cast_nullable_to_non_nullable
as String?,organizacaoId: freezed == organizacaoId ? _self.organizacaoId : organizacaoId // ignore: cast_nullable_to_non_nullable
as String?,consultasUsadas: null == consultasUsadas ? _self.consultasUsadas : consultasUsadas // ignore: cast_nullable_to_non_nullable
as int,consultasLimite: freezed == consultasLimite ? _self.consultasLimite : consultasLimite // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Uso].
extension UsoPatterns on Uso {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Uso value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Uso() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Uso value)  $default,){
final _that = this;
switch (_that) {
case _Uso():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Uso value)?  $default,){
final _that = this;
switch (_that) {
case _Uso() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String plano,  String? origem,  String? validaAte,  String? organizacaoId,  int consultasUsadas,  int? consultasLimite)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Uso() when $default != null:
return $default(_that.plano,_that.origem,_that.validaAte,_that.organizacaoId,_that.consultasUsadas,_that.consultasLimite);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String plano,  String? origem,  String? validaAte,  String? organizacaoId,  int consultasUsadas,  int? consultasLimite)  $default,) {final _that = this;
switch (_that) {
case _Uso():
return $default(_that.plano,_that.origem,_that.validaAte,_that.organizacaoId,_that.consultasUsadas,_that.consultasLimite);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String plano,  String? origem,  String? validaAte,  String? organizacaoId,  int consultasUsadas,  int? consultasLimite)?  $default,) {final _that = this;
switch (_that) {
case _Uso() when $default != null:
return $default(_that.plano,_that.origem,_that.validaAte,_that.organizacaoId,_that.consultasUsadas,_that.consultasLimite);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Uso implements Uso {
  const _Uso({this.plano = 'gratuito', this.origem, this.validaAte, this.organizacaoId, this.consultasUsadas = 0, this.consultasLimite});
  factory _Uso.fromJson(Map<String, dynamic> json) => _$UsoFromJson(json);

@override@JsonKey() final  String plano;
@override final  String? origem;
@override final  String? validaAte;
@override final  String? organizacaoId;
@override@JsonKey() final  int consultasUsadas;
@override final  int? consultasLimite;

/// Create a copy of Uso
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UsoCopyWith<_Uso> get copyWith => __$UsoCopyWithImpl<_Uso>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UsoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Uso&&(identical(other.plano, plano) || other.plano == plano)&&(identical(other.origem, origem) || other.origem == origem)&&(identical(other.validaAte, validaAte) || other.validaAte == validaAte)&&(identical(other.organizacaoId, organizacaoId) || other.organizacaoId == organizacaoId)&&(identical(other.consultasUsadas, consultasUsadas) || other.consultasUsadas == consultasUsadas)&&(identical(other.consultasLimite, consultasLimite) || other.consultasLimite == consultasLimite));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,plano,origem,validaAte,organizacaoId,consultasUsadas,consultasLimite);
}

@override
String toString() {
    return 'Uso(plano: $plano, origem: $origem, validaAte: $validaAte, organizacaoId: $organizacaoId, consultasUsadas: $consultasUsadas, consultasLimite: $consultasLimite)';
}


}

/// @nodoc
abstract mixin class _$UsoCopyWith<$Res> implements $UsoCopyWith<$Res> {
  factory _$UsoCopyWith(_Uso value, $Res Function(_Uso) _then) = __$UsoCopyWithImpl;
@override @useResult
$Res call({
 String plano, String? origem, String? validaAte, String? organizacaoId, int consultasUsadas, int? consultasLimite
});




}
/// @nodoc
class __$UsoCopyWithImpl<$Res>
    implements _$UsoCopyWith<$Res> {
  __$UsoCopyWithImpl(this._self, this._then);

  final _Uso _self;
  final $Res Function(_Uso) _then;

/// Create a copy of Uso
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? plano = null,Object? origem = freezed,Object? validaAte = freezed,Object? organizacaoId = freezed,Object? consultasUsadas = null,Object? consultasLimite = freezed,}) {
  return _then(_Uso(
plano: null == plano ? _self.plano : plano // ignore: cast_nullable_to_non_nullable
as String,origem: freezed == origem ? _self.origem : origem // ignore: cast_nullable_to_non_nullable
as String?,validaAte: freezed == validaAte ? _self.validaAte : validaAte // ignore: cast_nullable_to_non_nullable
as String?,organizacaoId: freezed == organizacaoId ? _self.organizacaoId : organizacaoId // ignore: cast_nullable_to_non_nullable
as String?,consultasUsadas: null == consultasUsadas ? _self.consultasUsadas : consultasUsadas // ignore: cast_nullable_to_non_nullable
as int,consultasLimite: freezed == consultasLimite ? _self.consultasLimite : consultasLimite // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$RespostaFicha {

 String get statusFicha; Ficha? get ficha; Uso? get uso;
/// Create a copy of RespostaFicha
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RespostaFichaCopyWith<RespostaFicha> get copyWith => _$RespostaFichaCopyWithImpl<RespostaFicha>(this as RespostaFicha, _$identity);

  /// Serializes this RespostaFicha to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RespostaFicha;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RespostaFicha&&(identical(other.statusFicha, _this.statusFicha) || other.statusFicha == _this.statusFicha)&&(identical(other.ficha, _this.ficha) || other.ficha == _this.ficha)&&(identical(other.uso, _this.uso) || other.uso == _this.uso));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RespostaFicha;
  return Object.hash(runtimeType,_this.statusFicha,_this.ficha,_this.uso);
}

@override
String toString() {
  final _this = this as RespostaFicha;
  return 'RespostaFicha(statusFicha: ${_this.statusFicha}, ficha: ${_this.ficha}, uso: ${_this.uso})';
}


}

/// @nodoc
abstract mixin class $RespostaFichaCopyWith<$Res>  {
  factory $RespostaFichaCopyWith(RespostaFicha value, $Res Function(RespostaFicha) _then) = _$RespostaFichaCopyWithImpl;
@useResult
$Res call({
 String statusFicha, Ficha? ficha, Uso? uso
});


$FichaCopyWith<$Res>? get ficha;$UsoCopyWith<$Res>? get uso;

}
/// @nodoc
class _$RespostaFichaCopyWithImpl<$Res>
    implements $RespostaFichaCopyWith<$Res> {
  _$RespostaFichaCopyWithImpl(this._self, this._then);

  final RespostaFicha _self;
  final $Res Function(RespostaFicha) _then;

/// Create a copy of RespostaFicha
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? statusFicha = null,Object? ficha = freezed,Object? uso = freezed,}) {
  return _then(RespostaFicha(
statusFicha: null == statusFicha ? _self.statusFicha : statusFicha // ignore: cast_nullable_to_non_nullable
as String,ficha: freezed == ficha ? _self.ficha : ficha // ignore: cast_nullable_to_non_nullable
as Ficha?,uso: freezed == uso ? _self.uso : uso // ignore: cast_nullable_to_non_nullable
as Uso?,
  ));
}
/// Create a copy of RespostaFicha
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FichaCopyWith<$Res>? get ficha {
    if (_self.ficha == null) {
    return null;
  }

  return $FichaCopyWith<$Res>(_self.ficha!, (value) {
    return _then(_self.copyWith(ficha: value));
  });
}/// Create a copy of RespostaFicha
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UsoCopyWith<$Res>? get uso {
    if (_self.uso == null) {
    return null;
  }

  return $UsoCopyWith<$Res>(_self.uso!, (value) {
    return _then(_self.copyWith(uso: value));
  });
}
}


/// Adds pattern-matching-related methods to [RespostaFicha].
extension RespostaFichaPatterns on RespostaFicha {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RespostaFicha value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RespostaFicha() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RespostaFicha value)  $default,){
final _that = this;
switch (_that) {
case _RespostaFicha():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RespostaFicha value)?  $default,){
final _that = this;
switch (_that) {
case _RespostaFicha() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String statusFicha,  Ficha? ficha,  Uso? uso)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RespostaFicha() when $default != null:
return $default(_that.statusFicha,_that.ficha,_that.uso);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String statusFicha,  Ficha? ficha,  Uso? uso)  $default,) {final _that = this;
switch (_that) {
case _RespostaFicha():
return $default(_that.statusFicha,_that.ficha,_that.uso);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String statusFicha,  Ficha? ficha,  Uso? uso)?  $default,) {final _that = this;
switch (_that) {
case _RespostaFicha() when $default != null:
return $default(_that.statusFicha,_that.ficha,_that.uso);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RespostaFicha implements RespostaFicha {
  const _RespostaFicha({required this.statusFicha, this.ficha, this.uso});
  factory _RespostaFicha.fromJson(Map<String, dynamic> json) => _$RespostaFichaFromJson(json);

@override final  String statusFicha;
@override final  Ficha? ficha;
@override final  Uso? uso;

/// Create a copy of RespostaFicha
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RespostaFichaCopyWith<_RespostaFicha> get copyWith => __$RespostaFichaCopyWithImpl<_RespostaFicha>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RespostaFichaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RespostaFicha&&(identical(other.statusFicha, statusFicha) || other.statusFicha == statusFicha)&&(identical(other.ficha, ficha) || other.ficha == ficha)&&(identical(other.uso, uso) || other.uso == uso));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,statusFicha,ficha,uso);
}

@override
String toString() {
    return 'RespostaFicha(statusFicha: $statusFicha, ficha: $ficha, uso: $uso)';
}


}

/// @nodoc
abstract mixin class _$RespostaFichaCopyWith<$Res> implements $RespostaFichaCopyWith<$Res> {
  factory _$RespostaFichaCopyWith(_RespostaFicha value, $Res Function(_RespostaFicha) _then) = __$RespostaFichaCopyWithImpl;
@override @useResult
$Res call({
 String statusFicha, Ficha? ficha, Uso? uso
});


@override $FichaCopyWith<$Res>? get ficha;@override $UsoCopyWith<$Res>? get uso;

}
/// @nodoc
class __$RespostaFichaCopyWithImpl<$Res>
    implements _$RespostaFichaCopyWith<$Res> {
  __$RespostaFichaCopyWithImpl(this._self, this._then);

  final _RespostaFicha _self;
  final $Res Function(_RespostaFicha) _then;

/// Create a copy of RespostaFicha
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? statusFicha = null,Object? ficha = freezed,Object? uso = freezed,}) {
  return _then(_RespostaFicha(
statusFicha: null == statusFicha ? _self.statusFicha : statusFicha // ignore: cast_nullable_to_non_nullable
as String,ficha: freezed == ficha ? _self.ficha : ficha // ignore: cast_nullable_to_non_nullable
as Ficha?,uso: freezed == uso ? _self.uso : uso // ignore: cast_nullable_to_non_nullable
as Uso?,
  ));
}

/// Create a copy of RespostaFicha
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FichaCopyWith<$Res>? get ficha {
    if (_self.ficha == null) {
    return null;
  }

  return $FichaCopyWith<$Res>(_self.ficha!, (value) {
    return _then(_self.copyWith(ficha: value));
  });
}/// Create a copy of RespostaFicha
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UsoCopyWith<$Res>? get uso {
    if (_self.uso == null) {
    return null;
  }

  return $UsoCopyWith<$Res>(_self.uso!, (value) {
    return _then(_self.copyWith(uso: value));
  });
}
}

// dart format on
