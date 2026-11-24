// Catálogo fixo do modo simples (assets/catalogo.json): ISBN -> título e autor.

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class Livro {
  const Livro({required this.isbn, required this.titulo, this.autor = ''});
  final String isbn;
  final String titulo;
  final String autor;
}

class Catalogo {
  Catalogo(Iterable<Livro> livros) : _porIsbn = {for (final l in livros) l.isbn: l};

  factory Catalogo.deJson(String texto) {
    final j = jsonDecode(texto) as Map<String, dynamic>;
    return Catalogo([
      for (final l in (j['livros'] as List).cast<Map<String, dynamic>>())
        Livro(
          isbn: (l['isbn'] as String).replaceAll(RegExp(r'[\s-]'), ''),
          titulo: l['titulo'] as String,
          autor: l['autor'] as String? ?? '',
        ),
    ]);
  }

  static Future<Catalogo> carregar() async =>
      Catalogo.deJson(await rootBundle.loadString('assets/catalogo.json'));

  final Map<String, Livro> _porIsbn;

  List<Livro> get livros => _porIsbn.values.toList();
  Livro? buscar(String isbn) => _porIsbn[isbn.replaceAll(RegExp(r'[\s-]'), '')];
}
