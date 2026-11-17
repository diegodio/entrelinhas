// Apoio dos testes: fontes reais, repositórios falsos e um app mínimo com tema e textos.

import 'dart:io';

import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:entrelinhas/funcionalidades/conta/dados/conta_repositorio.dart';
import 'package:entrelinhas/funcionalidades/conta/dominio/usuario.dart';
import 'package:entrelinhas/funcionalidades/obras/dados/obras_repositorio.dart';
import 'package:entrelinhas/funcionalidades/obras/dominio/modelos.dart';
import 'package:entrelinhas/l10n/textos.dart';
import 'package:entrelinhas/nucleo/cache/cache_local.dart';
import 'package:entrelinhas/nucleo/config/configuracao_servidor.dart';
import 'package:entrelinhas/nucleo/provedores.dart';
import 'package:entrelinhas/nucleo/rede/armazenamento_tokens.dart';
import 'package:entrelinhas/nucleo/rede/cliente_api.dart';
import 'package:entrelinhas/nucleo/rede/erro_api.dart';
import 'package:entrelinhas/nucleo/tema/tema.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

bool _fontesCarregadas = false;

/// Carrega Fraunces, Nunito Sans e os ícones para que as imagens de referência
/// mostrem o texto de verdade (sem a fonte de blocos padrão dos testes).
Future<void> carregarFontes() async {
  if (_fontesCarregadas) return;
  _fontesCarregadas = true;
  Future<void> carregar(String familia, List<String> arquivos) async {
    final loader = FontLoader(familia);
    for (final a in arquivos) {
      loader.addFont(Future.value(ByteData.sublistView(File(a).readAsBytesSync())));
    }
    await loader.load();
  }

  await carregar('Fraunces', ['assets/fontes/Fraunces-Medium.ttf', 'assets/fontes/Fraunces-SemiBold.ttf']);
  await carregar('NunitoSans', [
    'assets/fontes/NunitoSans-Regular.ttf',
    'assets/fontes/NunitoSans-Italic.ttf',
    'assets/fontes/NunitoSans-SemiBold.ttf',
    'assets/fontes/NunitoSans-Bold.ttf',
  ]);
  final icones = File(
      '${Platform.environment['FLUTTER_ROOT'] ?? '/opt/sdk/flutter'}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (icones.existsSync()) {
    await carregar('MaterialIcons', [icones.path]);
  }
}

Widget appDeTeste(Widget filho, {List<Override> overrides = const [], Size? tamanho}) {
  return ProviderScope(
    overrides: overrides,
    retry: (_, _) => null,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: TemaEntrelinhas.construir(),
      locale: const Locale('pt'),
      supportedLocales: Textos.supportedLocales,
      localizationsDelegates: const [
        Textos.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: filho,
    ),
  );
}

