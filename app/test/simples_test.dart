import 'dart:math';

import 'package:entrelinhas/simples/app_simples.dart';
import 'package:entrelinhas/simples/busca_livros.dart';
import 'package:entrelinhas/simples/catalogo.dart';
import 'package:entrelinhas/simples/componentes.dart';
import 'package:entrelinhas/simples/ean13.dart';
import 'package:entrelinhas/simples/historico.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

final catalogo = Catalogo(const [
  Livro(
    isbn: '9780306406157',
    titulo: 'O Livro de Teste',
    autor: 'Autora Fictícia',
    editora: 'Editora Exemplo',
  ),
  Livro(isbn: '9788543111537', titulo: 'Murdoku', autor: 'Manuel Garand'),
]);

/// Abre o app com um "leitor" que devolve os códigos da fila, um por vez.
Future<Historico> abrirApp(
  WidgetTester tester,
  List<String?> leituras, {
  List<FonteExterna> fontes = const [],
}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final historico = Historico(relogio: () => DateTime(2026, 11, 26, 10, 30));
  await tester.pumpWidget(
    AppSimples(
      catalogo: catalogo,
      historico: historico,
      abrirLeitor: (_) async => leituras.isEmpty ? null : leituras.removeAt(0),
      fontesExternas: fontes,
    ),
  );
  await tester.pumpAndSettle();
  return historico;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('o catálogo do app tem 6 livros com ISBN válido e o Murdoku', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final c = Catalogo.deJson(await rootBundle.loadString('assets/catalogo.json'));
    expect(c.livros, hasLength(6));
    for (final l in c.livros) {
      expect(digitoVerificadorOk(l.isbn), isTrue, reason: l.isbn);
      expect(l.isbn, startsWith('978'));
      expect(l.titulo, isNotEmpty);
    }
    expect(c.buscar('978-85-431-1153-7')?.titulo, startsWith('Murdoku'));
    expect(c.buscar('9788543111537')?.editora, 'Sextante');
  });

  test('busca por título, autor e ISBN, sem acento', () {
    expect(catalogo.filtrar('').length, 2);
    expect(catalogo.filtrar('livro de teste').single.isbn, '9780306406157');
    expect(catalogo.filtrar('autora ficticia').single.isbn, '9780306406157');
    expect(catalogo.filtrar('GARAND').single.titulo, 'Murdoku');
    expect(catalogo.filtrar('978-85-431').single.titulo, 'Murdoku');
    expect(catalogo.filtrar('xyz'), isEmpty);
  });

  test('histórico: mais recente primeiro, sem repetir, salvo no aparelho', () async {
    var agora = DateTime(2026, 11, 26, 9);
    final h = Historico(relogio: () => agora);
    await h.registrar('1');
    agora = agora.add(const Duration(minutes: 5));
    await h.registrar('2');
    await h.registrar('1');
    expect(h.itens.map((i) => i.isbn), ['1', '2']);
    final outro = Historico();
    await outro.carregar();
    expect(outro.itens.map((i) => i.isbn), ['1', '2']);
    await outro.limpar();
    expect(outro.itens, isEmpty);
  });

  test('capas: texto branco com contraste de 4,5:1 e cor estável por ISBN', () {
    double lum(Color c) {
      double canal(double v) => v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4).toDouble();
      final r = canal(c.r), g = canal(c.g), b = canal(c.b);
      return 0.2126 * r + 0.7152 * g + 0.0722 * b;
    }

    for (final tom in tonsCapa) {
      expect(1.05 / (lum(tom) + 0.05), greaterThanOrEqualTo(4.5), reason: '$tom');
    }
    expect(corDaCapa('9788543111537'), corDaCapa('9788543111537'));
  });

  group('busca externa', () {
    test('ordem: catálogo, depois as fontes na sequência', () async {
      final chamadas = <String>[];
      final b = BuscaLivros(
        catalogo,
        fontes: [
          (i) async {
            chamadas.add('brasil');
            return null;
          },
          (i) async {
            chamadas.add('google');
            return Livro(isbn: i, titulo: 'G', fonte: FonteLivro.googleBooks);
          },
        ],
      );
      expect(await b.buscar('9780306406157'), isA<Encontrado>());
      expect(chamadas, isEmpty); // estava no catálogo
      final r = await b.buscar('9788535902778');
      expect((r as Encontrado).livro.titulo, 'G');
      expect(chamadas, ['brasil', 'google']);
      expect(b.conhecido('9788535902778')?.titulo, 'G');
    });

    test('não encontrado x falha de todas as fontes', () async {
      final nada = BuscaLivros(catalogo, fontes: [(_) async => null, (_) async => null]);
      expect(await nada.buscar('9788535902778'), isA<NaoEncontrado>());
      final fora = BuscaLivros(
        catalogo,
        fontes: [(_) async => throw const SemConexao(), (_) async => throw const SemConexao()],
      );
      expect(await fora.buscar('9788535902778'), isA<FalhaConsulta>());
      final meio = BuscaLivros(
        catalogo,
        fontes: [(_) async => throw const SemConexao(), (_) async => null],
      );
      expect(await meio.buscar('9788535902778'), isA<NaoEncontrado>());
    });

    test('o que vem da internet fica guardado no aparelho', () async {
      final b = BuscaLivros(
        catalogo,
        fontes: [(i) async => Livro(isbn: i, titulo: 'Guardado', fonte: FonteLivro.brasilApi)],
      );
      await b.buscar('9788535902778');
      final depois = BuscaLivros(catalogo, fontes: const []);
      await depois.carregar();
      expect(depois.conhecido('9788535902778')?.titulo, 'Guardado');
      expect(depois.conhecido('9788535902778')?.fonte, FonteLivro.brasilApi);
    });

    test('converte a resposta da BrasilAPI', () {
      final l = livroDaBrasilApi({
        'isbn': '9788543111537',
        'title': 'Murdoku',
        'subtitle': '80 mistérios para resolver usando a lógica',
        'authors': ['Manuel Garand'],
        'publisher': 'Sextante',
        'synopsis': 'Quebra-cabeças.',
        'year': 2024,
        'cover_url': 'http://exemplo.org/capa.jpg',
      }, '9788543111537')!;
      expect(l.titulo, 'Murdoku: 80 mistérios para resolver usando a lógica');
      expect(l.autor, 'Manuel Garand');
      expect(l.editora, 'Sextante');
      expect(l.ano, '2024');
      expect(l.capaUrl, 'https://exemplo.org/capa.jpg');
      expect(l.fonte, FonteLivro.brasilApi);
      expect(livroDaBrasilApi({'title': ''}, '1'), isNull);
    });

    test('converte a resposta do Google Books', () {
      final l = livroDoGoogleBooks({
        'totalItems': 1,
        'items': [
          {
            'volumeInfo': {
              'title': 'O Pequeno Príncipe',
              'authors': ['Antoine de Saint-Exupéry', 'Tradução X'],
              'publisher': 'HarperCollins',
              'publishedDate': '2018-03-01',
              'description': 'Clássico.',
              'imageLinks': {'thumbnail': 'http://books.google.com/x.jpg'},
            },
          },
        ],
      }, '9788595081512')!;
      expect(l.titulo, 'O Pequeno Príncipe');
      expect(l.autor, 'Antoine de Saint-Exupéry, Tradução X');
      expect(l.ano, '2018');
      expect(l.capaUrl, 'https://books.google.com/x.jpg');
      expect(l.fonte, FonteLivro.googleBooks);
      expect(livroDoGoogleBooks({'totalItems': 0}, '1'), isNull);
    });
  });

  test('capas: catálogo/API primeiro, depois Open Library pelo ISBN', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const comCapa = Livro(isbn: '9788543111537', titulo: 'M', capaUrl: 'assets/capas/x.jpg');
    expect(fontesDeCapa(comCapa), [
      'assets/capas/x.jpg',
      'https://covers.openlibrary.org/b/isbn/9788543111537-M.jpg?default=false',
    ]);
    const semCapa = Livro(isbn: '9780306406157', titulo: 'T');
    expect(fontesDeCapa(semCapa, grande: true), [
      'https://covers.openlibrary.org/b/isbn/9780306406157-L.jpg?default=false',
    ]);
    // A capa do Murdoku (foto enviada pelo usuário) existe no app.
    final c = Catalogo.deJson(await rootBundle.loadString('assets/catalogo.json'));
    final capa = c.buscar('9788543111537')!.capaUrl!;
    expect((await rootBundle.load(capa)).lengthInBytes, greaterThan(10000));
  });

  test('datas legíveis', () {
    final agora = DateTime(2026, 11, 26, 18);
    expect(quandoLegivel(DateTime(2026, 11, 26, 9, 5), agora), 'Hoje, 09:05');
    expect(quandoLegivel(DateTime(2026, 11, 25, 22, 40), agora), 'Ontem, 22:40');
    expect(quandoLegivel(DateTime(2026, 10, 3, 8), agora), '03/10/2026');
  });

  testWidgets('início mostra busca, atalho e livros; a busca filtra', (tester) async {
    await abrirApp(tester, []);
    expect(find.text('Escanear um livro'), findsOneWidget);
    expect(find.text('O Livro de Teste'), findsWidgets);
    expect(find.text('Murdoku'), findsWidgets);
    await tester.enterText(find.byType(TextField), 'garand');
    await tester.pump();
    expect(find.text('O Livro de Teste'), findsNothing);
    expect(find.text('Murdoku'), findsWidgets);
    expect(find.text('1 resultado'), findsOneWidget);
  });

  testWidgets('escanear abre a página do livro e entra no histórico', (tester) async {
    final historico = await abrirApp(tester, ['9780306406157']);
    await tester.tap(find.byTooltip('Escanear'));
    await tester.pumpAndSettle();
    expect(find.text('Livro cadastrado'), findsOneWidget);
    expect(find.text('O Livro de Teste'), findsWidgets);
    expect(find.text('Editora Exemplo'), findsOneWidget);
    expect(historico.itens.single.isbn, '9780306406157');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Vistos recentemente'), findsOneWidget);
    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Hoje, 10:30'), findsOneWidget);
  });

  testWidgets('ISBN que ninguém conhece e "escanear outro"', (tester) async {
    await abrirApp(tester, ['9788535902778', '9788543111537'], fontes: [(_) async => null]);
    await tester.tap(find.byTooltip('Escanear'));
    await tester.pumpAndSettle();
    expect(find.text('Livro não encontrado'), findsWidgets);
    expect(find.textContaining('9788535902778'), findsWidgets);
    await tester.tap(find.text('Escanear outro livro'));
    await tester.pumpAndSettle();
    expect(find.text('Murdoku'), findsWidgets);
    expect(find.text('Livro cadastrado'), findsOneWidget);
  });

  testWidgets('ISBN fora do catálogo vem da API, com sinopse, e fica no histórico', (tester) async {
    const externo = Livro(
      isbn: '9788535902778',
      titulo: 'Livro da Internet',
      autor: 'Pessoa Autora',
      editora: 'Editora X',
      ano: '2004',
      sinopse: 'Uma história qualquer.',
      fonte: FonteLivro.brasilApi,
    );
    await abrirApp(tester, ['9788535902778'], fontes: [(_) async => externo]);
    await tester.tap(find.byTooltip('Escanear'));
    await tester.pumpAndSettle();
    expect(find.text('Encontrado na BrasilAPI'), findsOneWidget);
    expect(find.text('Uma história qualquer.'), findsOneWidget);
    expect(find.text('2004'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();
    expect(find.text('Livro da Internet'), findsWidgets);
  });

  testWidgets('sem conexão: avisa e deixa tentar de novo', (tester) async {
    var falhar = true;
    await abrirApp(
      tester,
      ['9788535902778'],
      fontes: [
        (isbn) async {
          if (falhar) throw const SemConexao();
          return Livro(isbn: isbn, titulo: 'Achado na segunda', fonte: FonteLivro.googleBooks);
        },
      ],
    );
    await tester.tap(find.byTooltip('Escanear'));
    await tester.pumpAndSettle();
    expect(find.text('Sem conexão'), findsOneWidget);
    falhar = false;
    await tester.tap(find.text('Tentar de novo'));
    await tester.pumpAndSettle();
    expect(find.text('Encontrado no Google Books'), findsOneWidget);
    expect(find.text('Achado na segunda'), findsWidgets);
  });

  testWidgets('fechar o leitor sem ler não muda nada', (tester) async {
    final historico = await abrirApp(tester, [null]);
    await tester.tap(find.byTooltip('Escanear'));
    await tester.pumpAndSettle();
    expect(find.text('Escanear um livro'), findsOneWidget);
    expect(historico.itens, isEmpty);
  });
}
