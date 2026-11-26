// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modelos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ObraResumo _$ObraResumoFromJson(Map<String, dynamic> json) => _ObraResumo(
  id: json['id'] as String,
  titulo: json['titulo'] as String,
  subtitulo: json['subtitulo'] as String?,
  autores:
      (json['autores'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const <String>[],
  capaUrl: json['capa_url'] as String?,
  isbn13: json['isbn13'] as String?,
  faixaFinal: json['faixa_final'] as String?,
  statusFicha: json['status_ficha'] as String? ?? 'sem_ficha',
  origem: json['origem'] as String? ?? 'base_entrelinhas',
  demonstracao: json['demonstracao'] as bool? ?? false,
);

Map<String, dynamic> _$ObraResumoToJson(_ObraResumo instance) => <String, dynamic>{
  'id': instance.id,
  'titulo': instance.titulo,
  'subtitulo': instance.subtitulo,
  'autores': instance.autores,
  'capa_url': instance.capaUrl,
  'isbn13': instance.isbn13,
  'faixa_final': instance.faixaFinal,
  'status_ficha': instance.statusFicha,
  'origem': instance.origem,
  'demonstracao': instance.demonstracao,
};

_Edicao _$EdicaoFromJson(Map<String, dynamic> json) => _Edicao(
  id: json['id'] as String,
  isbn13: json['isbn13'] as String?,
  isbn10: json['isbn10'] as String?,
  editora: json['editora'] as String?,
  ano: (json['ano'] as num?)?.toInt(),
  capaUrl: json['capa_url'] as String?,
);

Map<String, dynamic> _$EdicaoToJson(_Edicao instance) => <String, dynamic>{
  'id': instance.id,
  'isbn13': instance.isbn13,
  'isbn10': instance.isbn10,
  'editora': instance.editora,
  'ano': instance.ano,
  'capa_url': instance.capaUrl,
};

_ObraDetalhe _$ObraDetalheFromJson(Map<String, dynamic> json) => _ObraDetalhe(
  id: json['id'] as String,
  titulo: json['titulo'] as String,
  subtitulo: json['subtitulo'] as String?,
  autores:
      (json['autores'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const <String>[],
  capaUrl: json['capa_url'] as String?,
  isbn13: json['isbn13'] as String?,
  faixaFinal: json['faixa_final'] as String?,
  statusFicha: json['status_ficha'] as String? ?? 'sem_ficha',
  origem: json['origem'] as String? ?? 'base_entrelinhas',
  demonstracao: json['demonstracao'] as bool? ?? false,
  sinopse: json['sinopse'] as String?,
  genero: json['genero'] as String?,
  paginas: (json['paginas'] as num?)?.toInt(),
  idioma: json['idioma'] as String?,
  edicoes:
      (json['edicoes'] as List<dynamic>?)
          ?.map((e) => Edicao.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Edicao>[],
);

Map<String, dynamic> _$ObraDetalheToJson(_ObraDetalhe instance) => <String, dynamic>{
  'id': instance.id,
  'titulo': instance.titulo,
  'subtitulo': instance.subtitulo,
  'autores': instance.autores,
  'capa_url': instance.capaUrl,
  'isbn13': instance.isbn13,
  'faixa_final': instance.faixaFinal,
  'status_ficha': instance.statusFicha,
  'origem': instance.origem,
  'demonstracao': instance.demonstracao,
  'sinopse': instance.sinopse,
  'genero': instance.genero,
  'paginas': instance.paginas,
  'idioma': instance.idioma,
  'edicoes': instance.edicoes.map((e) => e.toJson()).toList(),
};

_ResultadoBusca _$ResultadoBuscaFromJson(Map<String, dynamic> json) => _ResultadoBusca(
  resultados:
      (json['resultados'] as List<dynamic>?)
          ?.map((e) => ObraResumo.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ObraResumo>[],
  isbn: json['isbn'] as String?,
  fontesExternasIndisponiveis: json['fontes_externas_indisponiveis'] as bool? ?? false,
);

Map<String, dynamic> _$ResultadoBuscaToJson(_ResultadoBusca instance) => <String, dynamic>{
  'resultados': instance.resultados.map((e) => e.toJson()).toList(),
  'isbn': instance.isbn,
  'fontes_externas_indisponiveis': instance.fontesExternasIndisponiveis,
};

_EixoFicha _$EixoFichaFromJson(Map<String, dynamic> json) => _EixoFicha(
  nivel: (json['nivel'] as num).toInt(),
  faixa: json['faixa'] as String,
  justificativa: json['justificativa'] as String? ?? '',
);

Map<String, dynamic> _$EixoFichaToJson(_EixoFicha instance) => <String, dynamic>{
  'nivel': instance.nivel,
  'faixa': instance.faixa,
  'justificativa': instance.justificativa,
};

_Evidencia _$EvidenciaFromJson(Map<String, dynamic> json) => _Evidencia(
  eixo: json['eixo'] as String,
  parafrase: json['parafrase'] as String? ?? '',
  trechoLiteral: json['trecho_literal'] as String?,
  fonte: json['fonte'] as String?,
  localizacao: json['localizacao'] as String?,
);

Map<String, dynamic> _$EvidenciaToJson(_Evidencia instance) => <String, dynamic>{
  'eixo': instance.eixo,
  'parafrase': instance.parafrase,
  'trecho_literal': instance.trechoLiteral,
  'fonte': instance.fonte,
  'localizacao': instance.localizacao,
};

_CamadaB _$CamadaBFromJson(Map<String, dynamic> json) => _CamadaB(
  flags: (json['flags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const <String>[],
  justificativas:
      (json['justificativas'] as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as String)) ??
      const <String, String>{},
);

Map<String, dynamic> _$CamadaBToJson(_CamadaB instance) => <String, dynamic>{
  'flags': instance.flags,
  'justificativas': instance.justificativas,
};

_ValorFormativo _$ValorFormativoFromJson(Map<String, dynamic> json) => _ValorFormativo(
  nivel: json['nivel'] as String,
  marcadores:
      (json['marcadores'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const <String>[],
  justificativa: json['justificativa'] as String? ?? '',
);

Map<String, dynamic> _$ValorFormativoToJson(_ValorFormativo instance) => <String, dynamic>{
  'nivel': instance.nivel,
  'marcadores': instance.marcadores,
  'justificativa': instance.justificativa,
};

_CamadaC _$CamadaCFromJson(Map<String, dynamic> json) => _CamadaC(
  vocabulario: (json['vocabulario'] as num).toInt(),
  estruturaNarrativa: (json['estrutura_narrativa'] as num).toInt(),
  densidadeTematica: (json['densidade_tematica'] as num).toInt(),
  extensao: (json['extensao'] as num?)?.toInt(),
  nivelLeitura: (json['nivel_leitura'] as num).toInt(),
  rotuloNivelLeitura: json['rotulo_nivel_leitura'] as String,
  exigenciaRepertorio:
      (json['exigencia_repertorio'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  valorFormativo: ValorFormativo.fromJson(json['valor_formativo'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CamadaCToJson(_CamadaC instance) => <String, dynamic>{
  'vocabulario': instance.vocabulario,
  'estrutura_narrativa': instance.estruturaNarrativa,
  'densidade_tematica': instance.densidadeTematica,
  'extensao': instance.extensao,
  'nivel_leitura': instance.nivelLeitura,
  'rotulo_nivel_leitura': instance.rotuloNivelLeitura,
  'exigencia_repertorio': instance.exigenciaRepertorio,
  'valor_formativo': instance.valorFormativo.toJson(),
};

_FonteProcedencia _$FonteProcedenciaFromJson(Map<String, dynamic> json) =>
    _FonteProcedencia(tipo: json['tipo'] as String, url: json['url'] as String?);

Map<String, dynamic> _$FonteProcedenciaToJson(_FonteProcedencia instance) => <String, dynamic>{
  'tipo': instance.tipo,
  'url': instance.url,
};

_Procedencia _$ProcedenciaFromJson(Map<String, dynamic> json) => _Procedencia(
  fonteDaAnalise: json['fonte_da_analise'] as String,
  confianca: (json['confianca'] as num).toDouble(),
  modelo: json['modelo'] as String?,
  fontes:
      (json['fontes'] as List<dynamic>?)
          ?.map((e) => FonteProcedencia.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <FonteProcedencia>[],
  revisadaPorHumano: json['revisada_por_humano'] as bool? ?? false,
  revisadaEm: json['revisada_em'] as String?,
);

Map<String, dynamic> _$ProcedenciaToJson(_Procedencia instance) => <String, dynamic>{
  'fonte_da_analise': instance.fonteDaAnalise,
  'confianca': instance.confianca,
  'modelo': instance.modelo,
  'fontes': instance.fontes.map((e) => e.toJson()).toList(),
  'revisada_por_humano': instance.revisadaPorHumano,
  'revisada_em': instance.revisadaEm,
};

_Ficha _$FichaFromJson(Map<String, dynamic> json) => _Ficha(
  obraId: json['obra_id'] as String,
  versaoRubrica: json['versao_rubrica'] as String,
  versaoFicha: (json['versao_ficha'] as num).toInt(),
  status: json['status'] as String,
  faixaFinal: json['faixa_final'] as String,
  faixaBase: json['faixa_base'] as String,
  agravanteAcumuloAplicado: json['agravante_acumulo_aplicado'] as bool,
  eixoDeterminante: json['eixo_determinante'] as String,
  recomendacaoContextual: json['recomendacao_contextual'] as String,
  textoRecomendacao: json['texto_recomendacao'] as String,
  camadaA: (json['camada_a'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, EixoFicha.fromJson(e as Map<String, dynamic>)),
  ),
  evidencias:
      (json['evidencias'] as List<dynamic>?)
          ?.map((e) => Evidencia.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Evidencia>[],
  camadaB: CamadaB.fromJson(json['camada_b'] as Map<String, dynamic>),
  camadaC: CamadaC.fromJson(json['camada_c'] as Map<String, dynamic>),
  procedencia: Procedencia.fromJson(json['procedencia'] as Map<String, dynamic>),
  atualizadaEm: json['atualizada_em'] as String,
  slug: json['slug'] as String?,
  avisoA5: json['aviso_a5'] as String?,
  avisoEstimativa: json['aviso_estimativa'] as String?,
  avisoIndependencia: json['aviso_independencia'] as String?,
);

Map<String, dynamic> _$FichaToJson(_Ficha instance) => <String, dynamic>{
  'obra_id': instance.obraId,
  'versao_rubrica': instance.versaoRubrica,
  'versao_ficha': instance.versaoFicha,
  'status': instance.status,
  'faixa_final': instance.faixaFinal,
  'faixa_base': instance.faixaBase,
  'agravante_acumulo_aplicado': instance.agravanteAcumuloAplicado,
  'eixo_determinante': instance.eixoDeterminante,
  'recomendacao_contextual': instance.recomendacaoContextual,
  'texto_recomendacao': instance.textoRecomendacao,
  'camada_a': instance.camadaA.map((k, e) => MapEntry(k, e.toJson())),
  'evidencias': instance.evidencias.map((e) => e.toJson()).toList(),
  'camada_b': instance.camadaB.toJson(),
  'camada_c': instance.camadaC.toJson(),
  'procedencia': instance.procedencia.toJson(),
  'atualizada_em': instance.atualizadaEm,
  'slug': instance.slug,
  'aviso_a5': instance.avisoA5,
  'aviso_estimativa': instance.avisoEstimativa,
  'aviso_independencia': instance.avisoIndependencia,
};

_ResumoFicha _$ResumoFichaFromJson(Map<String, dynamic> json) => _ResumoFicha(
  obraId: json['obra_id'] as String,
  slug: json['slug'] as String,
  status: json['status'] as String,
  faixaFinal: json['faixa_final'] as String?,
  recomendacaoContextual: json['recomendacao_contextual'] as String?,
  textoRecomendacao: json['texto_recomendacao'] as String?,
  fonteDaAnalise: json['fonte_da_analise'] as String?,
  textoFonteAnalise: json['texto_fonte_analise'] as String?,
  confianca: (json['confianca'] as num?)?.toDouble(),
  revisadaPorHumano: json['revisada_por_humano'] as bool? ?? false,
);

Map<String, dynamic> _$ResumoFichaToJson(_ResumoFicha instance) => <String, dynamic>{
  'obra_id': instance.obraId,
  'slug': instance.slug,
  'status': instance.status,
  'faixa_final': instance.faixaFinal,
  'recomendacao_contextual': instance.recomendacaoContextual,
  'texto_recomendacao': instance.textoRecomendacao,
  'fonte_da_analise': instance.fonteDaAnalise,
  'texto_fonte_analise': instance.textoFonteAnalise,
  'confianca': instance.confianca,
  'revisada_por_humano': instance.revisadaPorHumano,
};

_Uso _$UsoFromJson(Map<String, dynamic> json) => _Uso(
  plano: json['plano'] as String? ?? 'gratuito',
  origem: json['origem'] as String?,
  validaAte: json['valida_ate'] as String?,
  organizacaoId: json['organizacao_id'] as String?,
  consultasUsadas: (json['consultas_usadas'] as num?)?.toInt() ?? 0,
  consultasLimite: (json['consultas_limite'] as num?)?.toInt(),
);

Map<String, dynamic> _$UsoToJson(_Uso instance) => <String, dynamic>{
  'plano': instance.plano,
  'origem': instance.origem,
  'valida_ate': instance.validaAte,
  'organizacao_id': instance.organizacaoId,
  'consultas_usadas': instance.consultasUsadas,
  'consultas_limite': instance.consultasLimite,
};

_RespostaFicha _$RespostaFichaFromJson(Map<String, dynamic> json) => _RespostaFicha(
  statusFicha: json['status_ficha'] as String,
  ficha: json['ficha'] == null ? null : Ficha.fromJson(json['ficha'] as Map<String, dynamic>),
  uso: json['uso'] == null ? null : Uso.fromJson(json['uso'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RespostaFichaToJson(_RespostaFicha instance) => <String, dynamic>{
  'status_ficha': instance.statusFicha,
  'ficha': instance.ficha?.toJson(),
  'uso': instance.uso?.toJson(),
};
