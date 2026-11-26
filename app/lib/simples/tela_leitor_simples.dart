// Leitor do modo simples: câmera em tela cheia. Ao ler um ISBN de livro, fecha e devolve o
// código (Navigator.pop) para quem abriu, que mostra a página do livro.
//
// Leitura: no celular, ML Kit ao vivo (LeitorNativo); na web, uma foto da prévia a cada
// ~0,9 s lida pelo decodificador em Dart (ean13.dart). Galeria e "Digitar ISBN" também.

import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart' as permissao;

import '../funcionalidades/escanear/apresentacao/sobreposicao.dart';
import '../funcionalidades/escanear/dados/leitor.dart';
import '../funcionalidades/escanear/dominio/maquina_scanner.dart';
import '../l10n/textos.dart';
import '../nucleo/tema/tema.dart';
import 'ean13.dart';

class TelaLeitorSimples extends StatefulWidget {
  const TelaLeitorSimples({super.key, this.fabricaLeitor = criarLeitor, this.usarCamera = true});

  final LeitorDeCodigo Function() fabricaLeitor;

  /// Falso nos testes de widget (sem plugin de câmera).
  final bool usarCamera;

  @override
  State<TelaLeitorSimples> createState() => TelaLeitorSimplesState();
}

class TelaLeitorSimplesState extends State<TelaLeitorSimples> with WidgetsBindingObserver {
  static const _intervaloNativo = Duration(milliseconds: 110);
  static const _intervaloWeb = Duration(milliseconds: 900);
  static const _maquina = MaquinaScanner();

