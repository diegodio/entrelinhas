import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/textos.dart';
import '../../../nucleo/componentes/estados.dart';
import '../../../nucleo/config/ambiente.dart';
import '../../../nucleo/rede/erro_api.dart';
import '../../../nucleo/tema/tema.dart';
import '../dados/conta_repositorio.dart';
import '../dados/login_social.dart';

/// Validações puras (testáveis).
abstract final class ValidacaoConta {
  static bool emailValido(String v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
  static bool senhaValida(String v) => v.length >= 8;
}

/// Entrar ou criar conta. [depois] é a rota para onde voltar ao concluir.
class TelaEntrar extends ConsumerStatefulWidget {
  const TelaEntrar({super.key, this.cadastro = false, this.depois});
  final bool cadastro;
  final String? depois;

  @override
  ConsumerState<TelaEntrar> createState() => _TelaEntrarState();
}

class _TelaEntrarState extends ConsumerState<TelaEntrar> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _nome = TextEditingController();
  bool _aceite = false;
  bool _enviando = false;
  String? _erro;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    _nome.dispose();
    super.dispose();
  }

  void _concluir() {
    final destino = widget.depois;
    if (destino != null && destino.startsWith('/')) {
      context.go(destino);
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  Future<void> _enviar() async {
    final t = Textos.of(context);
    setState(() => _erro = null);
    if (!_form.currentState!.validate()) return;
    if (widget.cadastro && !_aceite) {
      setState(() => _erro = t.erroAceiteTermos);
      return;
    }
    setState(() => _enviando = true);
    try {
      final sessao = ref.read(sessaoProvider.notifier);
      if (widget.cadastro) {
        await sessao.cadastrar(_email.text.trim(), _senha.text, _nome.text.trim());
      } else {
        await sessao.entrar(_email.text.trim(), _senha.text);
      }
      if (mounted) _concluir();
    } on ErroApi catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.codigo == 'credenciais_invalidas'
          ? t.erroCredenciais
          : mensagemDeErro(context, e));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _social(String provedor) async {
    final t = Textos.of(context);
    setState(() => _erro = null);
    try {
      final credencial = await ref.read(loginSocialProvider).entrar(provedor);
      if (credencial == null) return; // a pessoa cancelou
      await ref.read(sessaoProvider.notifier)
          .entrarComProvedor(provedor, credencial.idToken, nome: credencial.nome);
      if (mounted) _concluir();
    } on LoginSocialIndisponivel {
      setState(() => _erro = t.loginSocialIndisponivel);
    } catch (e) {
      if (mounted) setState(() => _erro = mensagemDeErro(context, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final e = context.estilos;
    final social = ref.watch(loginSocialProvider);
    final depois = widget.depois == null ? '' : '?depois=${Uri.encodeComponent(widget.depois!)}';
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: LarguraLeitura(
          largura: 520,
          child: Form(
            key: _form,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(widget.cadastro ? t.criarContaTitulo : t.entrarTitulo,
                        style: e.tituloObra),
                  ),
                  const SizedBox(height: Espaco.l),
                  for (final p in social.disponiveis) ...[
                    OutlinedButton.icon(
                      onPressed: () => _social(p),
                      icon: Icon(p == 'apple' ? Icons.apple : Icons.account_circle_outlined),
                      label: Text(p == 'apple' ? t.entrarComApple : t.entrarComGoogle),
                    ),
                    const SizedBox(height: Espaco.xs),
                  ],
                  if (social.disponiveis.isNotEmpty) ...[
                    const SizedBox(height: Espaco.xs),
                    Row(children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Espaco.s),
                        child: Text(t.ou, style: e.apoio),
                      ),
                      const Expanded(child: Divider()),
                    ]),
                    const SizedBox(height: Espaco.m),
                  ],
                  if (widget.cadastro) ...[
                    TextFormField(
                      controller: _nome,
                      decoration: InputDecoration(labelText: t.nome),
                      autofillHints: const [AutofillHints.name],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: Espaco.s),
                  ],
                  TextFormField(
                    controller: _email,
                    decoration: InputDecoration(labelText: t.email),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    validator: (v) => ValidacaoConta.emailValido(v ?? '') ? null : t.emailInvalido,
                  ),
                  const SizedBox(height: Espaco.s),
                  TextFormField(
                    controller: _senha,
                    decoration: InputDecoration(labelText: t.senha),
                    obscureText: true,
                    autofillHints: [
                      widget.cadastro ? AutofillHints.newPassword : AutofillHints.password,
                    ],
                    onFieldSubmitted: (_) => _enviar(),
                    validator: (v) {
                      if ((v ?? '').isEmpty) return t.campoObrigatorio;
                      if (widget.cadastro && !ValidacaoConta.senhaValida(v!)) return t.senhaCurta;
                      return null;
                    },
                  ),
                  if (widget.cadastro) ...[
                    const SizedBox(height: Espaco.s),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _aceite,
                      onChanged: (v) => setState(() => _aceite = v ?? false),
                      title: Text(t.aceitoTermos, style: e.corpo),
                    ),
                    Wrap(spacing: Espaco.s, children: [
                      TextButton(
                        onPressed: () => launchUrl(Uri.parse(Ambiente.urlTermos)),
                        child: Text(t.termos),
                      ),
                      TextButton(
                        onPressed: () => launchUrl(Uri.parse(Ambiente.urlPolitica)),
                        child: Text(t.politica),
                      ),
                    ]),
                  ],
                  if (_erro != null) ...[
                    const SizedBox(height: Espaco.s),
                    Semantics(
                      liveRegion: true,
                      child: Text(_erro!,
                          style: e.corpo.copyWith(color: context.cores.alertaForte)),
                    ),
                  ],
                  const SizedBox(height: Espaco.m),
                  FilledButton(
                    onPressed: _enviando ? null : _enviar,
                    child: Text(widget.cadastro ? t.botaoCriarConta : t.botaoEntrar),
                  ),
                  const SizedBox(height: Espaco.xs),
                  if (!widget.cadastro)
                    TextButton(
                      onPressed: () => context.push('/recuperar-senha'),
                      child: Text(t.esqueciSenha),
                    ),
                  TextButton(
                    onPressed: () => context.pushReplacement(
                        (widget.cadastro ? '/entrar' : '/cadastro') + depois),
                    child: Text(widget.cadastro ? t.jaTemConta : t.naoTemConta),
                  ),
                  const SizedBox(height: Espaco.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Esqueci a senha" e, com token, "Nova senha".
class TelaRecuperarSenha extends ConsumerStatefulWidget {
  const TelaRecuperarSenha({super.key, this.token});
  final String? token;

  @override
  ConsumerState<TelaRecuperarSenha> createState() => _TelaRecuperarSenhaState();
}

class _TelaRecuperarSenhaState extends ConsumerState<TelaRecuperarSenha> {
  final _campo = TextEditingController();
  String? _mensagem;
  bool _enviando = false;

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final t = Textos.of(context);
    final repo = ref.read(contaRepositorioProvider);
    final redefinindo = widget.token != null;
    if (redefinindo && !ValidacaoConta.senhaValida(_campo.text)) {
      setState(() => _mensagem = t.senhaCurta);
      return;
    }
    if (!redefinindo && !ValidacaoConta.emailValido(_campo.text)) {
      setState(() => _mensagem = t.emailInvalido);
      return;
    }
    setState(() => _enviando = true);
    try {
      if (redefinindo) {
        await repo.redefinirSenha(widget.token!, _campo.text);
        if (mounted) setState(() => _mensagem = t.senhaRedefinida);
      } else {
        await repo.recuperarSenha(_campo.text.trim());
        if (mounted) setState(() => _mensagem = t.linkEnviado);
      }
    } catch (e) {
      if (mounted) setState(() => _mensagem = mensagemDeErro(context, e));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final redefinindo = widget.token != null;
    return Scaffold(
      appBar: AppBar(),
      body: LarguraLeitura(
        largura: 520,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.recuperarSenhaTitulo, style: context.estilos.tituloObra),
            const SizedBox(height: Espaco.s),
            if (!redefinindo) Text(t.recuperarSenhaTexto, style: context.estilos.corpo),
            const SizedBox(height: Espaco.m),
            TextField(
              controller: _campo,
              obscureText: redefinindo,
              keyboardType: redefinindo ? TextInputType.text : TextInputType.emailAddress,
              decoration: InputDecoration(labelText: redefinindo ? t.novaSenha : t.email),
              onSubmitted: (_) => _enviar(),
            ),
            if (_mensagem != null) ...[
              const SizedBox(height: Espaco.s),
              Semantics(liveRegion: true, child: Text(_mensagem!, style: context.estilos.corpo)),
            ],
            const SizedBox(height: Espaco.m),
            FilledButton(
              onPressed: _enviando ? null : _enviar,
              child: Text(redefinindo ? t.salvar : t.botaoEnviarLink),
            ),
          ],
        ),
      ),
    );
  }
}
