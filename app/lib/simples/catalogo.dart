// Catálogo fixo do modo simples (assets/catalogo.json): ISBN -> título e autor.

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// De onde veio o livro.
enum FonteLivro { catalogo, brasilApi, googleBooks }

class Livro {
  const Livro({
    required this.isbn,
    required this.titulo,
    this.autor = '',
    this.editora = '',
    this.ano = '',
    this.sinopse = '',
    this.capaUrl,
    this.fonte = FonteLivro.catalogo,
  });

  final String isbn;
  final String titulo;
  final String autor;
  final String editora;
  final String ano;
  final String sinopse;
  final String? capaUrl;
  final FonteLivro fonte;

  Map<String, dynamic> toJson() => {
    'isbn': isbn,
    'titulo': titulo,
    'autor': autor,
    'editora': editora,
    'ano': ano,
    'sinopse': sinopse,
    'capa_url': capaUrl,
    'fonte': fonte.name,
  };

  factory Livro.fromJson(Map<String, dynamic> j) => Livro(
    isbn: j['isbn'] as String,
    titulo: j['titulo'] as String,
    autor: j['autor'] as String? ?? '',
    editora: j['editora'] as String? ?? '',
    ano: j['ano'] as String? ?? '',
    sinopse: j['sinopse'] as String? ?? '',
    capaUrl: j['capa_url'] as String?,
    fonte: FonteLivro.values.asNameMap()[j['fonte']] ?? FonteLivro.catalogo,
  );
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
          editora: l['editora'] as String? ?? '',
        ),
    ]);
  }

  static Future<Catalogo> carregar() async =>
      Catalogo.deJson(await rootBundle.loadString('assets/catalogo.json'));

  final Map<String, Livro> _porIsbn;

  List<Livro> get livros => _porIsbn.values.toList();
  Livro? buscar(String isbn) => _porIsbn[isbn.replaceAll(RegExp(r'[\s-]'), '')];

  /// Busca por título, autor ou ISBN, sem diferenciar maiúsculas nem acentos.
  List<Livro> filtrar(String termo) {
    final t = semAcento(termo.trim());
    if (t.isEmpty) return livros;
    final digitos = termo.replaceAll(RegExp(r'[\s-]'), '');
    return [
      for (final l in livros)
        if (semAcento(l.titulo).contains(t) ||
            semAcento(l.autor).contains(t) ||
            (digitos.isNotEmpty && l.isbn.contains(digitos)))
          l,
    ];
  }
}

String semAcento(String s) {
  const de = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const para = 'aaaaaeeeeiiiiooooouuuucn';
  final b = StringBuffer();
  for (final ch in s.toLowerCase().split('')) {
    final i = de.indexOf(ch);
    b.write(i >= 0 ? para[i] : ch);
  }
  return b.toString();
}
