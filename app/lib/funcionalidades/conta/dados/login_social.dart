// Login com Google e Apple atrás de uma interface.
//
// A integração real depende de client IDs de cada plataforma e dos pacotes oficiais
// (google_sign_in, sign_in_with_apple). Eles não foram adicionados nesta versão porque não
// há credenciais neste ambiente para exercitá-los; a implementação padrão declara que
// nenhum provedor está disponível, e os botões não aparecem. O backend já verifica os
// ID tokens (app/provedores/login_social.py). Ver docs/como-rodar.md, "Login social".

import 'package:flutter_riverpod/flutter_riverpod.dart';

class CredencialSocial {
  const CredencialSocial({required this.idToken, this.nome});
  final String idToken;
  final String? nome;
}

class LoginSocialIndisponivel implements Exception {}

abstract interface class ProvedorLoginSocial {
  /// Provedores com botão na tela ("google", "apple").
  List<String> get disponiveis;

  /// Devolve o ID token, ou null se a pessoa cancelou.
  Future<CredencialSocial?> entrar(String provedor);
}

class LoginSocialDesligado implements ProvedorLoginSocial {
  const LoginSocialDesligado();
  @override
  List<String> get disponiveis => const [];
  @override
  Future<CredencialSocial?> entrar(String provedor) async => throw LoginSocialIndisponivel();
}

final loginSocialProvider = Provider<ProvedorLoginSocial>((ref) => const LoginSocialDesligado());
