// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'usuario.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MembroDe {

 String get organizacaoId; String get nome; String get papel;
/// Create a copy of MembroDe
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MembroDeCopyWith<MembroDe> get copyWith => _$MembroDeCopyWithImpl<MembroDe>(this as MembroDe, _$identity);

  /// Serializes this MembroDe to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MembroDe;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MembroDe&&(identical(other.organizacaoId, _this.organizacaoId) || other.organizacaoId == _this.organizacaoId)&&(identical(other.nome, _this.nome) || other.nome == _this.nome)&&(identical(other.papel, _this.papel) || other.papel == _this.papel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MembroDe;
  return Object.hash(runtimeType,_this.organizacaoId,_this.nome,_this.papel);
}

@override
String toString() {
  final _this = this as MembroDe;
  return 'MembroDe(organizacaoId: ${_this.organizacaoId}, nome: ${_this.nome}, papel: ${_this.papel})';
}


}

/// @nodoc
abstract mixin class $MembroDeCopyWith<$Res>  {
  factory $MembroDeCopyWith(MembroDe value, $Res Function(MembroDe) _then) = _$MembroDeCopyWithImpl;
@useResult
$Res call({
 String organizacaoId, String nome, String papel
});




}
/// @nodoc
class _$MembroDeCopyWithImpl<$Res>
    implements $MembroDeCopyWith<$Res> {
  _$MembroDeCopyWithImpl(this._self, this._then);

  final MembroDe _self;
  final $Res Function(MembroDe) _then;

/// Create a copy of MembroDe
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? organizacaoId = null,Object? nome = null,Object? papel = null,}) {
  return _then(MembroDe(
organizacaoId: null == organizacaoId ? _self.organizacaoId : organizacaoId // ignore: cast_nullable_to_non_nullable
as String,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,papel: null == papel ? _self.papel : papel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MembroDe].
extension MembroDePatterns on MembroDe {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MembroDe value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MembroDe() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MembroDe value)  $default,){
final _that = this;
switch (_that) {
case _MembroDe():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MembroDe value)?  $default,){
final _that = this;
switch (_that) {
case _MembroDe() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String organizacaoId,  String nome,  String papel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MembroDe() when $default != null:
return $default(_that.organizacaoId,_that.nome,_that.papel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String organizacaoId,  String nome,  String papel)  $default,) {final _that = this;
switch (_that) {
case _MembroDe():
return $default(_that.organizacaoId,_that.nome,_that.papel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String organizacaoId,  String nome,  String papel)?  $default,) {final _that = this;
switch (_that) {
case _MembroDe() when $default != null:
return $default(_that.organizacaoId,_that.nome,_that.papel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MembroDe implements MembroDe {
  const _MembroDe({required this.organizacaoId, required this.nome, required this.papel});
  factory _MembroDe.fromJson(Map<String, dynamic> json) => _$MembroDeFromJson(json);

@override final  String organizacaoId;
@override final  String nome;
@override final  String papel;

/// Create a copy of MembroDe
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MembroDeCopyWith<_MembroDe> get copyWith => __$MembroDeCopyWithImpl<_MembroDe>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MembroDeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MembroDe&&(identical(other.organizacaoId, organizacaoId) || other.organizacaoId == organizacaoId)&&(identical(other.nome, nome) || other.nome == nome)&&(identical(other.papel, papel) || other.papel == papel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,organizacaoId,nome,papel);
}

@override
String toString() {
    return 'MembroDe(organizacaoId: $organizacaoId, nome: $nome, papel: $papel)';
}


}

/// @nodoc
abstract mixin class _$MembroDeCopyWith<$Res> implements $MembroDeCopyWith<$Res> {
  factory _$MembroDeCopyWith(_MembroDe value, $Res Function(_MembroDe) _then) = __$MembroDeCopyWithImpl;
@override @useResult
$Res call({
 String organizacaoId, String nome, String papel
});




}
/// @nodoc
class __$MembroDeCopyWithImpl<$Res>
    implements _$MembroDeCopyWith<$Res> {
  __$MembroDeCopyWithImpl(this._self, this._then);

  final _MembroDe _self;
  final $Res Function(_MembroDe) _then;

/// Create a copy of MembroDe
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? organizacaoId = null,Object? nome = null,Object? papel = null,}) {
  return _then(_MembroDe(
organizacaoId: null == organizacaoId ? _self.organizacaoId : organizacaoId // ignore: cast_nullable_to_non_nullable
as String,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,papel: null == papel ? _self.papel : papel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Usuario {

 String get id; String get email; String get nome; String get papel; List<MembroDe> get organizacoes; Uso? get uso;
/// Create a copy of Usuario
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UsuarioCopyWith<Usuario> get copyWith => _$UsuarioCopyWithImpl<Usuario>(this as Usuario, _$identity);

  /// Serializes this Usuario to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Usuario;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Usuario&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.nome, _this.nome) || other.nome == _this.nome)&&(identical(other.papel, _this.papel) || other.papel == _this.papel)&&const DeepCollectionEquality().equals(other.organizacoes, _this.organizacoes)&&(identical(other.uso, _this.uso) || other.uso == _this.uso));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Usuario;
  return Object.hash(runtimeType,_this.id,_this.email,_this.nome,_this.papel,const DeepCollectionEquality().hash(_this.organizacoes),_this.uso);
}

@override
String toString() {
  final _this = this as Usuario;
  return 'Usuario(id: ${_this.id}, email: ${_this.email}, nome: ${_this.nome}, papel: ${_this.papel}, organizacoes: ${_this.organizacoes}, uso: ${_this.uso})';
}


}

/// @nodoc
abstract mixin class $UsuarioCopyWith<$Res>  {
  factory $UsuarioCopyWith(Usuario value, $Res Function(Usuario) _then) = _$UsuarioCopyWithImpl;
@useResult
$Res call({
 String id, String email, String nome, String papel, List<MembroDe> organizacoes, Uso? uso
});


$UsoCopyWith<$Res>? get uso;

}
/// @nodoc
class _$UsuarioCopyWithImpl<$Res>
    implements $UsuarioCopyWith<$Res> {
  _$UsuarioCopyWithImpl(this._self, this._then);

  final Usuario _self;
  final $Res Function(Usuario) _then;

/// Create a copy of Usuario
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? nome = null,Object? papel = null,Object? organizacoes = null,Object? uso = freezed,}) {
  return _then(Usuario(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,papel: null == papel ? _self.papel : papel // ignore: cast_nullable_to_non_nullable
as String,organizacoes: null == organizacoes ? _self.organizacoes : organizacoes // ignore: cast_nullable_to_non_nullable
as List<MembroDe>,uso: freezed == uso ? _self.uso : uso // ignore: cast_nullable_to_non_nullable
as Uso?,
  ));
}
/// Create a copy of Usuario
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


/// Adds pattern-matching-related methods to [Usuario].
extension UsuarioPatterns on Usuario {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Usuario value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Usuario() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Usuario value)  $default,){
final _that = this;
switch (_that) {
case _Usuario():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Usuario value)?  $default,){
final _that = this;
switch (_that) {
case _Usuario() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  String nome,  String papel,  List<MembroDe> organizacoes,  Uso? uso)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Usuario() when $default != null:
return $default(_that.id,_that.email,_that.nome,_that.papel,_that.organizacoes,_that.uso);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  String nome,  String papel,  List<MembroDe> organizacoes,  Uso? uso)  $default,) {final _that = this;
switch (_that) {
case _Usuario():
return $default(_that.id,_that.email,_that.nome,_that.papel,_that.organizacoes,_that.uso);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  String nome,  String papel,  List<MembroDe> organizacoes,  Uso? uso)?  $default,) {final _that = this;
switch (_that) {
case _Usuario() when $default != null:
return $default(_that.id,_that.email,_that.nome,_that.papel,_that.organizacoes,_that.uso);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Usuario extends Usuario {
  const _Usuario({required this.id, required this.email, this.nome = '', this.papel = 'usuario',  List<MembroDe> organizacoes = const <MembroDe>[], this.uso}): _organizacoes = organizacoes,super._();
  factory _Usuario.fromJson(Map<String, dynamic> json) => _$UsuarioFromJson(json);

@override final  String id;
@override final  String email;
@override@JsonKey() final  String nome;
@override@JsonKey() final  String papel;
 final  List<MembroDe> _organizacoes;
@override@JsonKey() List<MembroDe> get organizacoes {
  if (_organizacoes is EqualUnmodifiableListView) return _organizacoes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_organizacoes);
}

@override final  Uso? uso;

/// Create a copy of Usuario
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UsuarioCopyWith<_Usuario> get copyWith => __$UsuarioCopyWithImpl<_Usuario>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UsuarioToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Usuario&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.nome, nome) || other.nome == nome)&&(identical(other.papel, papel) || other.papel == papel)&&const DeepCollectionEquality().equals(other.organizacoes, _organizacoes)&&(identical(other.uso, uso) || other.uso == uso));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,email,nome,papel,const DeepCollectionEquality().hash(_organizacoes),uso);
}

