import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/textos.dart';
import '../../nucleo/componentes/estados.dart';
import '../../nucleo/provedores.dart';
import '../../nucleo/tema/tema.dart';
import '../../nucleo/textos/rotulos.dart';
import '../conta/dados/conta_repositorio.dart';
import '../ficha/estado_ficha.dart';
import '../obras/dominio/modelos.dart';

class TelaContestar extends ConsumerStatefulWidget {
  const TelaContestar({super.key, required this.obraId});
  final String obraId;

  @override
  ConsumerState<TelaContestar> createState() => _TelaContestarState();
}

class _TelaContestarState extends ConsumerState<TelaContestar> {
  String _campo = 'A1';
  final _texto = TextEditingController();
  bool _enviando = false;
  String? _erro;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final t = Textos.of(context);
    if (_texto.text.trim().length < 10) {
      setState(() => _erro = t.campoObrigatorio);
      return;
    }
    if (ref.read(sessaoProvider).value == null) {
      await context.push('/entrar?depois=/obra/${widget.obraId}/contestar');
      return;
    }
    setState(() {
      _enviando = true;
      _erro = null;
    });
    try {
      await ref
          .read(clienteApiProvider)
          .post<dynamic>(
            '/v1/obras/${widget.obraId}/contestacoes',
            dados: {'campo': _campo, 'texto': _texto.text.trim()},
          );
      ref.invalidate(fichaProvider(widget.obraId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.contestacaoEnviada)));
      context.pop();
    } catch (e) {
      if (mounted) setState(() => _erro = mensagemDeErro(context, e));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final opcoes = {
      for (final e in idsEixos) e: t.eixo(e),
      'camada_b': t.alertasConteudo,
      'camada_c': t.perfilLeitura,
      'valor_formativo': t.valorFormativo,
      'outro': t.campoOutro,
    };
    return Scaffold(
      appBar: AppBar(title: Text(t.contestarTitulo)),
      body: SingleChildScrollView(
        child: LarguraLeitura(
          largura: 560,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t.contestarExplicacao, style: context.estilos.corpo),
              const SizedBox(height: Espaco.m),
              DropdownMenu<String>(
                label: Text(t.campoContestado),
                expandedInsets: EdgeInsets.zero,
                initialSelection: _campo,
                onSelected: (v) => setState(() => _campo = v ?? 'outro'),
                dropdownMenuEntries: [
                  for (final MapEntry(:key, :value) in opcoes.entries)
                    DropdownMenuEntry(value: key, label: value),
                ],
              ),
              const SizedBox(height: Espaco.s),
              TextField(
                controller: _texto,
                minLines: 4,
                maxLines: 8,
                maxLength: 4000,
                decoration: InputDecoration(labelText: t.motivo, hintText: t.dicaMotivo),
              ),
              if (_erro != null)
                Text(
                  _erro!,
                  style: context.estilos.corpo.copyWith(color: context.cores.alertaForte),
                ),
              const SizedBox(height: Espaco.s),
              FilledButton(onPressed: _enviando ? null : _enviar, child: Text(t.botaoEnviar)),
              const SizedBox(height: Espaco.xl),
            ],
          ),
        ),
      ),
    );
  }
}
