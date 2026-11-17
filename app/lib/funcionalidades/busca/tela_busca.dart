import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/textos.dart';
import '../../nucleo/componentes/estados.dart';
import '../../nucleo/componentes/livros.dart';
import '../../nucleo/rede/erro_api.dart';
import '../../nucleo/tema/tema.dart';
import '../../nucleo/textos/rotulos.dart';
import '../obras/dados/obras_repositorio.dart';
import '../obras/dominio/modelos.dart';

/// Regras puras da busca (testáveis sem interface).
abstract final class RegrasBusca {
  static const minimo = 3;
  static const atraso = Duration(milliseconds: 350);

  static String normalizarIsbn(String texto) =>
      texto.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();

  /// Texto com 10 ou 13 dígitos (X final no de 10) é tratado como ISBN.
  static bool pareceIsbn(String texto) =>
      RegExp(r'^(\d{13}|\d{9}[\dX])$').hasMatch(normalizarIsbn(texto));

  static bool isbnValido(String texto) {
    final n = normalizarIsbn(texto);
    if (RegExp(r'^\d{13}$').hasMatch(n)) {
      var soma = 0;
      for (var i = 0; i < 12; i++) {
        soma += int.parse(n[i]) * (i.isEven ? 1 : 3);
      }
      return (10 - soma % 10) % 10 == int.parse(n[12]);
    }
    if (RegExp(r'^\d{9}[\dX]$').hasMatch(n)) {
      var soma = 0;
      for (var i = 0; i < 9; i++) {
        soma += (10 - i) * int.parse(n[i]);
      }
      soma += n[9] == 'X' ? 10 : int.parse(n[9]);
      return soma % 11 == 0;
    }
    return false;
  }
}

sealed class EstadoBusca {
  const EstadoBusca();
}

class BuscaOcioso extends EstadoBusca {
  const BuscaOcioso();
}

class BuscaCurta extends EstadoBusca {
  const BuscaCurta();
}

class BuscaIsbnInvalido extends EstadoBusca {
  const BuscaIsbnInvalido();
}

class BuscaCarregando extends EstadoBusca {
  const BuscaCarregando();
}

class BuscaResultado extends EstadoBusca {
  const BuscaResultado(this.resultado, this.termo);
  final ResultadoBusca resultado;
  final String termo;
}

class BuscaIsbnNaoEncontrado extends EstadoBusca {
  const BuscaIsbnNaoEncontrado(this.isbn);
  final String isbn;
}

class BuscaErro extends EstadoBusca {
  const BuscaErro(this.erro);
  final Object erro;
}

final buscaProvider = NotifierProvider.autoDispose<BuscaNotifier, EstadoBusca>(BuscaNotifier.new);

class BuscaNotifier extends Notifier<EstadoBusca> {
  Timer? _atraso;
  int _geracao = 0;

  @override
  EstadoBusca build() {
    ref.onDispose(() => _atraso?.cancel());
    return const BuscaOcioso();
  }

  /// Chamado a cada tecla: espera um pouco antes de buscar.
  void digitar(String termo) {
    _atraso?.cancel();
    final limpo = termo.trim();
    if (limpo.isEmpty) {
      state = const BuscaOcioso();
      return;
    }
    if (!RegrasBusca.pareceIsbn(limpo) && limpo.length < RegrasBusca.minimo) {
      state = const BuscaCurta();
      return;
    }
    _atraso = Timer(RegrasBusca.atraso, () => buscarAgora(limpo));
  }

