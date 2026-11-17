/// Flags e limites vindos do servidor (seção 4.8).
///
/// Todo bloco visual pergunta a [ConfiguracaoServidor.podeExibir]. Chave desconhecida é
/// erro, nunca "verdadeiro".
class FlagDesconhecida implements Exception {
  FlagDesconhecida(this.chave);
  final String chave;
  @override
  String toString() => 'Flag de visibilidade desconhecida: $chave';
}

class ConfiguracaoServidor {
  const ConfiguracaoServidor({required this.flags, required this.limites});

  final Map<String, bool> flags;
  final Map<String, dynamic> limites;

  static const chavesConhecidas = {
    'trechos_literais',
    'parafrase_evidencia',
    'camada_b',
    'camada_c',
    'valor_formativo',
    'eixo_a6',
    'confianca',
    'justificativa_eixo',
    'selo_revisao_humana',
    'metodologia',
    'exportar_pdf',
    'compartilhar',
    'scanner',
    'busca_titulo',
  };

  /// Valores iniciais da seção 4.8, usados enquanto o servidor não responde.
  static const padrao = ConfiguracaoServidor(
    flags: {
      'trechos_literais': false,
      'parafrase_evidencia': true,
      'camada_b': true,
      'camada_c': true,
      'valor_formativo': true,
      'eixo_a6': true,
      'confianca': true,
      'justificativa_eixo': true,
      'selo_revisao_humana': true,
      'metodologia': true,
      'exportar_pdf': true,
      'compartilhar': true,
      'scanner': true,
      'busca_titulo': true,
    },
    limites: {'consultas_gratis_mes': 10, 'perfis_plano_gratuito': 1},
  );

  factory ConfiguracaoServidor.fromJson(Map<String, dynamic> json) {
    final flags = Map<String, bool>.from(padrao.flags);
    (json['flags'] as Map? ?? {}).forEach((k, v) {
      if (chavesConhecidas.contains(k)) flags[k as String] = v == true;
    });
    return ConfiguracaoServidor(
      flags: flags,
      limites: {...padrao.limites, ...Map<String, dynamic>.from(json['limites'] as Map? ?? {})},
    );
  }

  bool podeExibir(String chave) {
    final valor = flags[chave];
    if (valor == null || !chavesConhecidas.contains(chave)) throw FlagDesconhecida(chave);
    return valor;
  }

  int get consultasGratisMes => (limites['consultas_gratis_mes'] as num?)?.toInt() ?? 10;

  ConfiguracaoServidor comFlag(String chave, bool valor) {
    podeExibir(chave);
    return ConfiguracaoServidor(flags: {...flags, chave: valor}, limites: limites);
  }
}
