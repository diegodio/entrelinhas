import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/textos.dart';
import '../../nucleo/componentes/estados.dart';
import '../../nucleo/componentes/indicadores.dart';
import '../../nucleo/componentes/livros.dart';
import '../../nucleo/componentes/selo_faixa.dart';
import '../../nucleo/config/configuracao_servidor.dart';
import '../../nucleo/provedores.dart';
import '../../nucleo/tema/tema.dart';
import '../../nucleo/textos/rotulos.dart';
import '../conta/dados/conta_repositorio.dart';
import '../obras/dominio/modelos.dart';
import 'acoes_ficha.dart';
import 'estado_ficha.dart';

class TelaFicha extends ConsumerWidget {
  const TelaFicha({super.key, required this.obraId});

  final String obraId;

  /// Quando a ficha foi aberta pelo reconhecimento, mostra a faixa "É este o livro?".

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(fichaProvider(obraId));
    final t = Textos.of(context);
    final pronta = estado.value is FichaPronta ? estado.value! as FichaPronta : null;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.canPop() ? context.pop() : context.go('/')),
        actions: [
          if (pronta != null) ...[
            Padding(
              padding: const EdgeInsets.only(right: Espaco.xs),
              child: OutlinedButton(
                onPressed: () => salvarNaLista(context, ref, pronta.obra.resumo),
                child: Text(t.salvarNaLista),
              ),
            ),
            MenuFicha(estado: pronta),
          ],
        ],
      ),
      body: switch (estado) {
        AsyncData(:final value) => _Conteudo(estado: value),
        AsyncError(:final error) => Center(
          child: EstadoErro(
            erro: error,
            aoTentarDeNovo: () => ref.invalidate(fichaProvider(obraId)),
          ),
        ),
        _ => const EsqueletoFicha(),
      },
    );
  }
}

class _Conteudo extends ConsumerWidget {
  const _Conteudo({required this.estado});
  final EstadoFicha estado;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final larga = MediaQuery.sizeOf(context).width >= Espaco.larguraLarga;
    final cabecalho = <Widget>[CabecalhoObra(obra: estado.obra), const SizedBox(height: Espaco.l)];
    final List<Widget> principal;
    final List<Widget> detalhes;
    switch (estado) {
      case FichaPronta(:final ficha):
        principal = [
          BlocoSelo(faixa: ficha.faixaFinal, texto: ficha.textoRecomendacao),
          const SizedBox(height: Espaco.m),
          BlocoLeitor(faixa: ficha.faixaFinal),
          BlocoProcedencia(ficha: ficha),
        ];
        detalhes = blocosDetalhe(context, ref, ficha);
      case FichaPrecisaEntrar(:final resumo):
        principal = [
          if (resumo?.faixaFinal != null)
            BlocoSelo(faixa: resumo!.faixaFinal!, texto: resumo.textoRecomendacao ?? ''),
          const SizedBox(height: Espaco.m),
          _ChamadaEntrar(obraId: estado.obra.id),
        ];
        detalhes = const [];
      case FichaLimiteAtingido(:final resumo):
        principal = [
          if (resumo?.faixaFinal != null)
            BlocoSelo(faixa: resumo!.faixaFinal!, texto: resumo.textoRecomendacao ?? ''),
          const SizedBox(height: Espaco.m),
          const _ChamadaPlanos(),
        ];
        detalhes = const [];
      case FichaEmAnalise():
        principal = [const _EmAnalise()];
        detalhes = const [];
      case FichaInexistente(:final indisponivel):
        principal = [_SemFicha(obraId: estado.obra.id, indisponivel: indisponivel)];
        detalhes = const [];
    }
    final rodape = [const SizedBox(height: Espaco.l), const _Rodape(), const SizedBox(height: 48)];

    if (larga && detalhes.isNotEmpty) {
      return SingleChildScrollView(
        child: LarguraLeitura(
          largura: 1200,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Column(children: [...cabecalho, ...principal])),
              const SizedBox(width: 48),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [...detalhes, ...rodape],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SingleChildScrollView(
      child: LarguraLeitura(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [...cabecalho, ...principal, ...detalhes, ...rodape],
        ),
      ),
    );
  }
}

