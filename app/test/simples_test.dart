import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:entrelinhas/l10n/textos.dart';
import 'package:entrelinhas/nucleo/tema/tema.dart';
import 'package:entrelinhas/simples/catalogo.dart';
import 'package:entrelinhas/simples/ean13.dart';
import 'package:entrelinhas/simples/tela_leitor_simples.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

final catalogo = Catalogo(const [
  Livro(isbn: '9780306406157', titulo: 'O Livro de Teste', autor: 'Autora Fictícia'),
]);

Future<TelaLeitorSimplesState> abrir(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: TemaEntrelinhas.construir(),
      locale: const Locale('pt'),
      supportedLocales: Textos.supportedLocales,
      localizationsDelegates: const [
        Textos.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: TelaLeitorSimples(catalogo: catalogo, usarCamera: false),
    ),
  );
  return tester.state<TelaLeitorSimplesState>(find.byType(TelaLeitorSimples));
}

void main() {
  test('o catálogo do app tem 6 livros com ISBN de livro válido', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final c = Catalogo.deJson(await rootBundle.loadString('assets/catalogo.json'));
    expect(c.livros, hasLength(6));
    expect(c.buscar('9788543111537')?.titulo, startsWith('Murdoku'));
    for (final l in c.livros) {
      expect(digitoVerificadorOk(l.isbn), isTrue, reason: l.isbn);
      expect(l.isbn, startsWith('978'));
      expect(l.titulo, isNotEmpty);
    }
  });

  test('interpretar: cadastrado, não cadastrado, não é livro, sem código', () {
    expect(interpretar('9780306406157', catalogo), isA<LivroEncontrado>());
    expect(interpretar('978-0-306-40615-7'.replaceAll('-', ''), catalogo), isA<LivroEncontrado>());
    expect(interpretar('9788535902778', catalogo), isA<NaoCadastrado>());
    expect(interpretar('7891000315507', catalogo), isA<NaoELivro>());
    expect(interpretar(null, catalogo), isA<SemCodigo>());
  });

  testWidgets('mostra o nome do livro lido e volta a ler', (tester) async {
    final tela = await abrir(tester);
    expect(find.text('O Livro de Teste'), findsNothing);
    tela.mostrar('9780306406157');
    await tester.pump();
    expect(find.text('O Livro de Teste'), findsOneWidget);
    expect(find.textContaining('Autora Fictícia'), findsOneWidget);
    await tester.tap(find.text('Ler outro livro'));
    await tester.pump();
    expect(find.text('O Livro de Teste'), findsNothing);
  });

  testWidgets('ISBN fora do catálogo e código que não é de livro', (tester) async {
    final tela = await abrir(tester);
    tela.mostrar('9788535902778');
    await tester.pump();
    expect(find.text('Livro não cadastrado'), findsOneWidget);
    expect(find.textContaining('9788535902778'), findsWidgets);
    await tester.tap(find.text('Ler outro livro'));
    await tester.pump();
    tela.mostrar('7891000315507');
    await tester.pump();
    expect(find.textContaining('não é de um livro'), findsOneWidget);
  });

  testWidgets('lista dos livros cadastrados', (tester) async {
    await abrir(tester);
    await tester.tap(find.byTooltip('Livros cadastrados'));
    await tester.pumpAndSettle();
    expect(find.text('O Livro de Teste'), findsOneWidget);
  });
}
