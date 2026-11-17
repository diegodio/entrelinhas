import 'dart:async';

import 'package:dio/dio.dart';

import 'armazenamento_tokens.dart';
import 'erro_api.dart';

/// Cliente HTTP da API. Injeta o token de acesso e renova uma vez quando ele expira.
class ClienteApi {
  ClienteApi({
    required String urlBase,
    required this.tokens,
    Dio? dio,
    this.aoPerderSessao,
  }) : dio = dio ??
            Dio(BaseOptions(
              baseUrl: urlBase,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 30),
              headers: {'Accept': 'application/json'},
            )) {
    this.dio.interceptors.add(InterceptorsWrapper(
          onRequest: (opcoes, handler) async {
            final t = await tokens.ler();
            if (t != null && opcoes.extra['sem_auth'] != true) {
              opcoes.headers['Authorization'] = 'Bearer ${t.acesso}';
            }
            handler.next(opcoes);
          },
          onError: (erro, handler) async {
            final codigo = (erro.response?.data is Map)
                ? (erro.response!.data as Map)['codigo']
                : null;
            final jaTentou = erro.requestOptions.extra['renovado'] == true;
            if (erro.response?.statusCode == 401 && codigo == 'token_expirado' && !jaTentou) {
              if (await _renovar()) {
                final opcoes = erro.requestOptions..extra['renovado'] = true;
                try {
                  return handler.resolve(await this.dio.fetch(opcoes));
                } on DioException catch (e) {
                  return handler.next(e);
                }
              }
            }
            handler.next(erro);
          },
        ));
  }

  final Dio dio;
  final ArmazenamentoTokens tokens;
  final void Function()? aoPerderSessao;
  Future<bool>? _renovacaoEmAndamento;

  Future<bool> _renovar() {
    return _renovacaoEmAndamento ??= () async {
      try {
        final t = await tokens.ler();
        if (t == null) return false;
        final r = await dio.post<Map<String, dynamic>>(
          '/v1/auth/renovar',
          data: {'token_renovacao': t.renovacao},
          options: Options(extra: {'sem_auth': true}),
        );
        await tokens.gravar(Tokens(
          acesso: r.data!['token_acesso'] as String,
          renovacao: r.data!['token_renovacao'] as String,
        ));
        return true;
      } catch (_) {
        await tokens.apagar();
        aoPerderSessao?.call();
        return false;
      } finally {
        _renovacaoEmAndamento = null;
      }
    }();
  }

  Future<T> _executar<T>(Future<Response<dynamic>> Function() chamada) async {
    try {
      final r = await chamada();
      return r.data as T;
    } on DioException catch (e) {
      throw ErroApi.deDio(e);
    }
  }

  Future<T> get<T>(String caminho, {Map<String, dynamic>? query}) =>
      _executar(() => dio.get<dynamic>(caminho, queryParameters: query));

  Future<T> post<T>(String caminho, {Object? dados, Map<String, dynamic>? query}) =>
      _executar(() => dio.post<dynamic>(caminho, data: dados, queryParameters: query));

  Future<T> patch<T>(String caminho, {Object? dados}) =>
      _executar(() => dio.patch<dynamic>(caminho, data: dados));

  Future<T> put<T>(String caminho, {Object? dados}) =>
      _executar(() => dio.put<dynamic>(caminho, data: dados));

  Future<T> delete<T>(String caminho) => _executar(() => dio.delete<dynamic>(caminho));

  Future<List<int>> baixar(String caminho) async {
    try {
      final r = await dio.get<List<int>>(caminho,
          options: Options(responseType: ResponseType.bytes));
      return r.data!;
    } on DioException catch (e) {
      throw ErroApi.deDio(e);
    }
  }
}
