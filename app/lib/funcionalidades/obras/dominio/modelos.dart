// Modelos imutáveis do contrato da API (seção 4.3). Gerados com freezed/json_serializable.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'modelos.freezed.dart';
part 'modelos.g.dart';

const idsEixos = ['A1', 'A2', 'A3', 'A4', 'A5', 'A6'];
const faixasOrdenadas = ['Livre', '10+', '12+', '14+', '16+', '18+'];

/// Idade mínima de uma faixa ("14+" -> 14, "Livre" -> 0).
int idadeMinimaDaFaixa(String faixa) =>
    faixa == 'Livre' ? 0 : int.tryParse(faixa.replaceAll('+', '')) ?? 0;

@freezed
abstract class ObraResumo with _$ObraResumo {
  const factory ObraResumo({
    required String id,
    required String titulo,
    String? subtitulo,
    @Default(<String>[]) List<String> autores,
    String? capaUrl,
    String? isbn13,
    String? faixaFinal,
    @Default('sem_ficha') String statusFicha,
    @Default('base_entrelinhas') String origem,
    @Default(false) bool demonstracao,
  }) = _ObraResumo;

  factory ObraResumo.fromJson(Map<String, dynamic> json) => _$ObraResumoFromJson(json);
}

@freezed
abstract class Edicao with _$Edicao {
  const factory Edicao({
    required String id,
    String? isbn13,
    String? isbn10,
    String? editora,
    int? ano,
    String? capaUrl,
  }) = _Edicao;

  factory Edicao.fromJson(Map<String, dynamic> json) => _$EdicaoFromJson(json);
}

@freezed
abstract class ObraDetalhe with _$ObraDetalhe {
  const ObraDetalhe._();

  const factory ObraDetalhe({
    required String id,
    required String titulo,
    String? subtitulo,
    @Default(<String>[]) List<String> autores,
    String? capaUrl,
    String? isbn13,
    String? faixaFinal,
    @Default('sem_ficha') String statusFicha,
    @Default('base_entrelinhas') String origem,
    @Default(false) bool demonstracao,
    String? sinopse,
    String? genero,
    int? paginas,
    String? idioma,
    @Default(<Edicao>[]) List<Edicao> edicoes,
  }) = _ObraDetalhe;

  factory ObraDetalhe.fromJson(Map<String, dynamic> json) => _$ObraDetalheFromJson(json);

  ObraResumo get resumo => ObraResumo(
        id: id,
        titulo: titulo,
        subtitulo: subtitulo,
        autores: autores,
        capaUrl: capaUrl,
        isbn13: isbn13,
        faixaFinal: faixaFinal,
        statusFicha: statusFicha,
        origem: origem,
        demonstracao: demonstracao,
      );
}

@freezed
abstract class ResultadoBusca with _$ResultadoBusca {
  const factory ResultadoBusca({
    @Default(<ObraResumo>[]) List<ObraResumo> resultados,
    String? isbn,
    @Default(false) bool fontesExternasIndisponiveis,
  }) = _ResultadoBusca;

  factory ResultadoBusca.fromJson(Map<String, dynamic> json) => _$ResultadoBuscaFromJson(json);
}

@freezed
abstract class EixoFicha with _$EixoFicha {
  const factory EixoFicha({
    required int nivel,
    required String faixa,
    @Default('') String justificativa,
  }) = _EixoFicha;

  factory EixoFicha.fromJson(Map<String, dynamic> json) => _$EixoFichaFromJson(json);
}

@freezed
abstract class Evidencia with _$Evidencia {
  const factory Evidencia({
    required String eixo,
    @Default('') String parafrase,
    String? trechoLiteral,
    String? fonte,
    String? localizacao,
  }) = _Evidencia;

  factory Evidencia.fromJson(Map<String, dynamic> json) => _$EvidenciaFromJson(json);
}

@freezed
abstract class CamadaB with _$CamadaB {
  const factory CamadaB({
    @Default(<String>[]) List<String> flags,
    @Default(<String, String>{}) Map<String, String> justificativas,
  }) = _CamadaB;

  factory CamadaB.fromJson(Map<String, dynamic> json) => _$CamadaBFromJson(json);
}

