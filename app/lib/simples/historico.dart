// Histórico dos ISBNs escaneados, guardado no aparelho (shared_preferences).

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemHistorico {
  const ItemHistorico({required this.isbn, required this.quando});
  final String isbn;
  final DateTime quando;

  Map<String, dynamic> toJson() => {'isbn': isbn, 'quando': quando.toIso8601String()};
  factory ItemHistorico.fromJson(Map<String, dynamic> j) =>
      ItemHistorico(isbn: j['isbn'] as String, quando: DateTime.parse(j['quando'] as String));
}

class Historico extends ChangeNotifier {
  Historico({DateTime Function()? relogio}) : _relogio = relogio ?? DateTime.now;

  static const _chave = 'simples.historico';
  static const maximo = 50;

  final DateTime Function() _relogio;
  List<ItemHistorico> _itens = const [];

  /// Do mais recente para o mais antigo, sem repetir ISBN.
  List<ItemHistorico> get itens => _itens;

  Future<void> carregar() async {
    try {
      final texto = (await SharedPreferences.getInstance()).getString(_chave);
      if (texto != null) {
        _itens = [
          for (final j in (jsonDecode(texto) as List).cast<Map<String, dynamic>>())
            ItemHistorico.fromJson(j),
        ];
        notifyListeners();
      }
    } catch (_) {
      // Histórico ilegível ou armazenamento indisponível: começa vazio.
    }
  }

  Future<void> registrar(String isbn) async {
    _itens = [
      ItemHistorico(isbn: isbn, quando: _relogio()),
      for (final i in _itens)
        if (i.isbn != isbn) i,
    ].take(maximo).toList();
    notifyListeners();
    await _salvar();
  }

  Future<void> limpar() async {
    _itens = const [];
    notifyListeners();
    await _salvar();
  }

  Future<void> _salvar() async {
    try {
      await (await SharedPreferences.getInstance()).setString(
        _chave,
        jsonEncode([for (final i in _itens) i.toJson()]),
      );
    } catch (_) {}
  }
}

/// "Hoje, 14:05", "Ontem, 09:30" ou "12/11/2026".
String quandoLegivel(DateTime d, DateTime agora) {
  String dois(int n) => n.toString().padLeft(2, '0');
  final hora = '${dois(d.hour)}:${dois(d.minute)}';
  final dia = DateTime(d.year, d.month, d.day);
  final hoje = DateTime(agora.year, agora.month, agora.day);
  final diferenca = hoje.difference(dia).inDays;
  if (diferenca == 0) return 'Hoje, $hora';
  if (diferenca == 1) return 'Ontem, $hora';
  return '${dois(d.day)}/${dois(d.month)}/${d.year}';
}