  CameraController? _camera;
  late final LeitorDeCodigo _leitor = widget.fabricaLeitor();
  EstadoScanner _estado = EstadoScanner.inicial;
  final _relogio = Stopwatch();
  Duration _ultimaAnalise = Duration.zero;
  bool _analisando = false;
  bool _lanterna = false;
  bool _semPermissao = false;
  bool _semCamera = false;
  Timer? _lacoWeb;
  bool _entregue = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.usarCamera) {
      _leitor.iniciar().then((_) => _iniciarCamera());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _soltarCamera();
    _leitor.encerrar();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.usarCamera) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _soltarCamera();
    } else if (state == AppLifecycleState.resumed && _camera == null && !_semPermissao) {
      _iniciarCamera();
    }
  }

  // ------------------------------------------------------------------ câmera

  Future<void> _iniciarCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _semCamera = true);
        return;
      }
      final traseira = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controle = CameraController(
        traseira,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: kIsWeb
            ? null
            : (defaultTargetPlatform == TargetPlatform.iOS
                  ? ImageFormatGroup.bgra8888
                  : ImageFormatGroup.nv21),
      );
      await controle.initialize();
      await controle.setFocusMode(FocusMode.auto).catchError((_) {});
      if (!mounted) {
        await controle.dispose();
        return;
      }
      _camera = controle;
      _relogio
        ..reset()
        ..start();
      setState(() => _semPermissao = false);
      _retomarLeitura();
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.code.startsWith('CameraAccess')) {
          _semPermissao = true;
        } else {
          _semCamera = true;
        }
      });
    }
  }

  void _soltarCamera() {
    _lacoWeb?.cancel();
    final c = _camera;
    _camera = null;
    _relogio.stop();
    if (c != null) {
      if (c.value.isStreamingImages) c.stopImageStream().catchError((_) {});
      c.dispose();
    }
  }

  void _retomarLeitura() {
    final c = _camera;
    if (c == null || _entregue) return;
    if (_leitor.aoVivo && !kIsWeb) {
      if (!c.value.isStreamingImages) c.startImageStream(_aoQuadro).catchError((_) {});
    } else {
      _lacoWeb?.cancel();
      _lacoWeb = Timer.periodic(_intervaloWeb, (_) => _fotografarELer());
    }
  }

  void _pausarLeitura() {
    _lacoWeb?.cancel();
    final c = _camera;
    if (c != null && c.value.isStreamingImages) c.stopImageStream().catchError((_) {});
  }

  // ----------------------------------------------------------------- leitura

  /// Celular: quadros do ML Kit.
  void _aoQuadro(CameraImage imagem) {
    final agora = _relogio.elapsed;
    if (_analisando || agora - _ultimaAnalise < _intervaloNativo || _entregue) return;
    _analisando = true;
    _ultimaAnalise = agora;
    _leitor
        .analisar(_converter(imagem))
        .then((analise) {
          if (!mounted || _entregue) return;
          setState(() => _estado = _maquina.aoAnalisar(_estado, analise, _relogio.elapsed));
          final isbn = _estado.isbn;
          if (_estado.fase == FaseScanner.consultando && isbn != null) entregar(isbn);
        })
        .catchError((_) {})
        .whenComplete(() => _analisando = false);
  }

  /// Web: tira uma foto da prévia e procura o código em Dart.
  Future<void> _fotografarELer() async {
    final c = _camera;
    if (_analisando || c == null || !c.value.isInitialized || _entregue) return;
    _analisando = true;
    try {
      final foto = await c.takePicture();
      final codigo = await lerEan13DeFoto(await foto.readAsBytes());
      if (!mounted || _entregue) return;
      if (codigo != null && eIsbnDeLivro(codigo)) {
        entregar(codigo);
      } else {
        setState(
          () => _estado = EstadoScanner(fase: FaseScanner.procurando, naoELivro: codigo != null),
        );
      }
    } catch (_) {
      // Uma foto falha de vez em quando (foco, troca de aba): tenta na próxima volta.
    } finally {
      _analisando = false;
    }
  }

  QuadroCamera _converter(CameraImage i) => QuadroCamera(
    largura: i.width,
    altura: i.height,
    formato: switch (i.format.group) {
      ImageFormatGroup.bgra8888 => FormatoQuadro.bgra8888,
      ImageFormatGroup.nv21 => FormatoQuadro.nv21,
      _ => FormatoQuadro.yuv420,
    },
    planos: [
      for (final p in i.planes)
        PlanoQuadro(bytes: p.bytes, bytesPorLinha: p.bytesPerRow, bytesPorPixel: p.bytesPerPixel),
    ],
    rotacao: _camera?.description.sensorOrientation ?? 90,
  );

  /// Código de livro: vibra, para a câmera e devolve o ISBN. Outro código ou nenhum: avisa
  /// e continua lendo.
  void entregar(String? codigo) {
    if (_entregue || !mounted) return;
    if (codigo == null || !eIsbnDeLivro(codigo)) {
      final t = Textos.of(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(codigo == null ? t.semCodigoNaFoto : t.naoELivro)));
      _retomarLeitura();
      return;
    }
    _entregue = true;
    HapticFeedback.mediumImpact();
    _pausarLeitura();
    Navigator.of(context).pop(codigo);
  }

  Future<void> _galeria() async {
    final arquivo = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (arquivo == null || !mounted) return;
    _pausarLeitura();
    entregar(await lerEan13DeFoto(await arquivo.readAsBytes()));
  }

  Future<void> _digitarIsbn() async {
    final t = Textos.of(context);
    final controle = TextEditingController();
    final isbn = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(t.digitarIsbnTitulo),
        content: TextField(
          controller: controle,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: '978-85-359-0277-8', labelText: t.cadastroIsbn),
          onSubmitted: (v) => Navigator.pop(c, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text(t.cancelar)),
          FilledButton(
            onPressed: () => Navigator.pop(c, controle.text),
            child: Text(t.botaoConsultar),
          ),
        ],
      ),
    );
    if (isbn == null || isbn.trim().isEmpty || !mounted) return;
    final limpo = isbn.replaceAll(RegExp(r'[\s-]'), '');
    if (!digitoVerificadorOk(limpo)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.isbnInvalido)));
      return;
    }
    entregar(limpo);
  }

  Future<void> _alternarLanterna() async {
    final c = _camera;
    if (c == null) return;
    try {
      await c.setFlashMode(_lanterna ? FlashMode.off : FlashMode.torch);
      setState(() => _lanterna = !_lanterna);
    } catch (_) {}
  }

  // -------------------------------------------------------------------- tela

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _corpo(context)),
            if (_camera != null && mostrarGuia(_estado, !kIsWeb))
              const Positioned.fill(bottom: 200, child: IgnorePointer(child: MolduraGuia())),
            Positioned(
              top: Espaco.xs,
              left: Espaco.xs,
              child: _BotaoRedondo(
                icone: Icons.close,
                rotulo: t.botaoFechar,
                aoTocar: () => Navigator.of(context).maybePop(),
              ),
            ),
            if (_camera != null)
              Positioned(
                top: Espaco.xs,
                right: Espaco.xs,
                child: _BotaoRedondo(
                  icone: _lanterna ? Icons.flashlight_off : Icons.flashlight_on,
                  rotulo: t.botaoLanterna,
                  aoTocar: _alternarLanterna,
                ),
              ),
            Positioned(left: 0, right: 0, bottom: 0, child: _painel(context)),
          ],
        ),
      ),
    );
  }

  Widget _corpo(BuildContext context) {
    final t = Textos.of(context);
    if (_semPermissao) {
      return _Explicacao(
        titulo: t.permissaoCameraTitulo,
        texto: t.permissaoCameraTexto,
        acao: FilledButton(
          onPressed: () => permissao.openAppSettings(),
          child: Text(t.botaoAbrirConfiguracoes),
        ),
      );
    }
    if (_semCamera) return _Explicacao(texto: t.semCamera);
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) {
      return widget.usarCamera
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : const SizedBox.expand();
    }
    final previa = camera.value.previewSize!;
    final larg = kIsWeb ? previa.width : previa.height;
    final alt = kIsWeb ? previa.height : previa.width;
    return ClipRect(
      child: OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: larg,
            height: alt,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(camera),
                SobreposicaoScanner(estado: _estado, aoVivo: !kIsWeb),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _painel(BuildContext context) {
    final t = Textos.of(context);
    final mensagem = switch (_estado) {
      EstadoScanner(naoELivro: true) => t.naoELivro,
      EstadoScanner(poucaLuz: true) => t.poucaLuz,
      _ => t.enquadre,
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(Espaco.m, Espaco.s, Espaco.m, Espaco.l),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00000000), Color(0xCC000000)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            liveRegion: true,
            child: Text(
              mensagem,
              textAlign: TextAlign.center,
              style: context.estilos.corpo.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: Espaco.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BotaoRedondo(
                icone: Icons.photo_library_outlined,
                rotulo: t.botaoGaleria,
                aoTocar: _galeria,
              ),
              _BotaoRedondo(
                icone: Icons.pin_outlined,
                rotulo: t.botaoDigitarIsbn,
                aoTocar: _digitarIsbn,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BotaoRedondo extends StatelessWidget {
  const _BotaoRedondo({required this.icone, required this.rotulo, required this.aoTocar});
  final IconData icone;
  final String rotulo;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: rotulo,
    onPressed: aoTocar,
    iconSize: 26,
    style: IconButton.styleFrom(
      backgroundColor: Colors.black45,
      foregroundColor: Colors.white,
      minimumSize: const Size(48, 48),
    ),
    icon: Icon(icone),
  );
}

class _Explicacao extends StatelessWidget {
  const _Explicacao({this.titulo, required this.texto, this.acao});
  final String? titulo;
  final String texto;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    final e = context.estilos;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Espaco.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_outlined, color: Colors.white, size: 40),
            const SizedBox(height: Espaco.m),
            if (titulo != null)
              Text(
                titulo!,
                textAlign: TextAlign.center,
                style: e.tituloSecao.copyWith(color: Colors.white),
              ),
            const SizedBox(height: Espaco.xs),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: e.corpo.copyWith(color: Colors.white),
            ),
            if (acao != null) ...[const SizedBox(height: Espaco.m), acao!],
            const SizedBox(height: 180),
          ],
        ),
      ),
    );
  }
}
