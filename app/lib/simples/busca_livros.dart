// Descobre o livro de um ISBN: catálogo local, depois BrasilAPI, depois Google Books.
// O que vem das APIs fica guardado no aparelho (histórico e recentes mostram o nome sem
// consultar de novo).
//
// As duas APIs são gratuitas, sem chave, e aceitam chamadas do navegador (CORS).
//   BrasilAPI:    GET https://brasilapi.com.br/api/isbn/v1/{isbn}
//   Google Books: GET https://www.googleapis.com/books/v1/volumes?q=isbn:{isbn}

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'catalogo.dart';

/// Uma fonte externa: devolve o livro, null se não conhece o ISBN, ou lança
/// [SemConexao] quando não deu para consultar.
typedef FonteExterna = Future<Livro?> Function(String isbn);

class SemConexao implements Exception {
  const SemConexao();
}

sealed class ResultadoBusca {
  const ResultadoBusca();
}

class Encontrado extends ResultadoBusca {
  const Encontrado(this.livro);
  final Livro livro;
}

class NaoEncontrado extends ResultadoBusca {
  const NaoEncontrado();
}

/// Nenhuma fonte respondeu (sem internet, fora do ar). Vale tentar de novo.
class FalhaConsulta extends ResultadoBusca {
  const FalhaConsulta();
}

class BuscaLivros extends ChangeNotifier {
  BuscaLivros(this.catalogo, {List<FonteExterna>? fontes, Dio? dio})
    : _fontes = fontes ?? _fontesPadrao(dio ?? _dioPadrao());

  static const _chave = 'simples.livros_externos';

  final Catalogo catalogo;
  final List<FonteExterna> _fontes;
  final Map<String, Livro> _cache = {};

  /// Livro já conhecido (catálogo ou consultado antes), sem ir à internet.
  Livro? conhecido(String isbn) => catalogo.buscar(isbn) ?? _cache[isbn];

  Future<void> carregar() async {
    try {
      final texto = (await SharedPreferences.getInstance()).getString(_chave);
      if (texto == null) return;
      for (final j in (jsonDecode(texto) as List).cast<Map<String, dynamic>>()) {
        final l = Livro.fromJson(j);
        _cache[l.isbn] = l;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<ResultadoBusca> buscar(String isbn) async {
    final local = conhecido(isbn);
    if (local != null) return Encontrado(local);
    var falhas = 0;
    for (final fonte in _fontes) {
      try {
        final l = await fonte(isbn);
        if (l != null) {
          _cache[isbn] = l;
          notifyListeners();
          await _salvar();
          return Encontrado(l);
        }
      } on SemConexao {
        falhas++;
      } catch (_) {
        falhas++; // resposta inesperada: tenta a próxima fonte
      }
    }
    return falhas == _fontes.length ? const FalhaConsulta() : const NaoEncontrado();
  }

  Future<void> _salvar() async {
    try {
      await (await SharedPreferences.getInstance()).setString(
        _chave,
        jsonEncode([for (final l in _cache.values) l.toJson()]),
      );
    } catch (_) {}
  }
}

Dio _dioPadrao() => Dio(
  BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
    validateStatus: (s) => s != null && s < 500,
  ),
);

List<FonteExterna> _fontesPadrao(Dio dio) => [
  (isbn) => _pedir(dio, 'https://brasilapi.com.br/api/isbn/v1/$isbn', livroDaBrasilApi),
  (isbn) =>
      _pedir(dio, 'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn', livroDoGoogleBooks),
];

Future<Livro?> _pedir(
  Dio dio,
  String url,
  Livro? Function(Map<String, dynamic> json, String isbn) converter,
) async {
  final isbn = RegExp(r'(\d{13})').firstMatch(url)!.group(1)!;
  final Response<dynamic> r;
  try {
    r = await dio.get<dynamic>(url);
  } on DioException {
    throw const SemConexao();
  }
  if (r.statusCode == 404) return null;
  if (r.statusCode != 200 || r.data is! Map<String, dynamic>) throw const SemConexao();
  return converter(r.data as Map<String, dynamic>, isbn);
}

String _texto(Object? v) => v is String ? v.trim() : '';

/// Resposta da BrasilAPI: {isbn, title, subtitle, authors[], publisher, synopsis,
/// year, cover_url, ...}.
Livro? livroDaBrasilApi(Map<String, dynamic> j, String isbn) {
  final titulo = _texto(j['title']);
  if (titulo.isEmpty) return null;
  final subtitulo = _texto(j['subtitle']);
  return Livro(
    isbn: isbn,
    titulo: subtitulo.isEmpty ? titulo : '$titulo: $subtitulo',
    autor: [for (final a in (j['authors'] as List? ?? const [])) _texto(a)]
        .where((a) => a.isNotEmpty)
        .join(', '),
    editora: _texto(j['publisher']),
    ano: j['year'] == null ? '' : '${j['year']}',
    sinopse: _texto(j['synopsis']),
    capaUrl: _https(_texto(j['cover_url'])),
    fonte: FonteLivro.brasilApi,
  );
}

/// Resposta do Google Books: {totalItems, items: [{volumeInfo: {title, subtitle, authors,
/// publisher, publishedDate, description, imageLinks: {thumbnail}}}]}.
Livro? livroDoGoogleBooks(Map<String, dynamic> j, String isbn) {
  final itens = j['items'] as List? ?? const [];
  if (itens.isEmpty) return null;
  final v = (itens.first as Map<String, dynamic>)['volumeInfo'] as Map<String, dynamic>? ?? {};
  final titulo = _texto(v['title']);
  if (titulo.isEmpty) return null;
  final subtitulo = _texto(v['subtitle']);
  final imagens = v['imageLinks'] as Map<String, dynamic>? ?? const {};
  final data = _texto(v['publishedDate']);
  return Livro(
    isbn: isbn,
    titulo: subtitulo.isEmpty ? titulo : '$titulo: $subtitulo',
    autor: [for (final a in (v['authors'] as List? ?? const [])) _texto(a)]
        .where((a) => a.isNotEmpty)
        .join(', '),
    editora: _texto(v['publisher']),
    ano: data.length >= 4 ? data.substring(0, 4) : data,
    sinopse: _texto(v['description']),
    capaUrl: _https(_texto(imagens['thumbnail'] ?? imagens['smallThumbnail'])),
    fonte: FonteLivro.googleBooks,
  );
}

String? _https(String url) =>
    url.isEmpty ? null : url.replaceFirst(RegExp(r'^http://'), 'https://');