  Future<void> buscarAgora(String termo) async {
    _atraso?.cancel();
    final limpo = termo.trim();
    if (RegrasBusca.pareceIsbn(limpo) && !RegrasBusca.isbnValido(limpo)) {
      state = const BuscaIsbnInvalido();
      return;
    }
    if (!RegrasBusca.pareceIsbn(limpo) && limpo.length < RegrasBusca.minimo) {
      state = const BuscaCurta();
      return;
    }
    final geracao = ++_geracao;
    state = const BuscaCarregando();
    try {
      final r = await ref.read(obrasRepositorioProvider).buscar(limpo);
      if (geracao != _geracao) return; // resposta de uma busca antiga
      state = (r.isbn != null && r.resultados.isEmpty)
          ? BuscaIsbnNaoEncontrado(r.isbn!)
          : BuscaResultado(r, limpo);
    } on ErroApi catch (e) {
      if (geracao != _geracao) return;
      state = switch (e.codigo) {
        'busca_curta' => const BuscaCurta(),
        'isbn_invalido' => const BuscaIsbnInvalido(),
        _ => BuscaErro(e),
      };
    }
  }
}

class TelaBusca extends ConsumerStatefulWidget {
  const TelaBusca({super.key, this.termoInicial = ''});
  final String termoInicial;

  @override
  ConsumerState<TelaBusca> createState() => _TelaBuscaState();
}

class _TelaBuscaState extends ConsumerState<TelaBusca> {
  late final _controle = TextEditingController(text: widget.termoInicial);

  @override
  void initState() {
    super.initState();
    if (widget.termoInicial.isNotEmpty) {
      Future.microtask(
          () => ref.read(buscaProvider.notifier).buscarAgora(widget.termoInicial));
    }
  }

  @override
  void dispose() {
    _controle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final estado = ref.watch(buscaProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.rotuloBuscar)),
      body: Column(
        children: [
          LarguraLeitura(
            child: TextField(
              controller: _controle,
              autofocus: widget.termoInicial.isEmpty,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: t.dicaBusca,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: ref.read(buscaProvider.notifier).digitar,
              onSubmitted: ref.read(buscaProvider.notifier).buscarAgora,
            ),
          ),
          const SizedBox(height: Espaco.s),
          Expanded(child: _Resultados(estado: estado, aoTentar: () {
            ref.read(buscaProvider.notifier).buscarAgora(_controle.text);
          })),
        ],
      ),
    );
  }
}

class _Resultados extends StatelessWidget {
  const _Resultados({required this.estado, required this.aoTentar});
  final EstadoBusca estado;
  final VoidCallback aoTentar;

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    return switch (estado) {
      BuscaOcioso() => const SizedBox.shrink(),
      BuscaCurta() => EstadoVazio(mensagem: t.buscaMinimo, icone: Icons.keyboard_outlined),
      BuscaIsbnInvalido() => EstadoVazio(mensagem: t.isbnInvalido, icone: Icons.pin_outlined),
      BuscaCarregando() => ListView(
          children: [
            for (var i = 0; i < 4; i++)
              const LarguraLeitura(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: Espaco.s),
                  child: Row(children: [
                    BlocoEsqueleto(largura: 44, altura: 64, raio: 3),
                    SizedBox(width: 14),
                    Expanded(child: BlocoEsqueleto(altura: 18)),
                  ]),
                ),
              ),
          ],
        ),
      BuscaIsbnNaoEncontrado(:final isbn) => EstadoVazio(
          mensagem: t.obraNaoEncontrada,
          acao: FilledButton(
            onPressed: () => context.push('/cadastrar-obra?isbn=$isbn'),
            child: Text(t.botaoCadastrarManual),
          ),
        ),
      BuscaErro(:final erro) => EstadoErro(erro: erro, aoTentarDeNovo: aoTentar),
      BuscaResultado(:final resultado) => ListView(
          children: [
            if (resultado.fontesExternasIndisponiveis)
              LarguraLeitura(child: Aviso(texto: t.buscaErroRede, icone: Icons.cloud_off)),
            if (resultado.resultados.isEmpty)
              EstadoVazio(mensagem: t.buscaVazia, icone: Icons.search_off)
            else
              for (final obra in resultado.resultados)
                LarguraLeitura(
                  child: Column(children: [
                    LinhaLivro(
                      obra: obra,
                      complemento: t.origem(obra.origem),
                      aoTocar: () => context.push('/obra/${obra.id}'),
                    ),
                    const Divider(),
                  ]),
                ),
          ],
        ),
    };
  }
}
