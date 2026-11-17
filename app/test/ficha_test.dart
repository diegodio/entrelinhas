import 'package:entrelinhas/funcionalidades/conta/dominio/usuario.dart';
import 'package:entrelinhas/funcionalidades/ficha/estado_ficha.dart';
import 'package:entrelinhas/funcionalidades/ficha/tela_ficha.dart';
import 'package:entrelinhas/funcionalidades/obras/dominio/modelos.dart';
import 'package:entrelinhas/nucleo/componentes/selo_faixa.dart';
import 'package:entrelinhas/nucleo/config/configuracao_servidor.dart';
import 'package:entrelinhas/nucleo/rede/erro_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'apoio.dart';

const _usuario = Usuario(id: 'u1', email: 'a@b.br');

Future<void> abrirFicha(WidgetTester tester, ObrasFalso obras,
    {ConfiguracaoServidor config = ConfiguracaoServidor.padrao,
    ContaFalsa? conta,
    String? leitorId,
    Size tamanho = const Size(390, 2600)}) async {
  definirTela(tester, tamanho);
  await tester.pumpWidget(appDeTeste(
    const TelaFicha(obraId: 'o1'),
    overrides: overridesFicha(obras: obras, config: config, conta: conta, leitorId: leitorId),
  ));
  await tester.pumpAndSettle();
}

ObrasFalso _pronta(Ficha ficha) =>
    ObrasFalso(respostaFicha: RespostaFicha(statusFicha: ficha.status, ficha: ficha));