List<Widget> blocosDetalhe(BuildContext context, WidgetRef ref, Ficha ficha) {
  final cfg = ref.watch(configuracaoProvider);
  return [
    const SizedBox(height: Espaco.l),
    BlocoConteudoSensivel(ficha: ficha, config: cfg),
    if (cfg.podeExibir('camada_b')) BlocoAlertas(ficha: ficha),
    if (cfg.podeExibir('camada_c')) BlocoPerfilLeitura(ficha: ficha),
    if (cfg.podeExibir('valor_formativo')) BlocoValorFormativo(ficha: ficha),
  ];
}

// --------------------------------------------------------------------- blocos

class CabecalhoObra extends StatelessWidget {
  const CabecalhoObra({super.key, required this.obra});
  final ObraDetalhe obra;

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final e = context.estilos;
    final info = [?obra.genero, if (obra.paginas != null) t.paginasN(obra.paginas!)].join(' · ');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CapaLivro(url: obra.capaUrl, titulo: obra.titulo, largura: 108, altura: 160, sombra: true),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (obra.demonstracao)
                Padding(
                  padding: const EdgeInsets.only(bottom: Espaco.xxs),
                  child: Text(t.rotuloDemonstracaoLonga.toUpperCase(), style: e.rotuloMaiusculo),
                ),
              Semantics(header: true, child: Text(obra.titulo, style: e.tituloObra)),
              if (obra.autores.isNotEmpty) ...[
                const SizedBox(height: Espaco.xxs),
                Text(obra.autores.join(', '), style: e.apoio.copyWith(fontSize: 15)),
              ],
              if (info.isNotEmpty) ...[
                const SizedBox(height: Espaco.xxs),
                Text(info, style: e.apoio.copyWith(fontSize: 13)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class BlocoSelo extends StatelessWidget {
  const BlocoSelo({super.key, required this.faixa, required this.texto});
  final String faixa;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: Espaco.m),
      decoration: BoxDecoration(
        color: c.superficie,
        border: Border.all(color: c.pauta),
        borderRadius: BorderRadius.circular(Raio.cartao),
      ),
      child: Row(
        children: [
          SeloFaixa(faixa: faixa),
          const SizedBox(width: Espaco.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Textos.of(context).rotuloOrientacao, style: context.estilos.rotuloMaiusculo),
                const SizedBox(height: Espaco.xxs),
                Text(texto, style: context.estilos.destaque.copyWith(fontSize: 19)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BlocoLeitor extends ConsumerWidget {
  const BlocoLeitor({super.key, required this.faixa});
  final String faixa;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Textos.of(context);
    final comparacao = compararLeitor(
      ref.watch(leitorAtualProvider),
      faixa,
      ref.watch(relogioProvider)(),
    );
    final texto = switch (comparacao) {
      null => null,
      DentroDaFaixa(:final leitor, :final idade) => t.dentroDaFaixa(leitor.apelido, idade),
      AbaixoDaFaixa(:final leitor, :final idade, :final faixa) => t.acimaDaIdade(
        t.faixaEmFrase(faixa),
        leitor.apelido,
        idade,
      ),
    };
    if (texto == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: Espaco.m),
      child: Aviso(texto: texto, icone: Icons.person_outline),
    );
  }
}

class BlocoProcedencia extends ConsumerWidget {
  const BlocoProcedencia({super.key, required this.ficha});
  final Ficha ficha;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Textos.of(context);
    final cfg = ref.watch(configuracaoProvider);
    final p = ficha.procedencia;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.fonteAnalise(p.fonteDaAnalise), style: context.estilos.apoio),
        if (cfg.podeExibir('confianca')) ...[
          const SizedBox(height: Espaco.xs),
          BarraConfianca(confianca: p.confianca),
        ],
        if (ficha.emRevisao) ...[
          const SizedBox(height: Espaco.s),
          Aviso(texto: t.emRevisao, icone: Icons.rate_review_outlined),
        ] else if (p.revisadaPorHumano && cfg.podeExibir('selo_revisao_humana')) ...[
          const SizedBox(height: Espaco.s),
          Row(
            children: [
              Icon(Icons.verified_outlined, size: 18, color: context.cores.marca),
              const SizedBox(width: Espaco.xs),
              Text(
                t.revisadoHumano,
                style: context.estilos.rotulo.copyWith(color: context.cores.marca),
              ),
            ],
          ),
        ],
        if (ficha.semAcessoAoTexto) ...[
          const SizedBox(height: Espaco.s),
          Aviso(texto: t.avisoEstimativa),
        ],
      ],
    );
  }
}

