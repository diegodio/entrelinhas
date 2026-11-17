import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/textos.dart';
import '../../nucleo/componentes/estados.dart';
import '../../nucleo/provedores.dart';
import '../../nucleo/rede/erro_api.dart';
import '../../nucleo/tema/tema.dart';
import '../conta/dados/conta_repositorio.dart';
import 'compras_loja.dart';

class TelaPlanos extends ConsumerStatefulWidget {
  const TelaPlanos({super.key});

  @override
  ConsumerState<TelaPlanos> createState() => _TelaPlanosState();
}

class _TelaPlanosState extends ConsumerState<TelaPlanos> {
  bool _enviando = false;

  Future<void> _assinar(String plano) async {
    final t = Textos.of(context);
    final mensageiro = ScaffoldMessenger.of(context);
    final usuario = ref.read(sessaoProvider).value;
    if (usuario == null) {
      await context.push('/entrar?depois=/planos');
      return;
    }
    setState(() => _enviando = true);
    try {
      final api = ref.read(clienteApiProvider);
      if (plano == 'familia' && ComprasLoja.disponivelNestaPlataforma) {
        await ComprasLoja(api).assinarFamilia();
      } else {
        final org = plano == 'escola' && usuario.organizacoes.isNotEmpty
            ? usuario.organizacoes.firstWhere(
                (o) => o.papel == 'gestor',
                orElse: () => usuario.organizacoes.first,
              )
            : null;
        final r = await api.post<Map<String, dynamic>>(
          '/v1/assinaturas/checkout',
          dados: {'plano': plano, 'organizacao_id': ?org?.organizacaoId},
        );
        if (r['provedor'] != 'falso') {
          await launchUrl(Uri.parse(r['url'] as String), webOnlyWindowName: '_self');
          return;
        }
      }
      await ref.read(sessaoProvider.notifier).recarregar();
      mensageiro.showSnackBar(SnackBar(content: Text(t.assinaturaAtivada)));
    } on ErroApi catch (e) {
      if (!mounted) return;
      mensageiro.showSnackBar(
        SnackBar(
          content: Text(
            e.codigo == 'pagamento_indisponivel'
                ? t.assinaturaIndisponivel
                : mensagemDeErro(context, e),
          ),
        ),
      );
    } catch (_) {
      mensageiro.showSnackBar(SnackBar(content: Text(t.assinaturaIndisponivel)));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final atual = ref.watch(sessaoProvider).value?.uso?.plano ?? 'gratuito';
    final limite = ref.watch(configuracaoProvider).consultasGratisMes;
    final planos = [
      ('gratuito', t.planoGratuito, t.planoGratuitoDescricao(limite), null),
      ('familia', t.planoFamilia, t.planoFamiliaDescricao, t.precoFamilia),
      ('escola', t.planoEscola, t.planoEscolaDescricao, t.precoEscola),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(t.planosTitulo)),
      body: SingleChildScrollView(
        child: LarguraLeitura(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (id, nome, descricao, preco) in planos) ...[
                _CartaoPlano(
                  nome: nome,
                  descricao: descricao,
                  preco: preco,
                  atual: atual == id,
                  acao: id == 'gratuito' || atual == id
                      ? null
                      : FilledButton(
                          onPressed: _enviando ? null : () => _assinar(id),
                          child: Text(t.botaoAssinar),
                        ),
                ),
                const SizedBox(height: Espaco.s),
              ],
              const SizedBox(height: Espaco.l),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartaoPlano extends StatelessWidget {
  const _CartaoPlano({
    required this.nome,
    required this.descricao,
    this.preco,
    required this.atual,
    this.acao,
  });
  final String nome;
  final String descricao;
  final String? preco;
  final bool atual;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final e = context.estilos;
    return Container(
      padding: const EdgeInsets.all(Espaco.m),
      decoration: BoxDecoration(
        color: c.superficie,
        border: Border.all(color: atual ? c.marca : c.pauta, width: atual ? 2 : 1),
        borderRadius: BorderRadius.circular(Raio.cartao),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(nome, style: e.tituloSecao)),
              if (atual)
                Text(Textos.of(context).planoAtual, style: e.rotulo.copyWith(color: c.marca)),
            ],
          ),
          if (preco != null) Text(preco!, style: e.destaque),
          const SizedBox(height: Espaco.xs),
          Text(descricao, style: e.corpo),
          if (acao != null) ...[const SizedBox(height: Espaco.s), acao!],
        ],
      ),
    );
  }
}
