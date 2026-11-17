import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Tokens {
  const Tokens({required this.acesso, required this.renovacao});
  final String acesso;
  final String renovacao;
}

abstract interface class ArmazenamentoTokens {
  Future<Tokens?> ler();
  Future<void> gravar(Tokens tokens);
  Future<void> apagar();
}

class ArmazenamentoTokensSeguro implements ArmazenamentoTokens {
  ArmazenamentoTokensSeguro([FlutterSecureStorage? armazenamento])
      : _a = armazenamento ?? const FlutterSecureStorage();
  final FlutterSecureStorage _a;
  static const _chaveAcesso = 'token_acesso';
  static const _chaveRenovacao = 'token_renovacao';

  @override
  Future<Tokens?> ler() async {
    try {
      final acesso = await _a.read(key: _chaveAcesso);
      final renovacao = await _a.read(key: _chaveRenovacao);
      if (acesso == null || renovacao == null) return null;
      return Tokens(acesso: acesso, renovacao: renovacao);
    } catch (_) {
      return null; // armazenamento corrompido ou indisponível: segue sem sessão
    }
  }

  @override
  Future<void> gravar(Tokens tokens) async {
    await _a.write(key: _chaveAcesso, value: tokens.acesso);
    await _a.write(key: _chaveRenovacao, value: tokens.renovacao);
  }

  @override
  Future<void> apagar() async {
    await _a.delete(key: _chaveAcesso);
    await _a.delete(key: _chaveRenovacao);
  }
}

class ArmazenamentoTokensMemoria implements ArmazenamentoTokens {
  Tokens? _tokens;
  @override
  Future<Tokens?> ler() async => _tokens;
  @override
  Future<void> gravar(Tokens tokens) async => _tokens = tokens;
  @override
  Future<void> apagar() async => _tokens = null;
}