class TituloSecao extends StatelessWidget {
  const TituloSecao(this.texto, {super.key});
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: Espaco.l, bottom: Espaco.xs),
    child: Semantics(header: true, child: Text(texto, style: context.estilos.tituloSecao)),
  );
}

class BlocoConteudoSensivel extends StatefulWidget {
  const BlocoConteudoSensivel({super.key, required this.ficha, required this.config});
  final Ficha ficha;
  final ConfiguracaoServidor config;

  @override
  State<BlocoConteudoSensivel> createState() => _BlocoConteudoSensivelState();
}

class _BlocoConteudoSensivelState extends State<BlocoConteudoSensivel> {
  final _abertos = <String>{};

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final f = widget.ficha;
    final cfg = widget.config;
    final a5Duro = (f.camadaA['A5']?.nivel ?? 0) >= 3;
    final eixos = idsEixos.where((e) => e != 'A6' || cfg.podeExibir('eixo_a6'));
    final temDetalhe =
        cfg.podeExibir('justificativa_eixo') || cfg.podeExibir('parafrase_evidencia');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TituloSecao(t.conteudoSensivel),
        for (final eixo in eixos) ...[
          LinhaEixo(
            eixo: eixo,
            nivel: f.camadaA[eixo]?.nivel ?? 0,
            determinante: eixo == f.eixoDeterminante && (f.camadaA[eixo]?.nivel ?? 0) > 0,
            aberto: _abertos.contains(eixo),
            aoTocar: temDetalhe && (f.camadaA[eixo]?.nivel ?? 0) > 0
                ? () => setState(
                    () => _abertos.contains(eixo) ? _abertos.remove(eixo) : _abertos.add(eixo),
                  )
                : null,
          ),
          if (_abertos.contains(eixo))
            _DetalheEixo(ficha: f, eixo: eixo, config: cfg, a5Duro: a5Duro),
          const Divider(),
        ],
        if (f.agravanteAcumuloAplicado) ...[
          const SizedBox(height: Espaco.s),
          Aviso(texto: t.notaAgravante),
        ],
        if (a5Duro) ...[
          const SizedBox(height: Espaco.s),
          Aviso(texto: t.avisoA5, icone: Icons.shield_outlined, forte: true),
        ],
      ],
    );
  }
}

