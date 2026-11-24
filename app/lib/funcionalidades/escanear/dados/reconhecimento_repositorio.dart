import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/provedores.dart';
import '../../../nucleo/rede/cliente_api.dart';
import '../../obras/dominio/modelos.dart';

/// Resposta de POST /v1/reconhecimento (leitura do código de barras na foto).
class ResultadoReconhecimento {
  const ResultadoReconhecimento({required this.status, this.obra, this.isbn});

  factory ResultadoReconhecimento.fromJson(Map<String, dynamic> j) {
    final o = j['obra'];
    return ResultadoReconhecimento(
      status: j['status'] as String,
      obra: o is Map<String, dynamic>
          ? ObraResumo.fromJson({...o, 'status_ficha': o['status_ficha'] ?? 'sem_ficha'})
          : null,
      isbn: j['isbn'] as String?,
    );
  }

  /// identificado | nao_identificado (ISBN fora do catálogo) | nao_e_livro | sem_codigo
  final String status;
  final ObraResumo? obra;
  final String? isbn;
}

class ReconhecimentoRepositorio {
  ReconhecimentoRepositorio(this.api);
  final ClienteApi api;

  Future<ResultadoReconhecimento> enviar(List<int> jpeg) async {
    final dados = FormData.fromMap({
      'imagem': MultipartFile.fromBytes(
        jpeg,
        filename: 'captura.jpg',
        contentType: DioMediaType('image', 'jpeg'),
      ),
    });
    final json = await api.post<Map<String, dynamic>>('/v1/reconhecimento', dados: dados);
    return ResultadoReconhecimento.fromJson(json);
  }
}

final reconhecimentoRepositorioProvider = Provider<ReconhecimentoRepositorio>(
  (ref) => ReconhecimentoRepositorio(ref.watch(clienteApiProvider)),
);
