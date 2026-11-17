import 'dart:io';
import 'dart:math';

import 'package:entrelinhas/funcionalidades/busca/tela_busca.dart';
import 'package:entrelinhas/funcionalidades/obras/dominio/modelos.dart';
import 'package:entrelinhas/nucleo/componentes/selo_faixa.dart';
import 'package:entrelinhas/nucleo/config/configuracao_servidor.dart';
import 'package:entrelinhas/nucleo/tema/tema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'apoio.dart';

double _luminancia(Color c) {
  double canal(double v) => v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * canal(c.r) + 0.7152 * canal(c.g) + 0.0722 * canal(c.b);
}

double contraste(Color a, Color b) {
  final la = _luminancia(a), lb = _luminancia(b);
  return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
}

void main() {
  group('contraste (mínimo 4,5:1)', () {
    const c = CoresEntrelinhas.claro;
    for (final MapEntry(:key, :value) in c.faixas.entries) {
      test('selo $key', () => expect(contraste(value, c.sobreFaixa), greaterThanOrEqualTo(4.5)));
    }
    final pares = {
      'tinta/papel': (c.tinta, c.papel),
      'tinta/superficie': (c.tinta, c.superficie),
      'tintaFraca/papel': (c.tintaFraca, c.papel),
      'tintaFraca/superficie': (c.tintaFraca, c.superficie),
      'tintaFraca/superficieSuave': (c.tintaFraca, c.superficieSuave),
      'marca/papel': (c.marca, c.papel),
      'sobreMarca/marca': (c.sobreMarca, c.marca),
      'alertaForte/papel': (c.alertaForte, c.papel),
      'alertaForte/superficieSuave': (c.alertaForte, c.superficieSuave),
      'acento/superficie': (c.acento, c.superficie),
      'superficie/tinta (avisos)': (c.superficie, c.tinta),
    };
    pares.forEach((nome, par) {
      test(nome, () => expect(contraste(par.$1, par.$2), greaterThanOrEqualTo(4.5)));
    });
    // Cores de faixa usadas como texto na pílula, sobre papel e superfície.
    for (final MapEntry(:key, :value) in c.faixas.entries) {
      test('pílula $key sobre papel', () => expect(contraste(value, c.papel), greaterThanOrEqualTo(4.5)));
    }
  });

  group('regras da busca', () {
    test('reconhece ISBN', () {
      expect(RegrasBusca.pareceIsbn('978-85-359-0277-8'), isTrue);
      expect(RegrasBusca.pareceIsbn('080442957x'), isTrue);
      expect(RegrasBusca.pareceIsbn('Dom Casmurro'), isFalse);
    });
    test('valida dígito verificador 10 e 13', () {
      expect(RegrasBusca.isbnValido('9788535902778'), isTrue);
      expect(RegrasBusca.isbnValido('9788535902779'), isFalse);
      expect(RegrasBusca.isbnValido('080442957X'), isTrue);
      expect(RegrasBusca.isbnValido('0306406153'), isFalse);
    });
  });

  group('configuração do servidor', () {
    test('chave desconhecida é erro, nunca verdadeiro', () {
      expect(() => ConfiguracaoServidor.padrao.podeExibir('inventada'),
          throwsA(isA<FlagDesconhecida>()));
    });
    test('valores iniciais da seção 4.8', () {
      expect(ConfiguracaoServidor.padrao.podeExibir('trechos_literais'), isFalse);
      expect(ConfiguracaoServidor.padrao.podeExibir('camada_b'), isTrue);
    });
    test('ignora chaves desconhecidas vindas do servidor', () {
      final c = ConfiguracaoServidor.fromJson({'flags': {'nova': true, 'camada_b': false}});
      expect(c.podeExibir('camada_b'), isFalse);
      expect(() => c.podeExibir('nova'), throwsA(isA<FlagDesconhecida>()));
    });
  });

  test('idade mínima da faixa', () {
    expect(idadeMinimaDaFaixa('Livre'), 0);
    expect(idadeMinimaDaFaixa('16+'), 16);
  });

  test('a expressão do sistema oficial não aparece em nenhum arquivo de textos', () {
    final proibida = RegExp('classifica[cç][aã]o\\s+indicativa', caseSensitive: false);
    final arquivos = [
      ...Directory('lib').listSync(recursive: true).whereType<File>()
          .where((f) => f.path.endsWith('.dart') || f.path.endsWith('.arb')),
      File('../backend/app/core/textos.py'),
      File('../backend/app/api/publico.py'),
    ].where((f) => f.existsSync());
    expect(arquivos, isNotEmpty);
    for (final f in arquivos) {
      expect(proibida.hasMatch(f.readAsStringSync()), isFalse, reason: f.path);
    }
  });

  testWidgets('imagem de referência: selos de todas as faixas', (t) async {
    await carregarFontes();
    definirTela(t, const Size(560, 220));
    await t.pumpWidget(appDeTeste(Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Wrap(spacing: 12, children: [for (final f in faixasOrdenadas) SeloFaixa(faixa: f)]),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [
            for (final f in faixasOrdenadas) SeloFaixa(faixa: f, tamanho: 48),
            for (final f in faixasOrdenadas.take(3)) PilulaFaixa(faixa: f),
          ]),
        ]),
      ),
    )));
    await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/selos.png'));
  });
}
