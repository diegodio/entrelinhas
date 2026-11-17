import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/textos.dart';
import '../../nucleo/componentes/estados.dart';
import '../../nucleo/tema/tema.dart';
import '../conta/dados/conta_repositorio.dart';
import '../obras/dados/obras_repositorio.dart';
import 'tela_busca.dart';

/// Cadastro manual quando nenhuma fonte reconhece o ISBN.
class TelaCadastrarObra extends ConsumerStatefulWidget {
  const TelaCadastrarObra({super.key, this.isbn = ''});
  final String isbn;

  @override
  ConsumerState<TelaCadastrarObra> createState() => _TelaCadastrarObraState();
}

class _TelaCadastrarObraState extends ConsumerState<TelaCadastrarObra> {
  final _form = GlobalKey<FormState>();
  late final _isbn = TextEditingController(text: widget.isbn);
  final _titulo = TextEditingController();
  final _autores = TextEditingController();
  final _editora = TextEditingController();
  final _ano = TextEditingController();
  final _paginas = TextEditingController();
  bool _enviando = false;
  String? _erro;

  @override
  void dispose() {
    for (final c in [_isbn, _titulo, _autores, _editora, _ano, _paginas]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    if (ref.read(sessaoProvider).value == null) {
      await context.push('/entrar?depois=/cadastrar-obra?isbn=${_isbn.text}');
      return;
    }
    setState(() {
      _enviando = true;
      _erro = null;
    });
    try {
      final obra = await ref
          .read(obrasRepositorioProvider)
          .cadastrar(
            isbn: RegrasBusca.normalizarIsbn(_isbn.text),
            titulo: _titulo.text.trim(),
            autores: _autores.text
                .split(',')
                .map((a) => a.trim())
                .where((a) => a.isNotEmpty)
                .toList(),
            editora: _editora.text.trim().isEmpty ? null : _editora.text.trim(),
            ano: int.tryParse(_ano.text),
            paginas: int.tryParse(_paginas.text),
          );
      if (mounted) context.pushReplacement('/obra/${obra.id}');
    } catch (e) {
      if (mounted) setState(() => _erro = mensagemDeErro(context, e));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    String? obrigatorio(String? v) => (v ?? '').trim().isEmpty ? t.campoObrigatorio : null;
    return Scaffold(
      appBar: AppBar(title: Text(t.cadastroTitulo)),
      body: SingleChildScrollView(
        child: LarguraLeitura(
          largura: 560,
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _isbn,
                  decoration: InputDecoration(labelText: t.cadastroIsbn),
                  keyboardType: TextInputType.number,
                  validator: (v) => RegrasBusca.isbnValido(v ?? '') ? null : t.isbnInvalido,
                ),
                const SizedBox(height: Espaco.s),
                TextFormField(
                  controller: _titulo,
                  validator: obrigatorio,
                  decoration: InputDecoration(labelText: t.cadastroTituloObra),
                ),
                const SizedBox(height: Espaco.s),
                TextFormField(
                  controller: _autores,
                  decoration: InputDecoration(labelText: t.cadastroAutores),
                ),
                const SizedBox(height: Espaco.s),
                TextFormField(
                  controller: _editora,
                  decoration: InputDecoration(labelText: t.cadastroEditora),
                ),
                const SizedBox(height: Espaco.s),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ano,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: t.cadastroAno),
                      ),
                    ),
                    const SizedBox(width: Espaco.s),
                    Expanded(
                      child: TextFormField(
                        controller: _paginas,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: t.cadastroPaginas),
                      ),
                    ),
                  ],
                ),
                if (_erro != null) ...[
                  const SizedBox(height: Espaco.s),
                  Text(
                    _erro!,
                    style: context.estilos.corpo.copyWith(color: context.cores.alertaForte),
                  ),
                ],
                const SizedBox(height: Espaco.m),
                FilledButton(onPressed: _enviando ? null : _salvar, child: Text(t.salvar)),
                const SizedBox(height: Espaco.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