class _DetalheEixo extends StatelessWidget {
  const _DetalheEixo({
    required this.ficha,
    required this.eixo,
    required this.config,
    required this.a5Duro,
  });
  final Ficha ficha;
  final String eixo;
  final ConfiguracaoServidor config;
  final bool a5Duro;

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final e = context.estilos;
    final justificativa = ficha.camadaA[eixo]?.justificativa ?? '';
    // Regra dura do A5: nunca exibir trecho literal, com qualquer combinação de flags.
    final mostrarTrecho = config.podeExibir('trechos_literais') && !(a5Duro && eixo == 'A5');
    return Padding(
      padding: const EdgeInsets.only(bottom: Espaco.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (config.podeExibir('justificativa_eixo') && justificativa.isNotEmpty)
            Text(justificativa, style: e.corpo),
          if (config.podeExibir('parafrase_evidencia'))
            for (final ev in ficha.evidenciasDo(eixo)) ...[
              const SizedBox(height: Espaco.xs),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Espaco.s),
                decoration: BoxDecoration(
                  color: context.cores.superficie,
                  border: Border(left: BorderSide(color: context.cores.pautaForte, width: 2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ev.parafrase, style: e.corpo.copyWith(fontSize: 14)),
                    if (mostrarTrecho && ev.trechoLiteral != null) ...[
                      const SizedBox(height: Espaco.xxs),
                      Text(
                        '“${ev.trechoLiteral}”',
                        style: e.corpo.copyWith(fontStyle: FontStyle.italic, fontSize: 14),
                      ),
                    ],
                    if (ev.fonte != null) ...[
                      const SizedBox(height: Espaco.xxs),
                      Text(t.evidenciaFonte(ev.fonte!), style: e.legenda),
                    ],
                  ],
                ),
              ),
            ],
        ],
      ),
    );
  }
}

class BlocoAlertas extends StatelessWidget {
  const BlocoAlertas({super.key, required this.ficha});
  final Ficha ficha;

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final flags = ficha.camadaB.flags;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TituloSecao(t.alertasConteudo),
        if (flags.isEmpty)
          Text(t.semAlertas, style: context.estilos.corpoFraco)
        else
          Wrap(
            spacing: Espaco.xs,
            runSpacing: Espaco.xs,
            children: [
              for (final f in flags)
                ChipAlerta(
                  rotulo: t.alerta(f),
                  aoTocar: ficha.camadaB.justificativas[f] == null
                      ? null
                      : () => showDialog<void>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(t.alerta(f)),
                            content: Text(ficha.camadaB.justificativas[f]!),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(t.ok),
                              ),
                            ],
                          ),
                        ),
                ),
            ],
          ),
      ],
    );
  }
}

class BlocoPerfilLeitura extends StatelessWidget {
  const BlocoPerfilLeitura({super.key, required this.ficha});
  final Ficha ficha;

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final c = ficha.camadaC;
    final e = context.estilos;
    final dimensoes = [
      (t.dimensaoVocabulario, c.vocabulario),
      (t.dimensaoEstrutura, c.estruturaNarrativa),
      (t.dimensaoDensidade, c.densidadeTematica),
      if (c.extensao != null) (t.dimensaoExtensao, c.extensao!),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TituloSecao(t.perfilLeitura),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.cores.superficieSuave,
            borderRadius: BorderRadius.circular(Raio.campo),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.nivelLeitura, style: e.rotulo),
              Text(c.rotuloNivelLeitura, style: e.destaque),
              const SizedBox(height: Espaco.s),
              for (final (nome, valor) in dimensoes)
                Semantics(
                  label: t.semanticaDimensao(nome, valor),
                  excludeSemantics: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(child: Text(nome, style: e.corpo.copyWith(fontSize: 14))),
                        BarraSegmentos(valor: valor, maximo: 5, largura: 100),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: Espaco.s),
        Text(t.repertorioQueAjuda, style: e.rotulo),
        const SizedBox(height: Espaco.xxs),
        if (c.exigenciaRepertorio.isEmpty)
          Text(t.semRepertorio, style: e.corpoFraco)
        else
          for (final item in c.exigenciaRepertorio) Text('• $item', style: e.corpo),
      ],
    );
  }
}

class BlocoValorFormativo extends StatelessWidget {
  const BlocoValorFormativo({super.key, required this.ficha});
  final Ficha ficha;

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final vf = ficha.camadaC.valorFormativo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TituloSecao(t.valorFormativo),
        Text(vf.nivel, style: context.estilos.destaque),
        if (vf.marcadores.isNotEmpty) ...[
          const SizedBox(height: Espaco.xs),
          Wrap(
            spacing: Espaco.xs,
            runSpacing: Espaco.xs,
            children: [for (final m in vf.marcadores) ChipAlerta(rotulo: t.marcador(m))],
          ),
        ],
        if (vf.justificativa.isNotEmpty) ...[
          const SizedBox(height: Espaco.xs),
          Text(vf.justificativa, style: context.estilos.corpo),
        ],
      ],
    );
  }
}

