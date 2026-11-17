// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MembroDe _$MembroDeFromJson(Map<String, dynamic> json) => _MembroDe(
  organizacaoId: json['organizacao_id'] as String,
  nome: json['nome'] as String,
  papel: json['papel'] as String,
);

Map<String, dynamic> _$MembroDeToJson(_MembroDe instance) => <String, dynamic>{
  'organizacao_id': instance.organizacaoId,
  'nome': instance.nome,
  'papel': instance.papel,
};

_Usuario _$UsuarioFromJson(Map<String, dynamic> json) => _Usuario(
  id: json['id'] as String,
  email: json['email'] as String,
  nome: json['nome'] as String? ?? '',
  papel: json['papel'] as String? ?? 'usuario',
  contribuirImagens: json['contribuir_imagens'] as bool? ?? false,
  organizacoes:
      (json['organizacoes'] as List<dynamic>?)
          ?.map((e) => MembroDe.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <MembroDe>[],
  uso: json['uso'] == null
      ? null
      : Uso.fromJson(json['uso'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UsuarioToJson(_Usuario instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'nome': instance.nome,
  'papel': instance.papel,
  'contribuir_imagens': instance.contribuirImagens,
  'organizacoes': instance.organizacoes.map((e) => e.toJson()).toList(),
  'uso': instance.uso?.toJson(),
};

_PerfilLeitor _$PerfilLeitorFromJson(Map<String, dynamic> json) =>
    _PerfilLeitor(
      id: json['id'] as String,
      apelido: json['apelido'] as String,
      anoNascimento: (json['ano_nascimento'] as num).toInt(),
      icone: json['icone'] as String? ?? 'livro',
    );

Map<String, dynamic> _$PerfilLeitorToJson(_PerfilLeitor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'apelido': instance.apelido,
      'ano_nascimento': instance.anoNascimento,
      'icone': instance.icone,
    };
