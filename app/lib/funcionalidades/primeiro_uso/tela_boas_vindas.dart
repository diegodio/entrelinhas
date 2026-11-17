import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/textos.dart';
import '../../nucleo/componentes/estados.dart';
import '../../nucleo/componentes/selo_faixa.dart';
import '../../nucleo/provedores.dart';
import '../../nucleo/tema/tema.dart';

const chavePrimeiroUso = 'primeiro_uso_concluido';

/// Já viu as boas-vindas? Lido do cache local; sem armazenamento, não insiste.
final primeiroUsoConcluidoProvider = FutureProvider<bool>((ref) async {
  return await ref.watch(cacheLocalProvider).ler(chavePrimeiroUso) == '1';
});

class TelaBoasVindas extends ConsumerStatefulWidget {
  const TelaBoasVindas({super.key});

  @override
  ConsumerState<TelaBoasVindas> createState() => _TelaBoasVindasState();
}

class _TelaBoasVindasState extends ConsumerState<TelaBoasVindas> {
  final _paginas = PageController();
  int _pagina = 0;

  Future<void> _concluir(String destino) async {
    await ref.read(cacheLocalProvider).gravar(chavePrimeiroUso, '1');
    ref.invalidate(primeiroUsoConcluidoProvider);
    if (mounted) context.go(destino);
  }

  @override
  void dispose() {
    _paginas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final e = context.estilos;
    final conteudos = [
      (t.boasVindas1Titulo, t.boasVindas1Texto, const Icon(Icons.qr_code_scanner, size: 72)),
      (t.boasVindas2Titulo, t.boasVindas2Texto, const SeloFaixa(faixa: '12+', tamanho: 88)),
      (
        t.boasVindas3Titulo,
        '${t.boasVindas3Texto}\n\n${t.avisoIndependencia}',
        const Icon(Icons.balance_outlined, size: 72),
      ),
    ];
    final ultima = _pagina == conteudos.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: () => _concluir('/'), child: Text(t.botaoPular)),
            ),
            Expanded(
              child: PageView(
                controller: _paginas,
                onPageChanged: (p) => setState(() => _pagina = p),
                children: [
                  for (final (titulo, texto, figura) in conteudos)
                    LarguraLeitura(
                      largura: 560,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconTheme(
                            data: IconThemeData(color: context.cores.marca),
                            child: figura,
                          ),
                          const SizedBox(height: Espaco.l),
                          Semantics(header: true, child: Text(titulo, style: e.tituloObra)),
                          const SizedBox(height: Espaco.s),
                          Text(texto, style: e.corpo.copyWith(fontSize: 16)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < conteudos.length; i++)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _pagina ? context.cores.marca : context.cores.pautaForte,
                    ),
                  ),
              ],
            ),
            LarguraLeitura(
              largura: 560,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Espaco.m),
                child: ultima
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FilledButton(
                            onPressed: () => _concluir('/cadastro'),
                            child: Text(t.botaoCriarConta),
                          ),
                          const SizedBox(height: Espaco.xs),
                          OutlinedButton(
                            onPressed: () => _concluir('/entrar'),
                            child: Text(t.botaoEntrar),
                          ),
                          TextButton(
                            onPressed: () => _concluir('/'),
                            child: Text(t.botaoUsarSemConta),
                          ),
                        ],
                      )
                    : FilledButton(
                        onPressed: () =>
                            _paginas.nextPage(duration: Movimento.medio, curve: Curves.easeOut),
                        child: Text(t.botaoContinuar),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