@override
String toString() {
    return 'Usuario(id: $id, email: $email, nome: $nome, papel: $papel, organizacoes: $organizacoes, uso: $uso)';
}


}

/// @nodoc
abstract mixin class _$UsuarioCopyWith<$Res> implements $UsuarioCopyWith<$Res> {
  factory _$UsuarioCopyWith(_Usuario value, $Res Function(_Usuario) _then) = __$UsuarioCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String nome, String papel, List<MembroDe> organizacoes, Uso? uso
});


@override $UsoCopyWith<$Res>? get uso;

}
/// @nodoc
class __$UsuarioCopyWithImpl<$Res>
    implements _$UsuarioCopyWith<$Res> {
  __$UsuarioCopyWithImpl(this._self, this._then);

  final _Usuario _self;
  final $Res Function(_Usuario) _then;

/// Create a copy of Usuario
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? nome = null,Object? papel = null,Object? organizacoes = null,Object? uso = freezed,}) {
  return _then(_Usuario(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,papel: null == papel ? _self.papel : papel // ignore: cast_nullable_to_non_nullable
as String,organizacoes: null == organizacoes ? _self._organizacoes : organizacoes // ignore: cast_nullable_to_non_nullable
as List<MembroDe>,uso: freezed == uso ? _self.uso : uso // ignore: cast_nullable_to_non_nullable
as Uso?,
  ));
}

