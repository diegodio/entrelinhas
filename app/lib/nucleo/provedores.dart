// Provedores de infraestrutura. Nos testes, sobrescreva-os com ProviderScope(overrides: ...).

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cache/cache_local.dart';
import 'config/ambiente.dart';
import 'config/configuracao_servidor.dart';
import 'rede/armazenamento_tokens.dart';
import 'rede/cliente_api.dart';

final armazenamentoTokensProvider = Provider<ArmazenamentoTokens>(
  (ref) => ArmazenamentoTokensSeguro(),
);

final cacheLocalProvider = Provider<CacheLocal>((ref) => CachePreferencias());

/// Avisado quando a renovação de sessão falha (o app volta ao estado deslogado).
final sessaoPerdidaProvider = NotifierProvider<SessaoPerdida, int>(SessaoPerdida.new);

class SessaoPerdida extends Notifier<int> {
  @override
  int build() => 0;
  void avisar() => state++;
}

final clienteApiProvider = Provider<ClienteApi>((ref) {
  return ClienteApi(
    urlBase: Ambiente.apiUrl,
    tokens: ref.watch(armazenamentoTokensProvider),
    aoPerderSessao: () => ref.read(sessaoPerdidaProvider.notifier).avisar(),
  );
});

const _chaveCacheConfig = 'configuracao_servidor';

/// Configuração do servidor, com o último valor conhecido como reserva sem rede.
final configuracaoServidorProvider = FutureProvider<ConfiguracaoServidor>((ref) async {
  final cache = ref.watch(cacheLocalProvider);
  try {
    final json = await ref.watch(clienteApiProvider).get<Map<String, dynamic>>('/v1/configuracao');
    await cache.gravarJson(_chaveCacheConfig, json);
    return ConfiguracaoServidor.fromJson(json);
  } catch (_) {
    final salvo = await cache.lerJson(_chaveCacheConfig);
    if (salvo is Map<String, dynamic>) return ConfiguracaoServidor.fromJson(salvo);
    return ConfiguracaoServidor.padrao;
  }
});

/// Atalho síncrono: usa o padrão enquanto a configuração carrega.
final configuracaoProvider = Provider<ConfiguracaoServidor>((ref) {
  return ref.watch(configuracaoServidorProvider).value ?? ConfiguracaoServidor.padrao;
});

/// Relógio injetável (idade dos leitores, testes determinísticos).
final relogioProvider = Provider<DateTime Function()>((ref) => DateTime.now);
