// Web: a câmera vem do navegador (exige HTTPS) e não há análise de quadros ao vivo com
// os pacotes usados. A tela mostra a moldura-guia, a captura é manual e o servidor
// localiza o livro no quadro inteiro (dica "desconhecido").

import '../dominio/deteccao.dart';
import 'detector.dart';

class DetectorWeb implements DetectorDeLivro {
  @override
  bool get aoVivo => false;
  @override
  Future<void> iniciar() async {}
  @override
  Future<Analise> analisar(QuadroCamera quadro) async => Analise.vazia;
  @override
  Future<void> encerrar() async {}
}

DetectorDeLivro criarDetectorDaPlataforma() => DetectorWeb();
