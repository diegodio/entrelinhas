import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Cache local do histórico e das fichas já abertas: a última ficha vista abre sem rede.
abstract interface class CacheLocal {
  Future<String?> ler(String chave);
  Future<void> gravar(String chave, String valor);
  Future<void> remover(String chave);
}

class CachePreferencias implements CacheLocal {
  SharedPreferences? _p;
  Future<SharedPreferences> get _prefs async => _p ??= await SharedPreferences.getInstance();

  @override
  Future<String?> ler(String chave) async {
    try {
      return (await _prefs).getString(chave);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> gravar(String chave, String valor) async {
    try {
      await (await _prefs).setString(chave, valor);
    } catch (_) {
      // Sem armazenamento local (navegação privada): o app segue sem cache.
    }
  }

  @override
  Future<void> remover(String chave) async {
    try {
      await (await _prefs).remove(chave);
    } catch (_) {}
  }
}

class CacheMemoria implements CacheLocal {
  final Map<String, String> dados = {};
  @override
  Future<String?> ler(String chave) async => dados[chave];
  @override
  Future<void> gravar(String chave, String valor) async => dados[chave] = valor;
  @override
  Future<void> remover(String chave) async => dados.remove(chave);
}

extension CacheJson on CacheLocal {
  Future<Object?> lerJson(String chave) async {
    final texto = await ler(chave);
    if (texto == null) return null;
    try {
      return jsonDecode(texto);
    } catch (_) {
      return null;
    }
  }

  Future<void> gravarJson(String chave, Object? valor) => gravar(chave, jsonEncode(valor));
}
