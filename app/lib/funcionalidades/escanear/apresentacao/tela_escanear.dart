import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart' as permissao;

import '../../../l10n/textos.dart';
import '../../../nucleo/componentes/estados.dart';
import '../../../nucleo/rede/erro_api.dart';
import '../../../nucleo/tema/tema.dart';
import '../../busca/tela_busca.dart';
import '../../obras/dados/obras_repositorio.dart';
import '../dados/leitor.dart';
import '../dados/reconhecimento_repositorio.dart';
import '../dados/recorte.dart';
import '../dominio/maquina_scanner.dart';
import 'sobreposicao.dart';

/// Fábrica do leitor de código (substituível nos testes).
final fabricaLeitorProvider = Provider<LeitorDeCodigo Function()>((ref) => criarLeitor);

class TelaEscanear extends ConsumerStatefulWidget {
  const TelaEscanear({super.key, this.abrirIsbn = false});

  /// Abre direto o diálogo de ISBN (vindo de "Digitar ISBN" no resultado).
  final bool abrirIsbn;

  @override
  ConsumerState<TelaEscanear> createState() => _TelaEscanearState();
}

class _TelaEscanearState extends ConsumerState<TelaEscanear> with WidgetsBindingObserver {
  static const _intervaloAnalise = Duration(milliseconds: 110); // ~9 análises por segundo
  static const _maquina = MaquinaScanner();

