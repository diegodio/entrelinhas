import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/provedores.dart';
import '../../../nucleo/rede/armazenamento_tokens.dart';
import '../../../nucleo/rede/cliente_api.dart';
import '../../../nucleo/rede/erro_api.dart';
import '../dominio/usuario.dart';

class ContaRepositorio {
  ContaRepositorio(this.api, this.tokens);
  final ClienteApi api;
  final ArmazenamentoTokens tokens;

  Future<Usuario> _guardar(Map<String, dynamic> json) async {
    await tokens.gravar(
      Tokens(acesso: json['token_acesso'] as String, renovacao: json['token_renovacao'] as String),
    );
    return eu();
  }

  Future<Usuario> entrar(String email, String senha) async => _guardar(
    await api.post<Map<String, dynamic>>(
      '/v1/auth/entrar',
      dados: {'email': email, 'senha': senha},
    ),
  );

  Future<Usuario> cadastrar({
    required String email,
    required String senha,
    required String nome,
  }) async => _guardar(
    await api.post<Map<String, dynamic>>(
      '/v1/auth/cadastro',
      dados: {'email': email, 'senha': senha, 'nome': nome, 'aceite_termos': true},
    ),
  );

  Future<Usuario> entrarComProvedor(String provedor, String idToken, {String? nome}) async =>
      _guardar(
        await api.post<Map<String, dynamic>>(
          '/v1/auth/$provedor',
          dados: {'id_token': idToken, 'nome': ?nome},
        ),
      );

  Future<void> recuperarSenha(String email) =>
      api.post<dynamic>('/v1/auth/recuperar', dados: {'email': email});

  Future<void> redefinirSenha(String token, String senha) =>
      api.post<dynamic>('/v1/auth/redefinir', dados: {'token': token, 'senha': senha});

  Future<Usuario?> sessaoAtual() async {
    if (await tokens.ler() == null) return null;
    try {
      return await eu();
    } on ErroApi catch (e) {
      if (e.naoAutenticado) {
        await tokens.apagar();
        return null;
      }
      rethrow;
    }
  }

  Future<Usuario> eu() async => Usuario.fromJson(await api.get<Map<String, dynamic>>('/v1/eu'));

  Future<Usuario> atualizar({String? nome, bool? contribuirImagens}) async => Usuario.fromJson(
    await api.patch<Map<String, dynamic>>(
      '/v1/eu',
      dados: {'nome': ?nome, 'contribuir_imagens': ?contribuirImagens},
    ),
  );

  Future<Map<String, dynamic>> exportarDados() =>
      api.get<Map<String, dynamic>>('/v1/eu/exportacao');

  Future<void> excluirConta() async {
    await api.delete<dynamic>('/v1/eu');
    await tokens.apagar();
  }

  Future<void> sair() async {
    final t = await tokens.ler();
    if (t != null) {
      try {
        await api.post<dynamic>('/v1/auth/sair', dados: {'token_renovacao': t.renovacao});
      } catch (_) {
        // Sair funciona mesmo sem rede: os tokens locais são apagados de qualquer forma.
      }
    }
    await tokens.apagar();
  }

  // ------------------------------------------------------------------ leitores

  Future<List<PerfilLeitor>> leitores() async {
    final lista = await api.get<List<dynamic>>('/v1/perfis');
    return lista.cast<Map<String, dynamic>>().map(PerfilLeitor.fromJson).toList();
  }

  Future<PerfilLeitor> salvarLeitor({
    String? id,
    required String apelido,
    required int anoNascimento,
    required String icone,
  }) async {
    final dados = {'apelido': apelido, 'ano_nascimento': anoNascimento, 'icone': icone};
    final json = id == null
        ? await api.post<Map<String, dynamic>>('/v1/perfis', dados: dados)
        : await api.put<Map<String, dynamic>>('/v1/perfis/$id', dados: dados);
    return PerfilLeitor.fromJson(json);
  }

