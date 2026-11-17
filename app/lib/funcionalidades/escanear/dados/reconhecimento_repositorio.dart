import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/provedores.dart';
import '../../../nucleo/rede/cliente_api.dart';
import '../../obras/dominio/modelos.dart';

class CandidatoReconhecido {
  const CandidatoReconhecido({required this.obra, required this.pontuacao, this.sinais = const []});
  final ObraResumo obra;
  final double pontuacao;
  final List<String> sinais;
}

/// Resposta de POST /v1/reconhecimento.
class ResultadoReconhecimento {
  const ResultadoReconhecimento({
    required this.status,
    this.obra,
    this.candidatos = const [],
    this.isbn,
    this.amostraId,
  });

  factory ResultadoReconhecimento.fromJson(Map<String, dynamic> j) {
    ObraResumo? obra(Object? o) => o is Map<String, dynamic>
        ? ObraResumo.fromJson({...o, 'status_ficha': o['status_ficha'] ?? 'sem_ficha'})
        : null;
    return ResultadoReconhecimento(
      status: j['status'] as String,
      obra: obra(j['obra']),
      candidatos: [
        for (final c in (j['candidatos'] as List? ?? []).cast<Map<String, dynamic>>())
          if (obra(c['obra']) != null)
            CandidatoReconhecido(
              obra: obra(c['obra'])!,
              pontuacao: (c['pontuacao'] as num).toDouble(),
              sinais: (c['sinais'] as List? ?? []).cast<String>(),
            ),
      ],
      isbn: (j['sinais'] as Map?)?['isbn'] as String?,
      amostraId: j['amostra_id'] as String?,
    );
  }

  final String status; // identificado | candidatos | nao_identificado | nao_e_livro
  final ObraResumo? obra;
  final List<CandidatoReconhecido> candidatos;
  final String? isbn;
  final String? amostraId;
}

class ReconhecimentoRepositorio {
  ReconhecimentoRepositorio(this.api);
  final ClienteApi api;

  Future<ResultadoReconhecimento> enviar(
    List<int> jpeg, {
    required String dica,
    String? isbn,
  }) async {
    final dados = FormData.fromMap({
      'imagem': MultipartFile.fromBytes(
        jpeg,
        filename: 'captura.jpg',
        contentType: DioMediaType('image', 'jpeg'),
      ),
      'dica': dica,
      'isbn': ?isbn,
    });
    final json = await api.post<Map<String, dynamic>>('/v1/reconhecimento', dados: dados);
    return ResultadoReconhecimento.fromJson(json);
  }

  Future<void> corrigir(String amostraId, String obraId) =>
      api.post<dynamic>('/v1/reconhecimento/$amostraId/correcao', dados: {'obra_id': obraId});
}

final reconhecimentoRepositorioProvider = Provider<ReconhecimentoRepositorio>(
  (ref) => ReconhecimentoRepositorio(ref.watch(clienteApiProvider)),
);

/// Último resultado, usado por "Não é este" na ficha.
final ultimoReconhecimentoProvider =
    NotifierProvider<UltimoReconhecimento, ResultadoReconhecimento?>(UltimoReconhecimento.new);

class UltimoReconhecimento extends Notifier<ResultadoReconhecimento?> {
  @override
  ResultadoReconhecimento? build() => null;
  void definir(ResultadoReconhecimento? r) => state = r;
}