class _Rodape extends ConsumerWidget {
  const _Rodape();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Textos.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ref.watch(configuracaoProvider).podeExibir('metodologia'))
          TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () => context.push('/metodologia'),
            child: Text(t.comoClassificamos),
          ),
        Text(t.avisoIndependencia, style: context.estilos.legenda),
      ],
    );
  }
}

class _ChamadaEntrar extends StatelessWidget {
  const _ChamadaEntrar({required this.obraId});
  final String obraId;

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.entrarParaVerFicha, style: context.estilos.corpo),
        const SizedBox(height: Espaco.m),
        FilledButton(
          onPressed: () => context.push('/entrar?depois=/obra/$obraId'),
          child: Text(t.botaoEntrar),
        ),
        const SizedBox(height: Espaco.xs),
        OutlinedButton(
          onPressed: () => context.push('/cadastro?depois=/obra/$obraId'),
          child: Text(t.botaoCriarConta),
        ),
      ],
    );
  }
}

class _ChamadaPlanos extends StatelessWidget {
  const _ChamadaPlanos();

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.limiteAtingidoTitulo, style: context.estilos.destaque),
        const SizedBox(height: Espaco.xs),
        Text(t.limiteAtingidoTexto, style: context.estilos.corpo),
        const SizedBox(height: Espaco.m),
        FilledButton(onPressed: () => context.push('/planos'), child: Text(t.botaoVerPlanos)),
      ],
    );
  }
}

class _EmAnalise extends StatelessWidget {
  const _EmAnalise();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Aviso(texto: Textos.of(context).estadoAnalisando, icone: Icons.hourglass_top_outlined),
    );
  }
}

class _SemFicha extends ConsumerStatefulWidget {
  const _SemFicha({required this.obraId, required this.indisponivel});
  final String obraId;
  final bool indisponivel;

  @override
  ConsumerState<_SemFicha> createState() => _SemFichaState();
}

class _SemFichaState extends ConsumerState<_SemFicha> {
  bool _enviando = false;

  Future<void> _pedir() async {
    final t = Textos.of(context);
    final mensageiro = ScaffoldMessenger.of(context);
    final logado = ref.read(sessaoProvider).value != null;
    if (!logado) {
      await context.push('/entrar?depois=/obra/${widget.obraId}');
      return;
    }
    setState(() => _enviando = true);
    try {
      await ref.read(fichaProvider(widget.obraId).notifier).pedirAnalise();
      mensageiro.showSnackBar(SnackBar(content: Text(t.analisePedida)));
    } catch (e) {
      if (mounted) mensageiro.showSnackBar(SnackBar(content: Text(mensagemDeErro(context, e))));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Aviso(texto: widget.indisponivel ? t.estadoIndisponivel : t.estadoSemFicha),
        const SizedBox(height: Espaco.m),
        FilledButton(onPressed: _enviando ? null : _pedir, child: Text(t.botaoPedirAnalise)),
      ],
    );
  }
}

/// Esqueleto com a forma da ficha (não um indicador giratório no meio da tela).
class EsqueletoFicha extends StatelessWidget {
  const EsqueletoFicha({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: Textos.of(context).carregando,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: LarguraLeitura(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  BlocoEsqueleto(largura: 108, altura: 160, raio: 4),
                  SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlocoEsqueleto(largura: 180, altura: 26),
                        SizedBox(height: 8),
                        BlocoEsqueleto(largura: 120, altura: 16),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Espaco.l),
              const BlocoEsqueleto(altura: 108, raio: Raio.cartao),
              const SizedBox(height: Espaco.l),
              const BlocoEsqueleto(largura: 160, altura: 20),
              for (var i = 0; i < 6; i++) ...[
                const SizedBox(height: Espaco.m),
                const BlocoEsqueleto(altura: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