@freezed
abstract class ValorFormativo with _$ValorFormativo {
  const factory ValorFormativo({
    required String nivel,
    @Default(<String>[]) List<String> marcadores,
    @Default('') String justificativa,
  }) = _ValorFormativo;

  factory ValorFormativo.fromJson(Map<String, dynamic> json) => _$ValorFormativoFromJson(json);
}

@freezed
abstract class CamadaC with _$CamadaC {
  const factory CamadaC({
    required int vocabulario,
    required int estruturaNarrativa,
    required int densidadeTematica,
    int? extensao,
    required int nivelLeitura,
    required String rotuloNivelLeitura,
    @Default(<String>[]) List<String> exigenciaRepertorio,
    required ValorFormativo valorFormativo,
  }) = _CamadaC;

  factory CamadaC.fromJson(Map<String, dynamic> json) => _$CamadaCFromJson(json);
}

@freezed
abstract class FonteProcedencia with _$FonteProcedencia {
  const factory FonteProcedencia({required String tipo, String? url}) = _FonteProcedencia;

  factory FonteProcedencia.fromJson(Map<String, dynamic> json) =>
      _$FonteProcedenciaFromJson(json);
}

@freezed
abstract class Procedencia with _$Procedencia {
  const factory Procedencia({
    required String fonteDaAnalise,
    required double confianca,
    String? modelo,
    @Default(<FonteProcedencia>[]) List<FonteProcedencia> fontes,
    @Default(false) bool revisadaPorHumano,
    String? revisadaEm,
  }) = _Procedencia;

  factory Procedencia.fromJson(Map<String, dynamic> json) => _$ProcedenciaFromJson(json);
}

@freezed
abstract class Ficha with _$Ficha {
  const Ficha._();

  const factory Ficha({
    required String obraId,
    required String versaoRubrica,
    required int versaoFicha,
    required String status,
    required String faixaFinal,
    required String faixaBase,
    required bool agravanteAcumuloAplicado,
    required String eixoDeterminante,
    required String recomendacaoContextual,
    required String textoRecomendacao,
    required Map<String, EixoFicha> camadaA,
    @Default(<Evidencia>[]) List<Evidencia> evidencias,
    required CamadaB camadaB,
    required CamadaC camadaC,
    required Procedencia procedencia,
    required String atualizadaEm,
    String? slug,
    String? avisoA5,
    String? avisoEstimativa,
    String? avisoIndependencia,
  }) = _Ficha;

  factory Ficha.fromJson(Map<String, dynamic> json) => _$FichaFromJson(json);

  bool get emRevisao => status == 'em_revisao';
  bool get semAcessoAoTexto =>
      procedencia.fonteDaAnalise == 'fontes_publicas' ||
      procedencia.fonteDaAnalise == 'metadados_e_conhecimento_previo';
  List<Evidencia> evidenciasDo(String eixo) => evidencias.where((e) => e.eixo == eixo).toList();
}

@freezed
abstract class ResumoFicha with _$ResumoFicha {
  const factory ResumoFicha({
    required String obraId,
    required String slug,
    required String status,
    String? faixaFinal,
    String? recomendacaoContextual,
    String? textoRecomendacao,
    String? fonteDaAnalise,
    String? textoFonteAnalise,
    double? confianca,
    @Default(false) bool revisadaPorHumano,
  }) = _ResumoFicha;

  factory ResumoFicha.fromJson(Map<String, dynamic> json) => _$ResumoFichaFromJson(json);
}

@freezed
abstract class Uso with _$Uso {
  const factory Uso({
    @Default('gratuito') String plano,
    String? origem,
    String? validaAte,
    String? organizacaoId,
    @Default(0) int consultasUsadas,
    int? consultasLimite,
  }) = _Uso;

  factory Uso.fromJson(Map<String, dynamic> json) => _$UsoFromJson(json);
}

@freezed
abstract class RespostaFicha with _$RespostaFicha {
  const factory RespostaFicha({
    required String statusFicha,
    Ficha? ficha,
    Uso? uso,
  }) = _RespostaFicha;

  factory RespostaFicha.fromJson(Map<String, dynamic> json) => _$RespostaFichaFromJson(json);
}
