import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/cache/cache_local.dart';
import '../../../nucleo/provedores.dart';
import '../../../nucleo/rede/cliente_api.dart';
import '../../../nucleo/rede/erro_api.dart';
import '../dominio/modelos.dart';

/// Repositório de obras e fichas: única ponte entre a interface e a API.
class ObrasRepositorio {
  ObrasRepositorio(this.api, this.cache);

  final ClienteApi api;
  final CacheLocal cache;

  static const _chaveHistorico = 'historico_consultas';
  static const maxHistorico = 20;

  Future<ResultadoBusca> buscar(String termo) async {
    final json = await api.get<Map<String, dynamic>>('/v1/obras', query: {'busca': termo});
    return ResultadoBusca.fromJson(json);
  }

  Future<ObraDetalhe> obter(String id) async {
    final chave = 'obra_$id';
    try {
      final json = await api.get<Map<String, dynamic>>('/v1/obras/$id');
      await cache.gravarJson(chave, json);
      return ObraDetalhe.fromJson(json);
    } on ErroApi catch (e) {
      if (e.semRede) {
        final salvo = await cache.lerJson(chave);
        if (salvo is Map<String, dynamic>) return ObraDetalhe.fromJson(salvo);
      }
      rethrow;
    }
  }

  Future<ObraDetalhe> porIsbn(String isbn) async =>
      ObraDetalhe.fromJson(await api.get<Map<String, dynamic>>('/v1/obras/isbn/$isbn'));

  Future<({String statusFicha, ResumoFicha? resumo})> resumoFicha(String id) async {
    final json = await api.get<Map<String, dynamic>>('/v1/obras/$id/ficha/resumo');
    final r = json['resumo'];
    return (
      statusFicha: json['status_ficha'] as String,
      resumo: r is Map<String, dynamic> ? ResumoFicha.fromJson(r) : null,
    );
  }

  /// Ficha completa, com cache: a última ficha vista abre sem rede.
  Future<RespostaFicha> ficha(String id) async {
    final chave = 'ficha_$id';
    try {
      final json = await api.get<Map<String, dynamic>>('/v1/obras/$id/ficha');
      final resposta = RespostaFicha.fromJson(json);
      if (resposta.ficha != null) await cache.gravarJson(chave, json);
      return resposta;
    } on ErroApi catch (e) {
      if (e.semRede) {
        final salvo = await cache.lerJson(chave);
        if (salvo is Map<String, dynamic>) return RespostaFicha.fromJson(salvo);
      }
      rethrow;
    }
  }

  Future<void> pedirAnalise(String id) => api.post<dynamic>('/v1/obras/$id/analise');

  Future<ObraDetalhe> cadastrar({
    required String isbn,
    required String titulo,
    required List<String> autores,
    String? editora,
    int? ano,
    int? paginas,
  }) async {
    final json = await api.post<Map<String, dynamic>>(
      '/v1/obras',
      dados: {
        'isbn': isbn,
        'titulo': titulo,
        'autores': autores,
        'editora': ?editora,
        'ano': ?ano,
        'paginas': ?paginas,
      },
    );
    return ObraDetalhe.fromJson(json);
  }

  // --------------------------------------------------------- histórico local

  Future<List<ObraResumo>> historico() async {
    final salvo = await cache.lerJson(_chaveHistorico);
    if (salvo is! List) return const [];
    return salvo.whereType<Map<String, dynamic>>().map(ObraResumo.fromJson).toList(growable: false);
  }

  Future<List<ObraResumo>> registrarNoHistorico(ObraResumo obra) async {
    final atual = [...await historico()]..removeWhere((o) => o.id == obra.id);
    final novo = [obra, ...atual].take(maxHistorico).toList();
    await cache.gravarJson(_chaveHistorico, novo.map((o) => o.toJson()).toList());
    return novo;
  }
}

final obrasRepositorioProvider = Provider<ObrasRepositorio>(
  (ref) => ObrasRepositorio(ref.watch(clienteApiProvider), ref.watch(cacheLocalProvider)),
);

final historicoProvider = AsyncNotifierProvider<HistoricoNotifier, List<ObraResumo>>(
  HistoricoNotifier.new,
);

class HistoricoNotifier extends AsyncNotifier<List<ObraResumo>> {
  @override
  Future<List<ObraResumo>> build() => ref.watch(obrasRepositorioProvider).historico();

  Future<void> registrar(ObraResumo obra) async {
    state = AsyncData(await ref.read(obrasRepositorioProvider).registrarNoHistorico(obra));
  }
}