/// Create a copy of Usuario
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


/// @nodoc
mixin _$PerfilLeitor {

 String get id; String get apelido; int get anoNascimento; String get icone;
/// Create a copy of PerfilLeitor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PerfilLeitorCopyWith<PerfilLeitor> get copyWith => _$PerfilLeitorCopyWithImpl<PerfilLeitor>(this as PerfilLeitor, _$identity);

  /// Serializes this PerfilLeitor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PerfilLeitor;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PerfilLeitor&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.apelido, _this.apelido) || other.apelido == _this.apelido)&&(identical(other.anoNascimento, _this.anoNascimento) || other.anoNascimento == _this.anoNascimento)&&(identical(other.icone, _this.icone) || other.icone == _this.icone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PerfilLeitor;
  return Object.hash(runtimeType,_this.id,_this.apelido,_this.anoNascimento,_this.icone);
}

@override
String toString() {
  final _this = this as PerfilLeitor;
  return 'PerfilLeitor(id: ${_this.id}, apelido: ${_this.apelido}, anoNascimento: ${_this.anoNascimento}, icone: ${_this.icone})';
}


}

/// @nodoc
abstract mixin class $PerfilLeitorCopyWith<$Res>  {
  factory $PerfilLeitorCopyWith(PerfilLeitor value, $Res Function(PerfilLeitor) _then) = _$PerfilLeitorCopyWithImpl;
@useResult
$Res call({
 String id, String apelido, int anoNascimento, String icone
});




}
/// @nodoc
class _$PerfilLeitorCopyWithImpl<$Res>
    implements $PerfilLeitorCopyWith<$Res> {
  _$PerfilLeitorCopyWithImpl(this._self, this._then);

  final PerfilLeitor _self;
  final $Res Function(PerfilLeitor) _then;

/// Create a copy of PerfilLeitor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? apelido = null,Object? anoNascimento = null,Object? icone = null,}) {
  return _then(PerfilLeitor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,apelido: null == apelido ? _self.apelido : apelido // ignore: cast_nullable_to_non_nullable
as String,anoNascimento: null == anoNascimento ? _self.anoNascimento : anoNascimento // ignore: cast_nullable_to_non_nullable
as int,icone: null == icone ? _self.icone : icone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PerfilLeitor].
extension PerfilLeitorPatterns on PerfilLeitor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PerfilLeitor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PerfilLeitor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PerfilLeitor value)  $default,){
final _that = this;
switch (_that) {
case _PerfilLeitor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PerfilLeitor value)?  $default,){
final _that = this;
switch (_that) {
case _PerfilLeitor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String apelido,  int anoNascimento,  String icone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PerfilLeitor() when $default != null:
return $default(_that.id,_that.apelido,_that.anoNascimento,_that.icone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String apelido,  int anoNascimento,  String icone)  $default,) {final _that = this;
switch (_that) {
case _PerfilLeitor():
return $default(_that.id,_that.apelido,_that.anoNascimento,_that.icone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String apelido,  int anoNascimento,  String icone)?  $default,) {final _that = this;
switch (_that) {
case _PerfilLeitor() when $default != null:
return $default(_that.id,_that.apelido,_that.anoNascimento,_that.icone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PerfilLeitor extends PerfilLeitor {
  const _PerfilLeitor({required this.id, required this.apelido, required this.anoNascimento, this.icone = 'livro'}): super._();
  factory _PerfilLeitor.fromJson(Map<String, dynamic> json) => _$PerfilLeitorFromJson(json);

@override final  String id;
@override final  String apelido;
@override final  int anoNascimento;
@override@JsonKey() final  String icone;

/// Create a copy of PerfilLeitor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PerfilLeitorCopyWith<_PerfilLeitor> get copyWith => __$PerfilLeitorCopyWithImpl<_PerfilLeitor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PerfilLeitorToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PerfilLeitor&&(identical(other.id, id) || other.id == id)&&(identical(other.apelido, apelido) || other.apelido == apelido)&&(identical(other.anoNascimento, anoNascimento) || other.anoNascimento == anoNascimento)&&(identical(other.icone, icone) || other.icone == icone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,apelido,anoNascimento,icone);
}

@override
String toString() {
    return 'PerfilLeitor(id: $id, apelido: $apelido, anoNascimento: $anoNascimento, icone: $icone)';
}


}

/// @nodoc
abstract mixin class _$PerfilLeitorCopyWith<$Res> implements $PerfilLeitorCopyWith<$Res> {
  factory _$PerfilLeitorCopyWith(_PerfilLeitor value, $Res Function(_PerfilLeitor) _then) = __$PerfilLeitorCopyWithImpl;
@override @useResult
$Res call({
 String id, String apelido, int anoNascimento, String icone
});




}
/// @nodoc
class __$PerfilLeitorCopyWithImpl<$Res>
    implements _$PerfilLeitorCopyWith<$Res> {
  __$PerfilLeitorCopyWithImpl(this._self, this._then);

  final _PerfilLeitor _self;
  final $Res Function(_PerfilLeitor) _then;

/// Create a copy of PerfilLeitor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? apelido = null,Object? anoNascimento = null,Object? icone = null,}) {
  return _then(_PerfilLeitor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,apelido: null == apelido ? _self.apelido : apelido // ignore: cast_nullable_to_non_nullable
as String,anoNascimento: null == anoNascimento ? _self.anoNascimento : anoNascimento // ignore: cast_nullable_to_non_nullable
as int,icone: null == icone ? _self.icone : icone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
