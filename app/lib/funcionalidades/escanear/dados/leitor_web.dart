// Web: a câmera vem do navegador (exige HTTPS) e não há leitura de quadros ao vivo com os
// pacotes usados. A captura é manual e o servidor lê o código de barras na foto.

import '../dominio/maquina_scanner.dart';
import 'leitor.dart';

class LeitorWeb implements LeitorDeCodigo {
  @override
  bool get aoVivo => false;
  @override
  Future<void> iniciar() async {}
  @override
  Future<Analise> analisar(QuadroCamera quadro) async => Analise.vazia;
  @override
  Future<void> encerrar() async {}
}

LeitorDeCodigo criarLeitorDaPlataforma() => LeitorWeb();