void definirTela(WidgetTester tester, Size tamanho) {
  tester.view.physicalSize = tamanho;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

// --------------------------------------------------------------- dados

const obraJardim = ObraDetalhe(
  id: 'o1',
  titulo: 'O Jardim de Vidro',
  autores: ['Marina Alcântara'],
  genero: 'Romance',
  paginas: 312,
  faixaFinal: '14+',
  statusFicha: 'publicada',
  demonstracao: true,
);

Ficha fichaExemplo({
  Map<String, int> niveis = const {'A1': 2, 'A6': 2},
  List<Evidencia>? evidencias,
  List<String> flags = const ['luto', 'morte_de_personagem_principal'],
  String faixa = '14+',
  String recomendacao = 'com_mediacao',
  String texto = 'Recomendada com mediação de adulto a partir de 14 anos.',
  String fonte = 'fontes_publicas',
  bool revisada = false,
  String status = 'publicada',
  bool agravante = false,
  String determinante = 'A6',
}) {
  final faixas = {'A1': '12+', 'A6': '14+'};
  return Ficha(
    obraId: 'o1',
    versaoRubrica: '1.0',
    versaoFicha: 1,
    status: status,
    faixaFinal: faixa,
    faixaBase: faixa,
    agravanteAcumuloAplicado: agravante,
    eixoDeterminante: determinante,
    recomendacaoContextual: recomendacao,
    textoRecomendacao: texto,
    camadaA: {
      for (final e in idsEixos)
        e: EixoFicha(
          nivel: niveis[e] ?? 0,
          faixa: faixas[e] ?? 'Livre',
          justificativa: (niveis[e] ?? 0) > 0 ? 'Justificativa do eixo $e.' : '',
        ),
    },
    evidencias: evidencias ??
        const [
          Evidencia(eixo: 'A1', parafrase: 'Em uma discussão, o tio empurra o irmão.',
              fonte: 'sinopse da editora'),
          Evidencia(eixo: 'A6', parafrase: 'Lembrança de abuso narrada pela avó.',
              fonte: 'resenha pública'),
        ],
    camadaB: CamadaB(flags: flags),
    camadaC: const CamadaC(
      vocabulario: 3,
      estruturaNarrativa: 3,
      densidadeTematica: 3,
      extensao: 3,
      nivelLeitura: 3,
      rotuloNivelLeitura: 'Intermediário',
      exigenciaRepertorio: ['Familiaridade com narrativas em dois tempos'],
      valorFormativo: ValorFormativo(
        nivel: 'Alto',
        marcadores: ['empatia', 'desenvolvimento_moral'],
        justificativa: 'Trata de amizade e amadurecimento diante da perda.',
      ),
    ),
    procedencia: Procedencia(fonteDaAnalise: fonte, confianca: 0.6, revisadaPorHumano: revisada),
    atualizadaEm: '2026-11-01T12:00:00Z',
    slug: 'o-jardim-de-vidro-abc123',
  );
}

class ApiNula extends ClienteApi {
  ApiNula() : super(urlBase: 'http://teste', tokens: ArmazenamentoTokensMemoria());
}

class ObrasFalso extends ObrasRepositorio {
  ObrasFalso({this.obra = obraJardim, this.respostaFicha, this.erroFicha})
      : super(ApiNula(), CacheMemoria());

  final ObraDetalhe obra;
  final RespostaFicha? respostaFicha;
  final ErroApi? erroFicha;
  int pedidosAnalise = 0;

  @override
  Future<ObraDetalhe> obter(String id) async => obra;

  @override
  Future<RespostaFicha> ficha(String id) async {
    if (erroFicha != null) throw erroFicha!;
    return respostaFicha!;
  }

  @override
  Future<void> pedirAnalise(String id) async => pedidosAnalise++;
}

class ContaFalsa extends ContaRepositorio {
  ContaFalsa({this.usuario, this.leitoresIniciais = const []})
      : super(ApiNula(), ArmazenamentoTokensMemoria());
  final Usuario? usuario;
  final List<PerfilLeitor> leitoresIniciais;

  @override
  Future<Usuario?> sessaoAtual() async => usuario;

  @override
  Future<List<PerfilLeitor>> leitores() async => leitoresIniciais;
}

List<Override> overridesFicha({
  required ObrasFalso obras,
  ContaFalsa? conta,
  ConfiguracaoServidor config = ConfiguracaoServidor.padrao,
  String? leitorId,
  DateTime? hoje,
}) {
  return [
    obrasRepositorioProvider.overrideWithValue(obras),
    contaRepositorioProvider.overrideWithValue(conta ?? ContaFalsa()),
    cacheLocalProvider.overrideWithValue(CacheMemoria()),
    configuracaoServidorProvider.overrideWith((_) async => config),
    relogioProvider.overrideWithValue(() => hoje ?? DateTime(2026, 11, 16)),
    if (leitorId != null)
      leitorSelecionadoProvider.overrideWith(() => _LeitorFixo(leitorId)),
  ];
}

class _LeitorFixo extends LeitorSelecionado {
  _LeitorFixo(this.id);
  final String id;
  @override
  String? build() => id;
}
