import 'package:freezed_annotation/freezed_annotation.dart';

import '../../obras/dominio/modelos.dart';

part 'usuario.freezed.dart';
part 'usuario.g.dart';

@freezed
abstract class MembroDe with _$MembroDe {
  const factory MembroDe({
    required String organizacaoId,
    required String nome,
    required String papel,
  }) = _MembroDe;

  factory MembroDe.fromJson(Map<String, dynamic> json) => _$MembroDeFromJson(json);
}

@freezed
abstract class Usuario with _$Usuario {
  const Usuario._();

  const factory Usuario({
    required String id,
    required String email,
    @Default('') String nome,
    @Default('usuario') String papel,
    @Default(<MembroDe>[]) List<MembroDe> organizacoes,
    Uso? uso,
  }) = _Usuario;

  factory Usuario.fromJson(Map<String, dynamic> json) => _$UsuarioFromJson(json);

  bool get revisor => papel == 'revisor' || papel == 'admin';
  bool get temOrganizacao => organizacoes.isNotEmpty;
}

@freezed
abstract class PerfilLeitor with _$PerfilLeitor {
  const PerfilLeitor._();

  const factory PerfilLeitor({
    required String id,
    required String apelido,
    required int anoNascimento,
    @Default('livro') String icone,
  }) = _PerfilLeitor;

  factory PerfilLeitor.fromJson(Map<String, dynamic> json) => _$PerfilLeitorFromJson(json);

  /// Idade completada no ano corrente (só temos o ano de nascimento, de propósito).
  int idadeEm(DateTime hoje) => hoje.year - anoNascimento;
}
