import 'package:dio/dio.dart';

/// Erro no formato único da API: {codigo, mensagem, detalhes}.
class ErroApi implements Exception {
  const ErroApi({
    required this.codigo,
    required this.mensagem,
    this.detalhes = const {},
    this.status,
  });

  final String codigo;
  final String mensagem;
  final Map<String, dynamic> detalhes;
  final int? status;

  bool get semRede => codigo == 'sem_rede';
  bool get naoAutenticado => status == 401;
  bool get limiteAtingido => codigo == 'limite_atingido';

  static ErroApi deDio(DioException e) {
    final resposta = e.response;
    final dados = resposta?.data;
    if (dados is Map && dados['codigo'] is String) {
      return ErroApi(
        codigo: dados['codigo'] as String,
        mensagem: (dados['mensagem'] as String?) ?? '',
        detalhes: Map<String, dynamic>.from((dados['detalhes'] as Map?) ?? const {}),
        status: resposta?.statusCode,
      );
    }
    final semResposta = resposta == null &&
        (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.unknown);
    return ErroApi(
      codigo: semResposta ? 'sem_rede' : 'erro_http',
      mensagem: '',
      status: resposta?.statusCode,
    );
  }

  @override
  String toString() => 'ErroApi($codigo, $status): $mensagem';
}
