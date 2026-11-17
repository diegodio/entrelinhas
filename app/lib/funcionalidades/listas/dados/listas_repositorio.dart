import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/provedores.dart';
import '../../../nucleo/rede/cliente_api.dart';
import '../../conta/dados/conta_repositorio.dart';
import '../../obras/dominio/modelos.dart';

class ResumoLista {
  const ResumoLista({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.quantidade,
    this.idadeReferencia,
    this.anoEscolar,
  });

  factory ResumoLista.fromJson(Map<String, dynamic> j) => ResumoLista(
    id: j['id'] as String,
    nome: j['nome'] as String,
    tipo: j['tipo'] as String? ?? 'pessoal',
    quantidade: (j['quantidade'] as num?)?.toInt() ?? 0,
    idadeReferencia: (j['idade_referencia'] as num?)?.toInt(),
    anoEscolar: j['ano_escolar'] as String?,
  );

  final String id;
  final String nome;
  final String tipo;
  final int quantidade;
  final int? idadeReferencia;
  final String? anoEscolar;
}

class ItemLista {
  const ItemLista({required this.obra, this.perfilId});
  factory ItemLista.fromJson(Map<String, dynamic> j) => ItemLista(
    obra: ObraResumo.fromJson(j['obra'] as Map<String, dynamic>),
    perfilId: j['perfil_id'] as String?,
  );
  final ObraResumo obra;
  final String? perfilId;
}

class ListaDetalhe {
  const ListaDetalhe({required this.resumo, required this.itens});
  factory ListaDetalhe.fromJson(Map<String, dynamic> j) => ListaDetalhe(
    resumo: ResumoLista.fromJson(j),
    itens: (j['itens'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map(ItemLista.fromJson)
        .toList(),
  );
  final ResumoLista resumo;
  final List<ItemLista> itens;
}

class ListasRepositorio {
  ListasRepositorio(this.api);
  final ClienteApi api;

  Future<List<ResumoLista>> listas() async =>
      (await api.get<List<dynamic>>('/v1/listas'))
          .cast<Map<String, dynamic>>()
          .map(ResumoLista.fromJson)
          .toList();

  Future<ListaDetalhe> lista(String id) async =>
      ListaDetalhe.fromJson(await api.get<Map<String, dynamic>>('/v1/listas/$id'));

  Future<ResumoLista> criar(String nome) async => ResumoLista.fromJson(
    await api.post<Map<String, dynamic>>('/v1/listas', dados: {'nome': nome}),
  );

  Future<void> excluir(String id) => api.delete<dynamic>('/v1/listas/$id');

  Future<void> adicionar(String listaId, String obraId, {String? perfilId}) => api.post<dynamic>(
    '/v1/listas/$listaId/itens',
    dados: {'obra_id': obraId, 'perfil_id': ?perfilId},
  );

  Future<void> remover(String listaId, String obraId) =>
      api.delete<dynamic>('/v1/listas/$listaId/itens/$obraId');
}

final listasRepositorioProvider = Provider<ListasRepositorio>(
  (ref) => ListasRepositorio(ref.watch(clienteApiProvider)),
);

final listasProvider = FutureProvider<List<ResumoLista>>((ref) async {
  final usuario = await ref.watch(sessaoProvider.future);
  if (usuario == null) return const [];
  return ref.watch(listasRepositorioProvider).listas();
});

final listaProvider = FutureProvider.autoDispose.family<ListaDetalhe, String>(
  (ref, id) => ref.watch(listasRepositorioProvider).lista(id),
);
