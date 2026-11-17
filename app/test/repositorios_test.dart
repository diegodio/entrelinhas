import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:entrelinhas/funcionalidades/obras/dados/obras_repositorio.dart';
import 'package:entrelinhas/funcionalidades/obras/dominio/modelos.dart';
import 'package:entrelinhas/nucleo/cache/cache_local.dart';
import 'package:entrelinhas/nucleo/rede/armazenamento_tokens.dart';
import 'package:entrelinhas/nucleo/rede/cliente_api.dart';
import 'package:entrelinhas/nucleo/rede/erro_api.dart';
import 'package:flutter_test/flutter_test.dart';

/// Adaptador HTTP falso: responde por caminho; `null` simula falta de rede.
class AdaptadorFalso implements HttpClientAdapter {
  AdaptadorFalso(this.rotas);
  final Map<String, (int, Object)?> rotas;
  final pedidos = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? _, Future<void>? _) async {
    pedidos.add(o);
    final r = rotas[o.path];
    if (r == null) {
      throw DioException.connectionError(requestOptions: o, reason: 'sem rede');
    }
    return ResponseBody.fromString(
      jsonEncode(r.$2),
      r.$1,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ClienteApi cliente(AdaptadorFalso a, ArmazenamentoTokens tokens) {
  final dio = Dio(BaseOptions(baseUrl: 'http://teste'))..httpClientAdapter = a;
  return ClienteApi(urlBase: 'http://teste', tokens: tokens, dio: dio);
}

Map<String, dynamic> obraJson(String id) => {
  'id': id,
  'titulo': 'Obra $id',
  'autores': <String>[],
  'status_ficha': 'publicada',
  'origem': 'base_entrelinhas',
  'demonstracao': false,
  'edicoes': <Object>[],
};

void main() {
  test('histórico: mais recente primeiro, sem repetir, no máximo 20', () async {
    final repo = ObrasRepositorio(
      cliente(AdaptadorFalso({}), ArmazenamentoTokensMemoria()),
      CacheMemoria(),
    );
    for (var i = 0; i < 25; i++) {
      await repo.registrarNoHistorico(ObraResumo(id: 'o$i', titulo: 'Obra $i'));
    }
    await repo.registrarNoHistorico(const ObraResumo(id: 'o10', titulo: 'Obra 10'));
    final h = await repo.historico();
    expect(h.length, ObrasRepositorio.maxHistorico);
    expect(h.first.id, 'o10');
    expect(h.where((o) => o.id == 'o10').length, 1);
  });

  test('a última ficha vista abre sem rede', () async {
    final cache = CacheMemoria();
    final rotas = <String, (int, Object)?>{
      '/v1/obras/o1': (200, obraJson('o1')),
      '/v1/obras/o1/ficha': (200, {'status_ficha': 'sem_ficha', 'ficha': null, 'uso': null}),
    };
    final adaptador = AdaptadorFalso(rotas);
    final repo = ObrasRepositorio(cliente(adaptador, ArmazenamentoTokensMemoria()), cache);
    expect((await repo.obter('o1')).titulo, 'Obra o1');
    // Sem rede: a obra vem do cache.
    rotas['/v1/obras/o1'] = null;
    expect((await repo.obter('o1')).titulo, 'Obra o1');
    // Ficha nunca aberta e sem rede: erro de rede, sem inventar dado.
    rotas['/v1/obras/o1/ficha'] = null;
    expect(
      () => repo.ficha('o1'),
      throwsA(isA<ErroApi>().having((e) => e.semRede, 'semRede', true)),
    );
  });

  test('erro da API vira ErroApi com código e detalhes', () async {
    final adaptador = AdaptadorFalso({
      '/v1/obras': (
        400,
        {
          'codigo': 'busca_curta',
          'mensagem': 'Digite ao menos 3 letras para buscar.',
          'detalhes': {},
        },
      ),
    });
    final repo = ObrasRepositorio(cliente(adaptador, ArmazenamentoTokensMemoria()), CacheMemoria());
    await expectLater(
      repo.buscar('ab'),
      throwsA(isA<ErroApi>().having((e) => e.codigo, 'codigo', 'busca_curta')),
    );
  });

  test('token de acesso vai no cabeçalho e é renovado uma vez quando expira', () async {
    final tokens = ArmazenamentoTokensMemoria();
    await tokens.gravar(const Tokens(acesso: 'velho', renovacao: 'r1'));
    var chamadas = 0;
    final adaptador = _AdaptadorRenovacao(() => chamadas++);
    final api = cliente(AdaptadorFalso({}), tokens);
    api.dio.httpClientAdapter = adaptador;
    final r = await api.get<Map<String, dynamic>>('/v1/eu');
    expect(r['ok'], isTrue);
    expect((await tokens.ler())!.acesso, 'novo');
    expect(adaptador.cabecalhos, ['Bearer velho', 'Bearer novo']);
  });
}

class _AdaptadorRenovacao implements HttpClientAdapter {
  _AdaptadorRenovacao(this.aoChamar);
  final void Function() aoChamar;
  final cabecalhos = <String?>[];

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? _, Future<void>? _) async {
    aoChamar();
    ResponseBody json(int s, Object c) => ResponseBody.fromString(
      jsonEncode(c),
      s,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
    if (o.path == '/v1/auth/renovar') {
      return json(200, {'token_acesso': 'novo', 'token_renovacao': 'r2'});
    }
    cabecalhos.add(o.headers['Authorization'] as String?);
    if (o.headers['Authorization'] == 'Bearer velho') {
      return json(401, {'codigo': 'token_expirado', 'mensagem': '', 'detalhes': {}});
    }
    return json(200, {'ok': true});
  }

  @override
  void close({bool force = false}) {}
}