  CameraController? _camera;
  LeitorDeCodigo? _detector;
  EstadoScanner _estado = EstadoScanner.inicial;
  final _relogio = Stopwatch();
  Duration _ultimaAnalise = Duration.zero;
  bool _analisando = false;
  bool _lanterna = false;
  bool _semPermissao = false;
  bool _semCamera = false;
  // Guardados quando a rede falha, para "Tentar de novo" reenviar sem nova leitura.
  Uint8List? _capturaPendente;
  String? _isbnPendente;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _iniciar();
    if (widget.abrirIsbn) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _digitarIsbn());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _soltarCamera();
    _detector?.encerrar();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    // Em segundo plano, a câmera é liberada; ao voltar, reabre.
    if (estado == AppLifecycleState.inactive || estado == AppLifecycleState.paused) {
      _soltarCamera();
    } else if (estado == AppLifecycleState.resumed && _camera == null && !_semPermissao) {
      _iniciarCamera();
    }
  }

  Future<void> _iniciar() async {
    _detector = ref.read(fabricaLeitorProvider)();
    await _detector!.iniciar();
    await _iniciarCamera();
  }

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
      if (_detector!.aoVivo && !kIsWeb) {
        await controle.startImageStream(_aoQuadro);
      }
      setState(() {
        _semPermissao = false;
        _estado = _maquina.reiniciar(_estado);
      });
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
    final c = _camera;
    _camera = null;
    _relogio.stop();
    if (c != null) {
      if (c.value.isStreamingImages) c.stopImageStream().catchError((_) {});
      c.dispose();
    }
  }

  // ------------------------------------------------------------ análise ao vivo

  void _aoQuadro(CameraImage imagem) {
    final agora = _relogio.elapsed;
    if (_analisando || agora - _ultimaAnalise < _intervaloAnalise || !_estado.analisando) {
      return; // frequência limitada; quadros excedentes são descartados
    }
    _analisando = true;
    _ultimaAnalise = agora;
    final quadro = _converter(imagem);
    _detector!
        .analisar(quadro)
        .then((analise) {
          if (!mounted) return;
          final antes = _estado.fase;
          setState(() => _estado = _maquina.aoAnalisar(_estado, analise, _relogio.elapsed));
          final isbn = _estado.isbn;
          if (antes != FaseScanner.consultando &&
              _estado.fase == FaseScanner.consultando &&
              isbn != null) {
            HapticFeedback.mediumImpact();
            _pararAnalise();
            _consultarIsbn(isbn);
          }
        })
        .catchError((_) {})
        .whenComplete(() => _analisando = false);
  }

  QuadroCamera _converter(CameraImage i) {
    final formato = switch (i.format.group) {
      ImageFormatGroup.bgra8888 => FormatoQuadro.bgra8888,
      ImageFormatGroup.nv21 => FormatoQuadro.nv21,
      _ => FormatoQuadro.yuv420,
    };
    return QuadroCamera(
      largura: i.width,
      altura: i.height,
      formato: formato,
      planos: [
        for (final p in i.planes)
          PlanoQuadro(bytes: p.bytes, bytesPorLinha: p.bytesPerRow, bytesPorPixel: p.bytesPerPixel),
      ],
      rotacao: _camera?.description.sensorOrientation ?? 90,
    );
  }

  // ------------------------------------------------------------------- captura

  void _pararAnalise() {
    final c = _camera;
    if (c != null && c.value.isStreamingImages) c.stopImageStream().catchError((_) {});
  }

  /// ISBN lido ao vivo ou digitado: consulta direto, sem enviar foto.
  Future<void> _consultarIsbn(String isbn) async {
    _isbnPendente = null;
    try {
      final obra = await ref.read(obrasRepositorioProvider).porIsbn(isbn);
      if (mounted) context.pushReplacement('/obra/${obra.id}');
    } on ErroApi catch (e) {
      if (!mounted) return;
      if (e.codigo == 'obra_nao_encontrada') {
        context.pushReplacement('/cadastrar-obra?isbn=$isbn');
        return;
      }
      if (e.semRede) _isbnPendente = isbn;
      _falhar(e);
    }
  }

  /// Captura manual (web, ou quando o código não é lido ao vivo): o servidor lê na foto.
  Future<void> _capturar() async {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized || !_estado.analisando) return;
    setState(() => _estado = _maquina.aoCapturarManual(_estado));
    try {
      if (camera.value.isStreamingImages) await camera.stopImageStream();
      final foto = await camera.takePicture();
      await _enviarFoto(await prepararEnvio(await foto.readAsBytes()));
    } catch (e) {
      _falhar(e);
    }
  }

  Future<void> _enviarFoto(Uint8List jpeg) async {
    _capturaPendente = null;
    try {
      final r = await ref.read(reconhecimentoRepositorioProvider).enviar(jpeg);
      if (!mounted) return;
      setState(() => _estado = _maquina.aoReceberResultado(_estado));
      if (r.status == 'identificado' && r.obra != null) {
        context.pushReplacement('/obra/${r.obra!.id}');
      } else if (r.status == 'nao_identificado' && r.isbn != null) {
        context.pushReplacement('/cadastrar-obra?isbn=${r.isbn}');
      } else {
        await context.push('/reconhecimento', extra: r);
        if (mounted) _recomecar();
      }
    } on ErroApi catch (e) {
      if (e.semRede) _capturaPendente = jpeg;
      _falhar(e);
    }
  }

  void _falhar(Object e) {
    if (!mounted) return;
    final semRede = e is ErroApi && e.semRede;
    final mensagem = semRede ? Textos.of(context).semRedeCaptura : mensagemDeErro(context, e);
    setState(() => _estado = _maquina.aoFalhar(_estado, mensagem));
  }

  Future<void> _recomecar() async {
    if (_isbnPendente != null) {
      final isbn = _isbnPendente!;
      setState(() => _estado = _maquina.aoCapturarManual(_maquina.reiniciar(_estado)));
      await _consultarIsbn(isbn);
      return;
    }
    if (_capturaPendente != null) {
      setState(() => _estado = _maquina.aoCapturarManual(_maquina.reiniciar(_estado)));
      await _enviarFoto(_capturaPendente!);
      return;
    }
    setState(() => _estado = _maquina.reiniciar(_estado));
    final c = _camera;
    if (c != null && _detector!.aoVivo && !kIsWeb && !c.value.isStreamingImages) {
      await c.startImageStream(_aoQuadro);
    }
  }

  Future<void> _galeria() async {
    final arquivo = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (arquivo == null || !mounted || !_estado.analisando) return;
    _pararAnalise();
    setState(() => _estado = _maquina.aoCapturarManual(_estado));
    try {
      await _enviarFoto(await prepararEnvio(await arquivo.readAsBytes()));
    } catch (e) {
      _falhar(e);
    }
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
    if (!RegrasBusca.isbnValido(isbn)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.isbnInvalido)));
      return;
    }
    _pararAnalise();
    setState(() => _estado = _maquina.aoCapturarManual(_maquina.reiniciar(_estado)));
    await _consultarIsbn(RegrasBusca.normalizarIsbn(isbn));
  }

  Future<void> _alternarLanterna() async {
    final c = _camera;
    if (c == null) return;
    try {
      await c.setFlashMode(_lanterna ? FlashMode.off : FlashMode.torch);
      setState(() => _lanterna = !_lanterna);
    } catch (_) {}
  }

  // --------------------------------------------------------------------- tela

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _corpo(context)),
            if (_camera != null && mostrarGuia(_estado, _detector?.aoVivo ?? false))
              const Positioned.fill(bottom: 180, child: IgnorePointer(child: MolduraGuia())),
            Positioned(
              top: Espaco.xs,
              left: Espaco.xs,
              child: _BotaoRedondo(
                icone: Icons.close,
                rotulo: t.botaoFechar,
                aoTocar: () => context.canPop() ? context.pop() : context.go('/'),
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
            Positioned(left: 0, right: 0, bottom: 0, child: _controles(context)),
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
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    final previa = camera.value.previewSize!;
    // No celular a prévia vem em paisagem (sensor); em pé, largura e altura trocam.
    // Na web ela já vem na orientação da tela.
    final larg = kIsWeb ? previa.width : previa.height;
    final alt = kIsWeb ? previa.height : previa.width;
    return LayoutBuilder(
      builder: (context, limites) => ClipRect(
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
                  SobreposicaoScanner(estado: _estado, aoVivo: _detector?.aoVivo ?? false),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _controles(BuildContext context) {
    final t = Textos.of(context);
    final e = context.estilos;
    final branco = e.corpo.copyWith(color: Colors.white);
    final aoVivo = _detector?.aoVivo ?? false;
    final mensagem = switch (_estado.fase) {
      FaseScanner.consultando || FaseScanner.resultado => t.identificando,
      FaseScanner.erro => _estado.mensagemErro ?? t.erroGenerico,
      _ when _estado.naoELivro => t.naoELivro,
      _ when _estado.poucaLuz => t.poucaLuz,
      _ => aoVivo ? t.enquadre : t.enquadreManual,
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
            child: Text(mensagem, textAlign: TextAlign.center, style: branco),
          ),
          if (_estado.fase == FaseScanner.erro) ...[
            const SizedBox(height: Espaco.xs),
            FilledButton(onPressed: _recomecar, child: Text(t.botaoTentarDeNovo)),
          ],
          const SizedBox(height: Espaco.s),
          const SizedBox(height: Espaco.s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BotaoRedondo(
                icone: Icons.photo_library_outlined,
                rotulo: t.botaoGaleria,
                aoTocar: _galeria,
              ),
              Semantics(
                button: true,
                label: t.botaoCapturar,
                child: GestureDetector(
                  onTap: _camera != null && _estado.analisando ? _capturar : null,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: _camera != null ? Colors.white24 : Colors.white10,
                    ),
                  ),
                ),
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
            const SizedBox(height: 160),
          ],
        ),
      ),
    );
  }
}
