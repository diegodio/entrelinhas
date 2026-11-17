import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../nucleo/rede/erro_api.dart';
import '../conta/dados/conta_repositorio.dart';
import '../conta/dominio/usuario.dart';
import '../obras/dados/obras_repositorio.dart';
import '../obras/dominio/modelos.dart';

sealed class EstadoFicha {
  const EstadoFicha(this.obra);
  final ObraDetalhe obra;
}

class FichaPronta extends EstadoFicha {
  const FichaPronta(super.obra, this.ficha, this.uso);
  final Ficha ficha;
  final Uso? uso;
}

class FichaEmAnalise extends EstadoFicha {
  const FichaEmAnalise(super.obra);
}

class FichaInexistente extends EstadoFicha {
  const FichaInexistente(super.obra, {this.indisponivel = false});
  final bool indisponivel;
}

class FichaPrecisaEntrar extends EstadoFicha {
  const FichaPrecisaEntrar(super.obra, this.resumo);
  final ResumoFicha? resumo;
}

class FichaLimiteAtingido extends EstadoFicha {
  const FichaLimiteAtingido(super.obra, this.resumo, this.uso);
  final ResumoFicha? resumo;
  final Uso? uso;
}

final fichaProvider =
    AsyncNotifierProvider.autoDispose.family<FichaNotifier, EstadoFicha, String>(FichaNotifier.new);

class FichaNotifier extends AsyncNotifier<EstadoFicha> {
  FichaNotifier(this.obraId);
  final String obraId;
  Timer? _atualizacao;

  /// Intervalo de atualização automática enquanto a obra está em análise.
  static Duration intervaloAnalise = const Duration(seconds: 4);

  @override
  Future<EstadoFicha> build() async {
    ref.onDispose(() => _atualizacao?.cancel());
    // Recarrega ao entrar ou sair da conta.
    ref.watch(sessaoProvider.select((s) => s.value?.id));
    final repo = ref.read(obrasRepositorioProvider);
    final obra = await repo.obter(obraId);
    final estado = await _carregarFicha(repo, obra);
    unawaited(ref.read(historicoProvider.notifier).registrar(
          estado is FichaPronta
              ? obra.resumo.copyWith(faixaFinal: estado.ficha.faixaFinal,
                  statusFicha: estado.ficha.status)
              : obra.resumo,
        ));
    _atualizacao?.cancel();
    if (estado is FichaEmAnalise) {
      _atualizacao = Timer(intervaloAnalise, () => ref.invalidateSelf());
    }
    return estado;
  }

  Future<EstadoFicha> _carregarFicha(ObrasRepositorio repo, ObraDetalhe obra) async {
    try {
      final r = await repo.ficha(obraId);
      if (r.ficha != null) return FichaPronta(obra, r.ficha!, r.uso);
      return _semFicha(obra, r.statusFicha);
    } on ErroApi catch (e) {
      final resumo = e.detalhes['resumo'];
      final resumoFicha = resumo is Map<String, dynamic> ? ResumoFicha.fromJson(resumo) : null;
      if (e.limiteAtingido) {
        final uso = e.detalhes['uso'];
        return FichaLimiteAtingido(
            obra, resumoFicha, uso is Map<String, dynamic> ? Uso.fromJson(uso) : null);
      }
      if (e.naoAutenticado) return FichaPrecisaEntrar(obra, resumoFicha);
      rethrow;
    }
  }

  EstadoFicha _semFicha(ObraDetalhe obra, String status) => switch (status) {
        'em_analise' => FichaEmAnalise(obra),
        'indisponivel' => FichaInexistente(obra, indisponivel: true),
        _ => FichaInexistente(obra),
      };

  Future<void> pedirAnalise() async {
    await ref.read(obrasRepositorioProvider).pedirAnalise(obraId);
    ref.invalidateSelf();
    await future;
  }
}

/// Comparação neutra entre a idade do leitor e a faixa (bloco "Para o leitor selecionado").
sealed class ComparacaoLeitor {
  const ComparacaoLeitor(this.leitor, this.idade);
  final PerfilLeitor leitor;
  final int idade;
}

class DentroDaFaixa extends ComparacaoLeitor {
  const DentroDaFaixa(super.leitor, super.idade);
}

class AbaixoDaFaixa extends ComparacaoLeitor {
  const AbaixoDaFaixa(super.leitor, super.idade, this.faixa);
  final String faixa;
}

ComparacaoLeitor? compararLeitor(PerfilLeitor? leitor, String faixa, DateTime hoje) {
  if (leitor == null) return null;
  final idade = leitor.idadeEm(hoje);
  return idade >= idadeMinimaDaFaixa(faixa)
      ? DentroDaFaixa(leitor, idade)
      : AbaixoDaFaixa(leitor, idade, faixa);
}
