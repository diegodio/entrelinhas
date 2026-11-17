import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/provedores.dart';
import '../../../nucleo/rede/cliente_api.dart';

class AcervoRepositorio {
  AcervoRepositorio(this.api);
  final ClienteApi api;

  Future<Map<String, dynamic>> organizacao(String id) =>
      api.get<Map<String, dynamic>>('/v1/organizacoes/$id');

  Future<Map<String, dynamic>> criarOrganizacao(String nome, String tipo) =>
      api.post<Map<String, dynamic>>('/v1/organizacoes', dados: {'nome': nome, 'tipo': tipo});

  Future<void> adicionarMembro(String org, String email, String papel) =>
      api.post<dynamic>('/v1/organizacoes/$org/membros', dados: {'email': email, 'papel': papel});

  Future<void> removerMembro(String org, String usuarioId) =>
      api.delete<dynamic>('/v1/organizacoes/$org/membros/$usuarioId');

  Future<Map<String, dynamic>> criarLista(
    String org, {
    required String nome,
    required String tipo,
    int? idade,
    String? ano,
  }) => api.post<Map<String, dynamic>>(
    '/v1/organizacoes/$org/listas',
    dados: {'nome': nome, 'tipo': tipo, 'idade_referencia': ?idade, 'ano_escolar': ?ano},
  );

  Future<Map<String, dynamic>> lista(String org, String lista) =>
      api.get<Map<String, dynamic>>('/v1/organizacoes/$org/listas/$lista');

  Future<String> importar(String org, String lista, List<int> csv, String nome) async {
    final r = await api.post<Map<String, dynamic>>(
      '/v1/organizacoes/$org/importacoes',
      dados: FormData.fromMap({
        'lista_id': lista,
        'arquivo': MultipartFile.fromBytes(
          csv,
          filename: nome,
          contentType: DioMediaType('text', 'csv'),
        ),
      }),
    );
    return r['tarefa_id'] as String;
  }

  Future<Map<String, dynamic>> andamento(String org, String tarefa) =>
      api.get<Map<String, dynamic>>('/v1/organizacoes/$org/importacoes/$tarefa');

  Future<Map<String, dynamic>> relatorio(String org, String lista) =>
      api.get<Map<String, dynamic>>('/v1/organizacoes/$org/listas/$lista/relatorio');

  Future<List<int>> relatorioArquivo(String org, String lista, String formato) =>
      api.baixar('/v1/organizacoes/$org/listas/$lista/relatorio?formato=$formato');
}

final acervoRepositorioProvider = Provider<AcervoRepositorio>(
  (ref) => AcervoRepositorio(ref.watch(clienteApiProvider)),
);

final organizacaoProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(acervoRepositorioProvider).organizacao(id),
);

final listaAcervoProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, (String, String)>(
      (ref, ids) => ref.watch(acervoRepositorioProvider).lista(ids.$1, ids.$2),
    );

final relatorioProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, (String, String)>(
  (ref, ids) => ref.watch(acervoRepositorioProvider).relatorio(ids.$1, ids.$2),
);