void main() {
  setUpAll(carregarFontes);

  testWidgets('ficha pronta mostra selo, eixos, alertas, perfil e valor formativo', (t) async {
    await abrirFicha(t, _pronta(fichaExemplo()));
    expect(find.text('O Jardim de Vidro'), findsOneWidget);
    expect(find.byType(SeloFaixa), findsOneWidget);
    expect(find.text('Recomendada com mediação de adulto a partir de 14 anos.'), findsOneWidget);
    expect(find.text('Define a faixa'), findsOneWidget);
    expect(find.text('Luto'), findsOneWidget);
    expect(find.text('Intermediário'), findsOneWidget);
    expect(find.text('Alto'), findsOneWidget);
    expect(find.textContaining('estimativa gerada sem acesso ao texto'), findsOneWidget);
    expect(find.textContaining('sem vínculo com o Ministério da Justiça'), findsOneWidget);
  });

  testWidgets('imagem de referência: ficha completa', (t) async {
    await abrirFicha(t, _pronta(fichaExemplo(revisada: true)), tamanho: const Size(390, 1900));
    await t.tap(find.text('Abuso, trauma e opressão'));
    await t.pumpAndSettle();
    await expectLater(find.byType(TelaFicha), matchesGoldenFile('goldens/ficha_completa.png'));
  });

  testWidgets('imagem de referência: ficha em duas colunas na tela larga', (t) async {
    await abrirFicha(t, _pronta(fichaExemplo()), tamanho: const Size(1280, 1100));
    await expectLater(find.byType(TelaFicha), matchesGoldenFile('goldens/ficha_larga.png'));
  });

  testWidgets('A5 em nível 3: nenhum trecho literal, com qualquer combinação de flags', (t) async {
    final ficha = fichaExemplo(
      niveis: {'A5': 3, 'A1': 2},
      determinante: 'A5',
      faixa: '16+',
      evidencias: const [
        Evidencia(eixo: 'A5', parafrase: 'Cena descrita de forma neutra.',
            trechoLiteral: 'TRECHO PROIBIDO'),
        Evidencia(eixo: 'A1', parafrase: 'Briga breve.', trechoLiteral: 'TRECHO PERMITIDO'),
      ],
      fonte: 'texto_integral',
    );
    final config = ConfiguracaoServidor.padrao.comFlag('trechos_literais', true);
    await abrirFicha(t, _pronta(ficha), config: config);
    await t.tap(find.text('Risco à integridade'));
    await t.tap(find.text('Violência física'));
    await t.pumpAndSettle();
    expect(find.textContaining('TRECHO PROIBIDO'), findsNothing);
    expect(find.textContaining('TRECHO PERMITIDO'), findsOneWidget);
    expect(find.textContaining('não são reproduzidos por descreverem conduta de risco'),
        findsOneWidget);
  });

  testWidgets('trechos literais desligados não aparecem', (t) async {
    final ficha = fichaExemplo(
      evidencias: const [Evidencia(eixo: 'A1', parafrase: 'Briga.', trechoLiteral: 'TRECHO')],
      fonte: 'texto_integral',
    );
    await abrirFicha(t, _pronta(ficha));
    await t.tap(find.text('Violência física'));
    await t.pumpAndSettle();
    expect(find.textContaining('TRECHO'), findsNothing);
    expect(find.text('Briga.'), findsOneWidget);
  });

  for (final flag in ConfiguracaoServidor.chavesConhecidas) {
    testWidgets('desligar a flag "$flag" recompõe a ficha sem erro', (t) async {
      final config = ConfiguracaoServidor.padrao.comFlag(flag, false);
      await abrirFicha(t, _pronta(fichaExemplo()), config: config);
      expect(t.takeException(), isNull);
      expect(find.byType(SeloFaixa), findsOneWidget);
      final textos = {
        'camada_b': 'Alertas de conteúdo',
        'camada_c': 'Perfil de leitura',
        'valor_formativo': 'Valor formativo',
        'eixo_a6': 'Abuso, trauma e opressão',
        'confianca': 'Confiança da análise',
      };
      if (textos.containsKey(flag)) expect(find.text(textos[flag]!), findsNothing);
    });
  }

  testWidgets('limite atingido mantém selo e recomendação e oferece planos', (t) async {
    final obras = ObrasFalso(
      erroFicha: const ErroApi(codigo: 'limite_atingido', mensagem: '', status: 402, detalhes: {
        'resumo': {
          'obra_id': 'o1', 'slug': 's', 'status': 'publicada', 'faixa_final': '14+',
          'texto_recomendacao': 'Recomendada com mediação de adulto a partir de 14 anos.',
        },
      }),
    );
    await abrirFicha(t, obras, conta: ContaFalsa(usuario: _usuario));
    expect(find.byType(SeloFaixa), findsOneWidget);
    expect(find.text('Ver planos'), findsOneWidget);
    expect(find.text('Conteúdo sensível'), findsNothing);
    await expectLater(find.byType(TelaFicha), matchesGoldenFile('goldens/ficha_limite.png'));
  });

  testWidgets('sem conta: resumo e convite para entrar', (t) async {
    final obras = ObrasFalso(
      erroFicha: const ErroApi(codigo: 'nao_autenticado', mensagem: '', status: 401, detalhes: {
        'resumo': {'obra_id': 'o1', 'slug': 's', 'status': 'publicada', 'faixa_final': '14+',
          'texto_recomendacao': 'x'},
      }),
    );
    await abrirFicha(t, obras);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
  });

  testWidgets('em análise: mensagem e atualização automática', (t) async {
    FichaNotifier.intervaloAnalise = const Duration(milliseconds: 50);
    final obras = ObrasFalso(respostaFicha: const RespostaFicha(statusFicha: 'em_analise'));
    definirTela(t, const Size(390, 844));
    await t.pumpWidget(appDeTeste(const TelaFicha(obraId: 'o1'),
        overrides: overridesFicha(obras: obras)));
    await t.pump();
    await t.pump();
    expect(find.textContaining('Estamos analisando esta obra'), findsOneWidget);
    await t.pumpWidget(const SizedBox()); // descarta e cancela o temporizador
    await t.pump(const Duration(milliseconds: 100));
  });

  testWidgets('sem ficha: pedir análise exige conta', (t) async {
    final obras = ObrasFalso(respostaFicha: const RespostaFicha(statusFicha: 'sem_ficha'));
    await abrirFicha(t, obras, conta: ContaFalsa(usuario: _usuario));
    expect(find.textContaining('ainda sem ficha'), findsOneWidget);
    await t.tap(find.text('Pedir análise'));
    await t.pumpAndSettle();
    expect(obras.pedidosAnalise, 1);
  });

  testWidgets('leitor abaixo da faixa recebe orientação neutra', (t) async {
    final conta = ContaFalsa(
      usuario: _usuario,
      leitoresIniciais: const [PerfilLeitor(id: 'l1', apelido: 'Lia', anoNascimento: 2014)],
    );
    await abrirFicha(t, _pronta(fichaExemplo()), conta: conta, leitorId: 'l1');
    expect(
      find.text('A faixa é 14 anos; Lia tem 12. A orientação é leitura com mediação de adulto '
          'ou aguardar.'),
      findsOneWidget,
    );
  });

  testWidgets('ficha contestada mostra o aviso de revisão', (t) async {
    await abrirFicha(t, _pronta(fichaExemplo(status: 'em_revisao', revisada: true)));
    expect(find.text('Ficha em revisão após contestação'), findsOneWidget);
    expect(find.text('Revisado por editor humano'), findsNothing);
  });

  testWidgets('semântica do eixo descreve nível e rótulo', (t) async {
    final semantica = t.ensureSemantics();
    await abrirFicha(t, _pronta(fichaExemplo()));
    expect(find.bySemanticsLabel(RegExp(r'Violência física: nível 2 de 4, Moderado')),
        findsOneWidget);
    expect(find.bySemanticsLabel('Orientação de leitura: 14+'), findsOneWidget);
    semantica.dispose();
  });

  group('compararLeitor', () {
    final hoje = DateTime(2026, 11, 16);
    test('dentro da faixa', () {
      final r = compararLeitor(
          const PerfilLeitor(id: 'a', apelido: 'Téo', anoNascimento: 2010), '14+', hoje);
      expect(r, isA<DentroDaFaixa>());
      expect(r!.idade, 16);
    });
    test('abaixo da faixa', () {
      expect(compararLeitor(const PerfilLeitor(id: 'a', apelido: 'Téo', anoNascimento: 2016),
          '12+', hoje), isA<AbaixoDaFaixa>());
    });
    test('livre serve para todos e sem leitor não há bloco', () {
      expect(compararLeitor(const PerfilLeitor(id: 'a', apelido: 'Bia', anoNascimento: 2024),
          'Livre', hoje), isA<DentroDaFaixa>());
      expect(compararLeitor(null, '14+', hoje), isNull);
    });
  });
}