  Future<void> excluirLeitor(String id) => api.delete<dynamic>('/v1/perfis/$id');
}

final contaRepositorioProvider = Provider<ContaRepositorio>(
  (ref) => ContaRepositorio(ref.watch(clienteApiProvider), ref.watch(armazenamentoTokensProvider)),
);

/// Usuário conectado (null = sem conta). Recarrega quando a sessão se perde.
final sessaoProvider = AsyncNotifierProvider<SessaoNotifier, Usuario?>(SessaoNotifier.new);

class SessaoNotifier extends AsyncNotifier<Usuario?> {
  @override
  Future<Usuario?> build() async {
    ref.listen(sessaoPerdidaProvider, (_, _) => state = const AsyncData(null));
    try {
      return await ref.read(contaRepositorioProvider).sessaoAtual();
    } on ErroApi catch (e) {
      if (e.semRede) return null;
      rethrow;
    }
  }

  ContaRepositorio get _repo => ref.read(contaRepositorioProvider);

  Future<void> entrar(String email, String senha) async =>
      state = AsyncData(await _repo.entrar(email, senha));

  Future<void> cadastrar(String email, String senha, String nome) async =>
      state = AsyncData(await _repo.cadastrar(email: email, senha: senha, nome: nome));

  Future<void> entrarComProvedor(String provedor, String idToken, {String? nome}) async =>
      state = AsyncData(await _repo.entrarComProvedor(provedor, idToken, nome: nome));

  Future<void> recarregar() async => state = AsyncData(await _repo.eu());

  Future<void> atualizar({String? nome, bool? contribuirImagens}) async =>
      state = AsyncData(await _repo.atualizar(nome: nome, contribuirImagens: contribuirImagens));

  Future<void> sair() async {
    await _repo.sair();
    state = const AsyncData(null);
  }

  Future<void> excluirConta() async {
    await _repo.excluirConta();
    state = const AsyncData(null);
  }
}

final leitoresProvider = AsyncNotifierProvider<LeitoresNotifier, List<PerfilLeitor>>(
  LeitoresNotifier.new,
);

class LeitoresNotifier extends AsyncNotifier<List<PerfilLeitor>> {
  @override
  Future<List<PerfilLeitor>> build() async {
    final usuario = await ref.watch(sessaoProvider.future);
    if (usuario == null) return const [];
    return ref.read(contaRepositorioProvider).leitores();
  }

  Future<void> salvar({
    String? id,
    required String apelido,
    required int ano,
    required String icone,
  }) async {
    await ref
        .read(contaRepositorioProvider)
        .salvarLeitor(id: id, apelido: apelido, anoNascimento: ano, icone: icone);
    ref.invalidateSelf();
    await future;
  }

  Future<void> excluir(String id) async {
    await ref.read(contaRepositorioProvider).excluirLeitor(id);
    if (ref.read(leitorSelecionadoProvider) == id) {
      await ref.read(leitorSelecionadoProvider.notifier).escolher(null);
    }
    ref.invalidateSelf();
    await future;
  }
}

/// Leitor escolhido em "Para quem é a leitura?". Lembrado localmente.
final leitorSelecionadoProvider = NotifierProvider<LeitorSelecionado, String?>(
  LeitorSelecionado.new,
);

class LeitorSelecionado extends Notifier<String?> {
  static const _chave = 'leitor_selecionado';

  @override
  String? build() {
    ref.read(cacheLocalProvider).ler(_chave).then((v) {
      if (v != null && v.isNotEmpty && state == null) state = v;
    });
    return null;
  }

  Future<void> escolher(String? id) async {
    state = id;
    await ref.read(cacheLocalProvider).gravar(_chave, id ?? '');
  }
}

final leitorAtualProvider = Provider<PerfilLeitor?>((ref) {
  final id = ref.watch(leitorSelecionadoProvider);
  final leitores = ref.watch(leitoresProvider).value ?? const [];
  for (final l in leitores) {
    if (l.id == id) return l;
  }
  return null;
});
