import 'package:material_ui/material_ui.dart';

import '../../l10n/textos.dart';
import '../rede/erro_api.dart';
import '../tema/tema.dart';

/// Mensagem de erro que diz o que aconteceu e o que fazer, sem código técnico.
String mensagemDeErro(BuildContext context, Object erro) {
  final t = Textos.of(context);
  if (erro is ErroApi) {
    if (erro.semRede) return t.erroRede;
    if (erro.codigo == 'token_expirado') return t.erroSessao;
    if (erro.mensagem.isNotEmpty) return erro.mensagem;
  }
  return t.erroGenerico;
}

class EstadoErro extends StatelessWidget {
  const EstadoErro({super.key, required this.erro, this.aoTentarDeNovo});
  final Object erro;
  final VoidCallback? aoTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    return Padding(
      padding: const EdgeInsets.all(Espaco.l),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_outlined, size: 32, color: context.cores.tintaFraca),
          const SizedBox(height: Espaco.s),
          Text(mensagemDeErro(context, erro),
              textAlign: TextAlign.center, style: context.estilos.corpo),
          if (aoTentarDeNovo != null) ...[
            const SizedBox(height: Espaco.m),
            OutlinedButton(onPressed: aoTentarDeNovo, child: Text(t.tentarNovamente)),
          ],
        ],
      ),
    );
  }
}

class EstadoVazio extends StatelessWidget {
  const EstadoVazio({super.key, required this.mensagem, this.icone = Icons.menu_book_outlined,
      this.acao});
  final String mensagem;
  final IconData icone;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Espaco.l),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 32, color: context.cores.tintaFraca),
          const SizedBox(height: Espaco.s),
          Text(mensagem, textAlign: TextAlign.center, style: context.estilos.corpoFraco),
          if (acao != null) ...[const SizedBox(height: Espaco.m), acao!],
        ],
      ),
    );
  }
}

/// Bloco de esqueleto: a forma do conteúdo enquanto carrega, sem indicador giratório.
class BlocoEsqueleto extends StatefulWidget {
  const BlocoEsqueleto({super.key, this.largura, required this.altura, this.raio = 6,
      this.circulo = false});
  final double? largura;
  final double altura;
  final double raio;
  final bool circulo;

  @override
  State<BlocoEsqueleto> createState() => _BlocoEsqueletoState();
}

class _BlocoEsqueletoState extends State<BlocoEsqueleto> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respeita a preferência do sistema por movimento reduzido.
    if (MediaQuery.disableAnimationsOf(context)) {
      _anim.stop();
    } else if (!_anim.isAnimating) {
      _anim.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, _) => Container(
          width: widget.largura,
          height: widget.altura,
          decoration: BoxDecoration(
            color: Color.lerp(c.superficieSuave, c.pauta, _anim.value),
            shape: widget.circulo ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.circulo ? null : BorderRadius.circular(widget.raio),
          ),
        ),
      ),
    );
  }
}

/// Cartão de aviso discreto (procedência, estimativa, A5, revisão).
class Aviso extends StatelessWidget {
  const Aviso({super.key, required this.texto, this.icone = Icons.info_outline, this.forte = false});
  final String texto;
  final IconData icone;
  final bool forte;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Espaco.s),
      decoration: BoxDecoration(
        color: c.superficieSuave,
        borderRadius: BorderRadius.circular(Raio.campo),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 18, color: forte ? c.alertaForte : c.tinta),
          const SizedBox(width: Espaco.xs),
          Expanded(child: Text(texto, style: context.estilos.corpo.copyWith(fontSize: 14))),
        ],
      ),
    );
  }
}

/// Limita a largura de leitura em telas largas e aplica a margem lateral.
class LarguraLeitura extends StatelessWidget {
  const LarguraLeitura({super.key, required this.child, this.largura = Espaco.larguraLeitura});
  final Widget child;
  final double largura;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: largura),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Espaco.margemLateral),
          child: child,
        ),
      ),
    );
  }
}
