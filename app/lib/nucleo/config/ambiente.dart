// Configuração de compilação. Passe valores com --dart-define.
//   flutter run --dart-define=API_URL=https://api.exemplo.com

import 'package:flutter/foundation.dart';

abstract final class Ambiente {
  static const _apiUrl = String.fromEnvironment('API_URL');

  /// URL base da API. Sem --dart-define, aponta para o backend local.
  static String get apiUrl {
    if (_apiUrl.isNotEmpty) return _apiUrl;
    // O emulador Android enxerga a máquina hospedeira em 10.0.2.2.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }

  /// Endereço público do app web (links compartilháveis de fichas).
  static const urlApp = String.fromEnvironment('URL_APP', defaultValue: 'http://localhost:8080');

  static const googleClientIdWeb = String.fromEnvironment('GOOGLE_CLIENT_ID_WEB');
  static const urlTermos = String.fromEnvironment('URL_TERMOS',
      defaultValue: 'https://entrelinhas.app/termos');
  static const urlPolitica = String.fromEnvironment('URL_POLITICA',
      defaultValue: 'https://entrelinhas.app/privacidade');
}
