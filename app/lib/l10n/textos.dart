import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'textos_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of Textos
/// returned by `Textos.of(context)`.
///
/// Applications need to include `Textos.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/textos.dart';
///
/// return MaterialApp(
///   localizationsDelegates: Textos.localizationsDelegates,
///   supportedLocales: Textos.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the Textos.supportedLocales
/// property.
abstract class Textos {
  Textos(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static Textos of(BuildContext context) {
    return Localizations.of<Textos>(context, Textos)!;
  }

  static const LocalizationsDelegate<Textos> delegate = _TextosDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('pt')];

  /// No description provided for @nomeProduto.
  ///
  /// In pt, this message translates to:
  /// **'Entrelinhas'**
  String get nomeProduto;

  /// No description provided for @slogan.
  ///
  /// In pt, this message translates to:
  /// **'O que está entre as linhas, antes da leitura.'**
  String get slogan;

  /// No description provided for @avisoIndependencia.
  ///
  /// In pt, this message translates to:
  /// **'Orientação editorial independente, sem vínculo com o Ministério da Justiça ou com o sistema ClassInd.'**
  String get avisoIndependencia;

  /// No description provided for @navInicio.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get navInicio;

  /// No description provided for @navEscanear.
  ///
  /// In pt, this message translates to:
  /// **'Escanear'**
  String get navEscanear;

  /// No description provided for @navListas.
  ///
  /// In pt, this message translates to:
  /// **'Listas'**
  String get navListas;

  /// No description provided for @navPerfil.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get navPerfil;

  /// No description provided for @navAcervo.
  ///
  /// In pt, this message translates to:
  /// **'Acervo'**
  String get navAcervo;

  /// No description provided for @navRevisao.
  ///
  /// In pt, this message translates to:
  /// **'Revisão'**
  String get navRevisao;

  /// No description provided for @boasVindas1Titulo.
  ///
  /// In pt, this message translates to:
  /// **'Saiba o que há no livro antes da leitura'**
  String get boasVindas1Titulo;

  /// No description provided for @boasVindas1Texto.
  ///
  /// In pt, this message translates to:
  /// **'Aponte a câmera para a capa ou para o código de barras, ou busque pelo título. Em segundos, você vê a faixa de idade recomendada e os temas sensíveis da obra.'**
  String get boasVindas1Texto;

  /// No description provided for @boasVindas2Titulo.
  ///
  /// In pt, this message translates to:
  /// **'Como ler uma ficha'**
  String get boasVindas2Titulo;

  /// No description provided for @boasVindas2Texto.
  ///
  /// In pt, this message translates to:
  /// **'O selo mostra a partir de que idade a leitura é recomendada. Os alertas indicam temas presentes, como luto ou bullying. O perfil de leitura diz quão exigente é o texto. Nenhum deles é um julgamento sobre a obra.'**
  String get boasVindas2Texto;

  /// No description provided for @boasVindas3Titulo.
  ///
  /// In pt, this message translates to:
  /// **'Uma orientação independente'**
  String get boasVindas3Titulo;

  /// No description provided for @boasVindas3Texto.
  ///
  /// In pt, this message translates to:
  /// **'O Entrelinhas informa; quem decide é a família ou a escola. A faixa é calculada por uma regra pública, e editores revisam as fichas.'**
  String get boasVindas3Texto;

  /// No description provided for @botaoContinuar.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get botaoContinuar;

  /// No description provided for @botaoPular.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get botaoPular;

  /// No description provided for @botaoComecar.
  ///
  /// In pt, this message translates to:
  /// **'Começar'**
  String get botaoComecar;

  /// No description provided for @botaoEntrar.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get botaoEntrar;

  /// No description provided for @botaoCriarConta.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get botaoCriarConta;

  /// No description provided for @botaoAgoraNao.
  ///
  /// In pt, this message translates to:
  /// **'Agora não'**
  String get botaoAgoraNao;

  /// No description provided for @botaoUsarSemConta.
  ///
  /// In pt, this message translates to:
  /// **'Usar sem conta'**
  String get botaoUsarSemConta;

  /// No description provided for @rotuloBuscar.
  ///
  /// In pt, this message translates to:
  /// **'Buscar um livro'**
  String get rotuloBuscar;

  /// No description provided for @dicaBusca.
  ///
  /// In pt, this message translates to:
  /// **'Título, autor ou ISBN'**
  String get dicaBusca;

  /// No description provided for @botaoApontar.
  ///
  /// In pt, this message translates to:
  /// **'Apontar para o livro'**
  String get botaoApontar;

  /// No description provided for @botaoApontarSub.
  ///
  /// In pt, this message translates to:
  /// **'Capa ou código de barras'**
  String get botaoApontarSub;

  /// No description provided for @consultasRecentes.
  ///
  /// In pt, this message translates to:
  /// **'Consultas recentes'**
  String get consultasRecentes;

  /// No description provided for @semConsultasRecentes.
  ///
  /// In pt, this message translates to:
  /// **'Os livros que você consultar aparecem aqui.'**
  String get semConsultasRecentes;

  /// No description provided for @paraQuemELeitura.
  ///
  /// In pt, this message translates to:
  /// **'Para quem é a leitura?'**
  String get paraQuemELeitura;

  /// No description provided for @leitorNenhum.
  ///
  /// In pt, this message translates to:
  /// **'Para mim'**
  String get leitorNenhum;

  /// No description provided for @usoMes.
  ///
  /// In pt, this message translates to:
  /// **'{usadas} de {limite} fichas neste mês'**
  String usoMes(int usadas, int limite);

  /// No description provided for @buscaMinimo.
  ///
  /// In pt, this message translates to:
  /// **'Digite ao menos 3 letras para buscar.'**
  String get buscaMinimo;

  /// No description provided for @buscaVazia.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma obra encontrada. Confira a grafia ou tente o ISBN.'**
  String get buscaVazia;

  /// No description provided for @isbnInvalido.
  ///
  /// In pt, this message translates to:
  /// **'Este número não é um ISBN válido. Confira os dígitos.'**
  String get isbnInvalido;

  /// No description provided for @buscaErroRede.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão com as fontes externas. Mostrando só a base Entrelinhas.'**
  String get buscaErroRede;

  /// No description provided for @obraNaoEncontrada.
  ///
  /// In pt, this message translates to:
  /// **'ISBN válido, mas nenhuma fonte reconheceu a obra. Você pode cadastrá-la manualmente.'**
  String get obraNaoEncontrada;

  /// No description provided for @botaoCadastrarManual.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar obra'**
  String get botaoCadastrarManual;

  /// No description provided for @cadastroTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar obra'**
  String get cadastroTitulo;

  /// No description provided for @cadastroIsbn.
  ///
  /// In pt, this message translates to:
  /// **'ISBN'**
  String get cadastroIsbn;

  /// No description provided for @cadastroTituloObra.
  ///
  /// In pt, this message translates to:
  /// **'Título'**
  String get cadastroTituloObra;

  /// No description provided for @cadastroAutores.
  ///
  /// In pt, this message translates to:
  /// **'Autores (separados por vírgula)'**
  String get cadastroAutores;

  /// No description provided for @cadastroEditora.
  ///
  /// In pt, this message translates to:
  /// **'Editora'**
  String get cadastroEditora;

  /// No description provided for @cadastroAno.
  ///
  /// In pt, this message translates to:
  /// **'Ano'**
  String get cadastroAno;

  /// No description provided for @cadastroPaginas.
  ///
  /// In pt, this message translates to:
  /// **'Páginas'**
  String get cadastroPaginas;

  /// No description provided for @semFichaAinda.
  ///
  /// In pt, this message translates to:
  /// **'Sem ficha ainda'**
  String get semFichaAinda;

  /// No description provided for @emAnaliseCurto.
  ///
  /// In pt, this message translates to:
  /// **'Em análise'**
  String get emAnaliseCurto;

  /// No description provided for @origemBase.
  ///
  /// In pt, this message translates to:
  /// **'Base Entrelinhas'**
  String get origemBase;

  /// No description provided for @origemGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Google Books'**
  String get origemGoogle;

  /// No description provided for @origemOpenLibrary.
  ///
  /// In pt, this message translates to:
  /// **'Open Library'**
  String get origemOpenLibrary;

  /// No description provided for @origemManual.
  ///
  /// In pt, this message translates to:
  /// **'Cadastro manual'**
  String get origemManual;

  /// No description provided for @rotuloDemonstracao.
  ///
  /// In pt, this message translates to:
  /// **'Demonstração'**
  String get rotuloDemonstracao;

  /// No description provided for @rotuloDemonstracaoLonga.
  ///
  /// In pt, this message translates to:
  /// **'Obra fictícia de demonstração'**
  String get rotuloDemonstracaoLonga;

  /// No description provided for @eEsteLivro.
  ///
  /// In pt, this message translates to:
  /// **'É este o livro?'**
  String get eEsteLivro;

  /// No description provided for @naoEEste.
  ///
  /// In pt, this message translates to:
  /// **'Não é este'**
  String get naoEEste;

  /// No description provided for @encontramosOpcoes.
  ///
  /// In pt, this message translates to:
  /// **'Encontramos estas opções'**
  String get encontramosOpcoes;

  /// No description provided for @nenhumaDestas.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma destas'**
  String get nenhumaDestas;

  /// No description provided for @naoReconhecemos.
  ///
  /// In pt, this message translates to:
  /// **'Não reconhecemos este livro. Tente o código de barras na contracapa ou busque pelo título.'**
  String get naoReconhecemos;

  /// No description provided for @naoELivro.
  ///
  /// In pt, this message translates to:
  /// **'O código lido não é de um livro. Procure o código ISBN, geralmente na contracapa.'**
  String get naoELivro;

  /// No description provided for @botaoEscanearDeNovo.
  ///
  /// In pt, this message translates to:
  /// **'Escanear de novo'**
  String get botaoEscanearDeNovo;

  /// No description provided for @botaoBuscarTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Buscar pelo título'**
  String get botaoBuscarTitulo;

  /// No description provided for @botaoDigitarIsbn.
  ///
  /// In pt, this message translates to:
  /// **'Digitar ISBN'**
  String get botaoDigitarIsbn;

  /// No description provided for @digitarIsbnTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Digitar ISBN'**
  String get digitarIsbnTitulo;

  /// No description provided for @botaoConsultar.
  ///
  /// In pt, this message translates to:
  /// **'Consultar'**
  String get botaoConsultar;

  /// No description provided for @enquadre.
  ///
  /// In pt, this message translates to:
  /// **'Enquadre a capa ou o código de barras'**
  String get enquadre;

  /// No description provided for @identificando.
  ///
  /// In pt, this message translates to:
  /// **'Identificando o livro…'**
  String get identificando;

  /// No description provided for @permissaoCameraTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Precisamos da câmera'**
  String get permissaoCameraTitulo;

  /// No description provided for @permissaoCameraTexto.
  ///
  /// In pt, this message translates to:
  /// **'A câmera é usada só para reconhecer o livro. Você também pode escolher uma foto da galeria ou digitar o ISBN.'**
  String get permissaoCameraTexto;

  /// No description provided for @botaoAbrirConfiguracoes.
  ///
  /// In pt, this message translates to:
  /// **'Abrir configurações'**
  String get botaoAbrirConfiguracoes;

  /// No description provided for @poucaLuz.
  ///
  /// In pt, this message translates to:
  /// **'Pouca luz. Experimente ligar a lanterna.'**
  String get poucaLuz;

  /// No description provided for @semRedeCaptura.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão. A foto foi guardada; tente enviar de novo.'**
  String get semRedeCaptura;

  /// No description provided for @botaoTentarDeNovo.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get botaoTentarDeNovo;

  /// No description provided for @modoAutomatico.
  ///
  /// In pt, this message translates to:
  /// **'Automático'**
  String get modoAutomatico;

  /// No description provided for @modoCapa.
  ///
  /// In pt, this message translates to:
  /// **'Capa'**
  String get modoCapa;

  /// No description provided for @modoCodigo.
  ///
  /// In pt, this message translates to:
  /// **'Código de barras'**
  String get modoCodigo;

  /// No description provided for @botaoGaleria.
  ///
  /// In pt, this message translates to:
  /// **'Escolher da galeria'**
  String get botaoGaleria;

  /// No description provided for @botaoLanterna.
  ///
  /// In pt, this message translates to:
  /// **'Lanterna'**
  String get botaoLanterna;

  /// No description provided for @botaoCapturar.
  ///
  /// In pt, this message translates to:
  /// **'Capturar'**
  String get botaoCapturar;

  /// No description provided for @botaoFechar.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get botaoFechar;

  /// No description provided for @semCamera.
  ///
  /// In pt, this message translates to:
  /// **'Não encontramos uma câmera neste dispositivo. Envie uma foto do livro ou digite o ISBN.'**
  String get semCamera;

  /// No description provided for @botaoEnviarFoto.
  ///
  /// In pt, this message translates to:
  /// **'Enviar foto'**
  String get botaoEnviarFoto;

  /// No description provided for @dicaVariosLivros.
  ///
  /// In pt, this message translates to:
  /// **'Mais de um livro no quadro. Toque no que você quer consultar.'**
  String get dicaVariosLivros;

  /// No description provided for @dicaSegurar.
  ///
  /// In pt, this message translates to:
  /// **'Segure firme…'**
  String get dicaSegurar;

  /// No description provided for @salvarNaLista.
  ///
  /// In pt, this message translates to:
  /// **'Salvar na lista'**
  String get salvarNaLista;

  /// No description provided for @compartilhar.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar'**
  String get compartilhar;

  /// No description provided for @exportarPdf.
  ///
  /// In pt, this message translates to:
  /// **'Exportar PDF'**
  String get exportarPdf;

  /// No description provided for @contestar.
  ///
  /// In pt, this message translates to:
  /// **'Contestar ficha'**
  String get contestar;

  /// No description provided for @maisOpcoes.
  ///
  /// In pt, this message translates to:
  /// **'Mais opções'**
  String get maisOpcoes;

  /// No description provided for @rotuloOrientacao.
  ///
  /// In pt, this message translates to:
  /// **'ORIENTAÇÃO DE LEITURA'**
  String get rotuloOrientacao;

  /// No description provided for @paginasN.
  ///
  /// In pt, this message translates to:
  /// **'{n} páginas'**
  String paginasN(int n);

  /// No description provided for @faixaAnos.
  ///
  /// In pt, this message translates to:
  /// **'{idade} anos'**
  String faixaAnos(String idade);

  /// No description provided for @faixaLivre.
  ///
  /// In pt, this message translates to:
  /// **'Livre'**
  String get faixaLivre;

  /// No description provided for @dentroDaFaixa.
  ///
  /// In pt, this message translates to:
  /// **'Dentro da faixa para {nome} ({idade} anos).'**
  String dentroDaFaixa(String nome, int idade);

  /// No description provided for @acimaDaIdade.
  ///
  /// In pt, this message translates to:
  /// **'A faixa é {faixa}; {nome} tem {idade}. A orientação é leitura com mediação de adulto ou aguardar.'**
  String acimaDaIdade(String faixa, String nome, int idade);

  /// No description provided for @confiancaAnalise.
  ///
  /// In pt, this message translates to:
  /// **'Confiança da análise'**
  String get confiancaAnalise;

  /// No description provided for @confiancaBaixa.
  ///
  /// In pt, this message translates to:
  /// **'Baixa'**
  String get confiancaBaixa;

  /// No description provided for @confiancaMedia.
  ///
  /// In pt, this message translates to:
  /// **'Média'**
  String get confiancaMedia;

  /// No description provided for @confiancaAlta.
  ///
  /// In pt, this message translates to:
  /// **'Alta'**
  String get confiancaAlta;

  /// No description provided for @revisadoHumano.
  ///
  /// In pt, this message translates to:
  /// **'Revisado por editor humano'**
  String get revisadoHumano;

  /// No description provided for @emRevisao.
  ///
  /// In pt, this message translates to:
  /// **'Ficha em revisão após contestação'**
  String get emRevisao;

  /// No description provided for @avisoEstimativa.
  ///
  /// In pt, this message translates to:
  /// **'Esta ficha é uma estimativa gerada sem acesso ao texto da obra. Trate a faixa como orientação inicial, não como análise.'**
  String get avisoEstimativa;

  /// No description provided for @conteudoSensivel.
  ///
  /// In pt, this message translates to:
  /// **'Conteúdo sensível'**
  String get conteudoSensivel;

  /// No description provided for @defineAFaixa.
  ///
  /// In pt, this message translates to:
  /// **'Define a faixa'**
  String get defineAFaixa;

  /// No description provided for @notaAgravante.
  ///
  /// In pt, this message translates to:
  /// **'Dois ou mais eixos em 16 anos ou acima elevam a faixa em um degrau.'**
  String get notaAgravante;

  /// No description provided for @alertasConteudo.
  ///
  /// In pt, this message translates to:
  /// **'Alertas de conteúdo'**
  String get alertasConteudo;

  /// No description provided for @semAlertas.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum alerta de conteúdo.'**
  String get semAlertas;

  /// No description provided for @perfilLeitura.
  ///
  /// In pt, this message translates to:
  /// **'Perfil de leitura'**
  String get perfilLeitura;

  /// No description provided for @nivelLeitura.
  ///
  /// In pt, this message translates to:
  /// **'Nível de leitura'**
  String get nivelLeitura;

  /// No description provided for @repertorioQueAjuda.
  ///
  /// In pt, this message translates to:
  /// **'Repertório que ajuda'**
  String get repertorioQueAjuda;

  /// No description provided for @valorFormativo.
  ///
  /// In pt, this message translates to:
  /// **'Valor formativo'**
  String get valorFormativo;

  /// No description provided for @comoClassificamos.
  ///
  /// In pt, this message translates to:
  /// **'Como classificamos'**
  String get comoClassificamos;

  /// No description provided for @avisoA5.
  ///
  /// In pt, this message translates to:
  /// **'Trechos desta obra não são reproduzidos por descreverem conduta de risco. A orientação se baseia em descrição neutra das cenas.'**
  String get avisoA5;

  /// No description provided for @estadoAnalisando.
  ///
  /// In pt, this message translates to:
  /// **'Estamos analisando esta obra. Isso leva alguns instantes.'**
  String get estadoAnalisando;

  /// No description provided for @estadoSemFicha.
  ///
  /// In pt, this message translates to:
  /// **'Obra localizada, ainda sem ficha Entrelinhas.'**
  String get estadoSemFicha;

  /// No description provided for @estadoIndisponivel.
  ///
  /// In pt, this message translates to:
  /// **'Não conseguimos gerar a ficha desta obra agora.'**
  String get estadoIndisponivel;

  /// No description provided for @botaoPedirAnalise.
  ///
  /// In pt, this message translates to:
  /// **'Pedir análise'**
  String get botaoPedirAnalise;

  /// No description provided for @analisePedida.
  ///
  /// In pt, this message translates to:
  /// **'Análise pedida. Avisaremos quando a ficha estiver pronta.'**
  String get analisePedida;

  /// No description provided for @limiteAtingidoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Você usou as fichas gratuitas deste mês'**
  String get limiteAtingidoTitulo;

  /// No description provided for @limiteAtingidoTexto.
  ///
  /// In pt, this message translates to:
  /// **'O selo e a recomendação continuam visíveis. Para ver a ficha completa agora, conheça os planos.'**
  String get limiteAtingidoTexto;

  /// No description provided for @botaoVerPlanos.
  ///
  /// In pt, this message translates to:
  /// **'Ver planos'**
  String get botaoVerPlanos;

  /// No description provided for @entrarParaVerFicha.
  ///
  /// In pt, this message translates to:
  /// **'Entre na sua conta para ver a ficha completa: conteúdo sensível, alertas e perfil de leitura.'**
  String get entrarParaVerFicha;

  /// No description provided for @evidenciaFonte.
  ///
  /// In pt, this message translates to:
  /// **'Fonte: {fonte}'**
  String evidenciaFonte(String fonte);

  /// No description provided for @trechoLiteral.
  ///
  /// In pt, this message translates to:
  /// **'Trecho'**
  String get trechoLiteral;

  /// No description provided for @justificativa.
  ///
  /// In pt, this message translates to:
  /// **'Justificativa'**
  String get justificativa;

  /// No description provided for @dimensaoVocabulario.
  ///
  /// In pt, this message translates to:
  /// **'Vocabulário'**
  String get dimensaoVocabulario;

  /// No description provided for @dimensaoEstrutura.
  ///
  /// In pt, this message translates to:
  /// **'Estrutura narrativa'**
  String get dimensaoEstrutura;

  /// No description provided for @dimensaoDensidade.
  ///
  /// In pt, this message translates to:
  /// **'Densidade temática'**
  String get dimensaoDensidade;

  /// No description provided for @dimensaoExtensao.
  ///
  /// In pt, this message translates to:
  /// **'Extensão'**
  String get dimensaoExtensao;

  /// No description provided for @semRepertorio.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum repertório prévio necessário.'**
  String get semRepertorio;

  /// No description provided for @nivelDe.
  ///
  /// In pt, this message translates to:
  /// **'Nível {nivel} de {maximo}'**
  String nivelDe(int nivel, int maximo);

  /// No description provided for @fichaVersao.
  ///
  /// In pt, this message translates to:
  /// **'Versão {versao} da ficha · Rubrica {rubrica}'**
  String fichaVersao(int versao, String rubrica);

  /// No description provided for @eixoA1.
  ///
  /// In pt, this message translates to:
  /// **'Violência física'**
  String get eixoA1;

  /// No description provided for @eixoA2.
  ///
  /// In pt, this message translates to:
  /// **'Sexo e intimidade'**
  String get eixoA2;

  /// No description provided for @eixoA3.
  ///
  /// In pt, this message translates to:
  /// **'Linguagem ofensiva'**
  String get eixoA3;

  /// No description provided for @eixoA4.
  ///
  /// In pt, this message translates to:
  /// **'Substâncias'**
  String get eixoA4;

  /// No description provided for @eixoA5.
  ///
  /// In pt, this message translates to:
  /// **'Risco à integridade'**
  String get eixoA5;

  /// No description provided for @eixoA6.
  ///
  /// In pt, this message translates to:
  /// **'Abuso, trauma e opressão'**
  String get eixoA6;

  /// No description provided for @nivel0.
  ///
  /// In pt, this message translates to:
  /// **'Ausente'**
  String get nivel0;

  /// No description provided for @nivel1.
  ///
  /// In pt, this message translates to:
  /// **'Leve'**
  String get nivel1;

  /// No description provided for @nivel2.
  ///
  /// In pt, this message translates to:
  /// **'Moderado'**
  String get nivel2;

  /// No description provided for @nivel3.
  ///
  /// In pt, this message translates to:
  /// **'Intenso'**
  String get nivel3;

  /// No description provided for @nivel4.
  ///
  /// In pt, this message translates to:
  /// **'Extremo'**
  String get nivel4;

  /// No description provided for @semanticaEixo.
  ///
  /// In pt, this message translates to:
  /// **'{eixo}: nível {nivel} de 4, {rotulo}'**
  String semanticaEixo(String eixo, int nivel, String rotulo);

  /// No description provided for @semanticaSelo.
  ///
  /// In pt, this message translates to:
  /// **'Orientação de leitura: {faixa}'**
  String semanticaSelo(String faixa);

  /// No description provided for @semanticaConfianca.
  ///
  /// In pt, this message translates to:
  /// **'Confiança da análise: {rotulo}'**
  String semanticaConfianca(String rotulo);

  /// No description provided for @semanticaCapa.
  ///
  /// In pt, this message translates to:
  /// **'Capa de {titulo}'**
  String semanticaCapa(String titulo);

  /// No description provided for @semanticaDimensao.
  ///
  /// In pt, this message translates to:
  /// **'{dimensao}: {valor} de 5'**
  String semanticaDimensao(String dimensao, int valor);

  /// No description provided for @fonteTextoIntegral.
  ///
  /// In pt, this message translates to:
  /// **'Análise do texto integral'**
  String get fonteTextoIntegral;

  /// No description provided for @fonteAmostragem.
  ///
  /// In pt, this message translates to:
  /// **'Análise por amostragem de trechos'**
  String get fonteAmostragem;

  /// No description provided for @fontePublicas.
  ///
  /// In pt, this message translates to:
  /// **'Análise a partir de sinopse e resenhas públicas'**
  String get fontePublicas;

  /// No description provided for @fonteMetadados.
  ///
  /// In pt, this message translates to:
  /// **'Estimativa sem acesso ao texto'**
  String get fonteMetadados;

  /// No description provided for @flagMorteDePersonagemPrincipal.
  ///
  /// In pt, this message translates to:
  /// **'Morte de personagem principal'**
  String get flagMorteDePersonagemPrincipal;

  /// No description provided for @flagLuto.
  ///
  /// In pt, this message translates to:
  /// **'Luto'**
  String get flagLuto;

  /// No description provided for @flagMorteOuMausTratosDeAnimal.
  ///
  /// In pt, this message translates to:
  /// **'Morte ou maus-tratos de animal'**
  String get flagMorteOuMausTratosDeAnimal;

  /// No description provided for @flagDoencaTerminal.
  ///
  /// In pt, this message translates to:
  /// **'Doença terminal'**
  String get flagDoencaTerminal;

  /// No description provided for @flagBullying.
  ///
  /// In pt, this message translates to:
  /// **'Bullying'**
  String get flagBullying;

  /// No description provided for @flagViolenciaEscolar.
  ///
  /// In pt, this message translates to:
  /// **'Violência escolar'**
  String get flagViolenciaEscolar;

  /// No description provided for @flagGravidezIndesejada.
  ///
  /// In pt, this message translates to:
  /// **'Gravidez indesejada'**
  String get flagGravidezIndesejada;

  /// No description provided for @flagAborto.
  ///
  /// In pt, this message translates to:
  /// **'Aborto'**
  String get flagAborto;

  /// No description provided for @flagViolenciaSexualForaDeCena.
  ///
  /// In pt, this message translates to:
  /// **'Violência sexual fora de cena'**
  String get flagViolenciaSexualForaDeCena;

  /// No description provided for @flagSequestroOuCarcere.
  ///
  /// In pt, this message translates to:
  /// **'Sequestro ou cárcere'**
  String get flagSequestroOuCarcere;

  /// No description provided for @flagAutomutilacao.
  ///
  /// In pt, this message translates to:
  /// **'Automutilação'**
  String get flagAutomutilacao;

  /// No description provided for @flagSuicidio.
  ///
  /// In pt, this message translates to:
  /// **'Suicídio'**
  String get flagSuicidio;

  /// No description provided for @flagTranstornoAlimentar.
  ///
  /// In pt, this message translates to:
  /// **'Transtorno alimentar'**
  String get flagTranstornoAlimentar;

  /// No description provided for @flagDependenciaQuimica.
  ///
  /// In pt, this message translates to:
  /// **'Dependência química'**
  String get flagDependenciaQuimica;

  /// No description provided for @flagRelacaoAbusivaRomantizada.
  ///
  /// In pt, this message translates to:
  /// **'Relação abusiva romantizada'**
  String get flagRelacaoAbusivaRomantizada;

  /// No description provided for @flagDiferencaDePoderEmRelacaoAfetiva.
  ///
  /// In pt, this message translates to:
  /// **'Diferença de poder em relação afetiva'**
  String get flagDiferencaDePoderEmRelacaoAfetiva;

  /// No description provided for @flagDiscriminacaoSemCriticaNarrativa.
  ///
  /// In pt, this message translates to:
  /// **'Discriminação sem crítica narrativa'**
  String get flagDiscriminacaoSemCriticaNarrativa;

  /// No description provided for @flagConteudoReligiosoSensivel.
  ///
  /// In pt, this message translates to:
  /// **'Conteúdo religioso sensível'**
  String get flagConteudoReligiosoSensivel;

  /// No description provided for @flagFinalTragico.
  ///
  /// In pt, this message translates to:
  /// **'Final trágico'**
  String get flagFinalTragico;

  /// No description provided for @flagAcidenteGrave.
  ///
  /// In pt, this message translates to:
  /// **'Acidente grave'**
  String get flagAcidenteGrave;

  /// No description provided for @flagArmaDeFogo.
  ///
  /// In pt, this message translates to:
  /// **'Arma de fogo'**
  String get flagArmaDeFogo;

  /// No description provided for @marcadorEmpatia.
  ///
  /// In pt, this message translates to:
  /// **'Empatia'**
  String get marcadorEmpatia;

  /// No description provided for @marcadorRepertorioCultural.
  ///
  /// In pt, this message translates to:
  /// **'Repertório cultural'**
  String get marcadorRepertorioCultural;

  /// No description provided for @marcadorPensamentoCritico.
  ///
  /// In pt, this message translates to:
  /// **'Pensamento crítico'**
  String get marcadorPensamentoCritico;

  /// No description provided for @marcadorQualidadeEstetica.
  ///
  /// In pt, this message translates to:
  /// **'Qualidade estética'**
  String get marcadorQualidadeEstetica;

  /// No description provided for @marcadorConhecimentoHistorico.
  ///
  /// In pt, this message translates to:
  /// **'Conhecimento histórico'**
  String get marcadorConhecimentoHistorico;

  /// No description provided for @marcadorDesenvolvimentoMoral.
  ///
  /// In pt, this message translates to:
  /// **'Desenvolvimento moral'**
  String get marcadorDesenvolvimentoMoral;

  /// No description provided for @listasTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Listas'**
  String get listasTitulo;

  /// No description provided for @listaQueroLer.
  ///
  /// In pt, this message translates to:
  /// **'Quero ler'**
  String get listaQueroLer;

  /// No description provided for @listaAprovados.
  ///
  /// In pt, this message translates to:
  /// **'Aprovados'**
  String get listaAprovados;

  /// No description provided for @novaLista.
  ///
  /// In pt, this message translates to:
  /// **'Nova lista'**
  String get novaLista;

  /// No description provided for @nomeDaLista.
  ///
  /// In pt, this message translates to:
  /// **'Nome da lista'**
  String get nomeDaLista;

  /// No description provided for @filtroFaixa.
  ///
  /// In pt, this message translates to:
  /// **'Faixa'**
  String get filtroFaixa;

  /// No description provided for @filtroLeitor.
  ///
  /// In pt, this message translates to:
  /// **'Leitor'**
  String get filtroLeitor;

  /// No description provided for @filtroTodas.
  ///
  /// In pt, this message translates to:
  /// **'Todas'**
  String get filtroTodas;

  /// No description provided for @filtroTodos.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get filtroTodos;

  /// No description provided for @listaVazia.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum livro nesta lista ainda.'**
  String get listaVazia;

  /// No description provided for @semListas.
  ///
  /// In pt, this message translates to:
  /// **'Crie listas para guardar os livros que você consultou.'**
  String get semListas;

  /// No description provided for @removerDaLista.
  ///
  /// In pt, this message translates to:
  /// **'Remover da lista'**
  String get removerDaLista;

  /// No description provided for @salvoEm.
  ///
  /// In pt, this message translates to:
  /// **'Salvo em {lista}'**
  String salvoEm(String lista);

  /// No description provided for @escolherLista.
  ///
  /// In pt, this message translates to:
  /// **'Escolha a lista'**
  String get escolherLista;

  /// No description provided for @paraLeitor.
  ///
  /// In pt, this message translates to:
  /// **'Para qual leitor?'**
  String get paraLeitor;

  /// No description provided for @entrarParaListas.
  ///
  /// In pt, this message translates to:
  /// **'Entre na sua conta para criar listas.'**
  String get entrarParaListas;

  /// No description provided for @itensN.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =0{Nenhum livro} =1{1 livro} other{{n} livros}}'**
  String itensN(int n);

  /// No description provided for @perfilTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get perfilTitulo;

  /// No description provided for @conta.
  ///
  /// In pt, this message translates to:
  /// **'Conta'**
  String get conta;

  /// No description provided for @leitores.
  ///
  /// In pt, this message translates to:
  /// **'Leitores'**
  String get leitores;

  /// No description provided for @adicionarLeitor.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar leitor'**
  String get adicionarLeitor;

  /// No description provided for @editarLeitor.
  ///
  /// In pt, this message translates to:
  /// **'Editar leitor'**
  String get editarLeitor;

  /// No description provided for @apelido.
  ///
  /// In pt, this message translates to:
  /// **'Apelido'**
  String get apelido;

  /// No description provided for @anoNascimento.
  ///
  /// In pt, this message translates to:
  /// **'Ano de nascimento'**
  String get anoNascimento;

  /// No description provided for @icone.
  ///
  /// In pt, this message translates to:
  /// **'Ícone'**
  String get icone;

  /// No description provided for @leitoresExplicacao.
  ///
  /// In pt, this message translates to:
  /// **'Guardamos só o apelido, o ano de nascimento e um ícone. Nada de nome completo, foto ou escola.'**
  String get leitoresExplicacao;

  /// No description provided for @limitePerfis.
  ///
  /// In pt, this message translates to:
  /// **'O plano gratuito permite um leitor. Conheça os planos para adicionar mais.'**
  String get limitePerfis;

  /// No description provided for @plano.
  ///
  /// In pt, this message translates to:
  /// **'Plano'**
  String get plano;

  /// No description provided for @planoGratuito.
  ///
  /// In pt, this message translates to:
  /// **'Gratuito'**
  String get planoGratuito;

  /// No description provided for @planoFamilia.
  ///
  /// In pt, this message translates to:
  /// **'Família'**
  String get planoFamilia;

  /// No description provided for @planoEscola.
  ///
  /// In pt, this message translates to:
  /// **'Escola'**
  String get planoEscola;

  /// No description provided for @planoValidoAte.
  ///
  /// In pt, this message translates to:
  /// **'Válido até {data}'**
  String planoValidoAte(String data);

  /// No description provided for @usoDoMes.
  ///
  /// In pt, this message translates to:
  /// **'Uso do mês'**
  String get usoDoMes;

  /// No description provided for @privacidade.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade'**
  String get privacidade;

  /// No description provided for @contribuirImagens.
  ///
  /// In pt, this message translates to:
  /// **'Ajudar a melhorar o reconhecimento'**
  String get contribuirImagens;

  /// No description provided for @contribuirImagensExplicacao.
  ///
  /// In pt, this message translates to:
  /// **'Quando ligado, as fotos que você envia para reconhecer livros e as correções que você faz são guardadas para treinar o reconhecimento de capas. Desligado, as fotos são processadas e descartadas.'**
  String get contribuirImagensExplicacao;

  /// No description provided for @exportarDados.
  ///
  /// In pt, this message translates to:
  /// **'Exportar meus dados'**
  String get exportarDados;

  /// No description provided for @dadosExportados.
  ///
  /// In pt, this message translates to:
  /// **'Seus dados foram preparados.'**
  String get dadosExportados;

  /// No description provided for @excluirConta.
  ///
  /// In pt, this message translates to:
  /// **'Excluir conta'**
  String get excluirConta;

  /// No description provided for @excluirContaConfirmar.
  ///
  /// In pt, this message translates to:
  /// **'Excluir sua conta apaga leitores, listas, histórico e imagens guardadas. Isso não pode ser desfeito.'**
  String get excluirContaConfirmar;

  /// No description provided for @termos.
  ///
  /// In pt, this message translates to:
  /// **'Termos de uso'**
  String get termos;

  /// No description provided for @politica.
  ///
  /// In pt, this message translates to:
  /// **'Política de privacidade'**
  String get politica;

  /// No description provided for @sair.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get sair;

  /// No description provided for @naoConectado.
  ///
  /// In pt, this message translates to:
  /// **'Você não está conectado.'**
  String get naoConectado;

  /// No description provided for @entrarTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get entrarTitulo;

  /// No description provided for @criarContaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get criarContaTitulo;

  /// No description provided for @email.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @senha.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get senha;

  /// No description provided for @nome.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get nome;

  /// No description provided for @esqueciSenha.
  ///
  /// In pt, this message translates to:
  /// **'Esqueci a senha'**
  String get esqueciSenha;

  /// No description provided for @recuperarSenhaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Recuperar senha'**
  String get recuperarSenhaTitulo;

  /// No description provided for @recuperarSenhaTexto.
  ///
  /// In pt, this message translates to:
  /// **'Enviaremos um link para criar uma nova senha.'**
  String get recuperarSenhaTexto;

  /// No description provided for @botaoEnviarLink.
  ///
  /// In pt, this message translates to:
  /// **'Enviar link'**
  String get botaoEnviarLink;

  /// No description provided for @linkEnviado.
  ///
  /// In pt, this message translates to:
  /// **'Se houver uma conta com este e-mail, o link chegará em instantes.'**
  String get linkEnviado;

  /// No description provided for @novaSenha.
  ///
  /// In pt, this message translates to:
  /// **'Nova senha'**
  String get novaSenha;

  /// No description provided for @senhaRedefinida.
  ///
  /// In pt, this message translates to:
  /// **'Senha redefinida. Entre com a nova senha.'**
  String get senhaRedefinida;

  /// No description provided for @entrarComGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Continuar com Google'**
  String get entrarComGoogle;

  /// No description provided for @entrarComApple.
  ///
  /// In pt, this message translates to:
  /// **'Continuar com Apple'**
  String get entrarComApple;

  /// No description provided for @ou.
  ///
  /// In pt, this message translates to:
  /// **'ou'**
  String get ou;

  /// No description provided for @aceitoTermos.
  ///
  /// In pt, this message translates to:
  /// **'Li e aceito os Termos de uso e a Política de privacidade.'**
  String get aceitoTermos;

  /// No description provided for @erroAceiteTermos.
  ///
  /// In pt, this message translates to:
  /// **'É preciso aceitar os termos para criar a conta.'**
  String get erroAceiteTermos;

  /// No description provided for @erroCredenciais.
  ///
  /// In pt, this message translates to:
  /// **'E-mail ou senha incorretos.'**
  String get erroCredenciais;

  /// No description provided for @senhaCurta.
  ///
  /// In pt, this message translates to:
  /// **'A senha precisa ter ao menos 8 caracteres.'**
  String get senhaCurta;

  /// No description provided for @emailInvalido.
  ///
  /// In pt, this message translates to:
  /// **'Confira o e-mail.'**
  String get emailInvalido;

  /// No description provided for @campoObrigatorio.
  ///
  /// In pt, this message translates to:
  /// **'Preencha este campo.'**
  String get campoObrigatorio;

  /// No description provided for @jaTemConta.
  ///
  /// In pt, this message translates to:
  /// **'Já tem conta? Entrar'**
  String get jaTemConta;

  /// No description provided for @naoTemConta.
  ///
  /// In pt, this message translates to:
  /// **'Não tem conta? Criar conta'**
  String get naoTemConta;

  /// No description provided for @loginSocialIndisponivel.
  ///
  /// In pt, this message translates to:
  /// **'Este acesso ainda não está configurado.'**
  String get loginSocialIndisponivel;

  /// No description provided for @planosTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Planos'**
  String get planosTitulo;

  /// No description provided for @planoGratuitoDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Busca e câmera ilimitadas, selo sempre visível, {limite} fichas completas novas por mês e 1 leitor.'**
  String planoGratuitoDescricao(int limite);

  /// No description provided for @planoFamiliaDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Fichas ilimitadas, leitores e listas ilimitados e exportação em PDF.'**
  String get planoFamiliaDescricao;

  /// No description provided for @planoEscolaDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Tudo do Família para a equipe, com painel de acervo, importação em lote e relatórios.'**
  String get planoEscolaDescricao;

  /// No description provided for @precoFamilia.
  ///
  /// In pt, this message translates to:
  /// **'[PREÇO FAMÍLIA]'**
  String get precoFamilia;

  /// No description provided for @precoEscola.
  ///
  /// In pt, this message translates to:
  /// **'[PREÇO ESCOLA]'**
  String get precoEscola;

  /// No description provided for @botaoAssinar.
  ///
  /// In pt, this message translates to:
  /// **'Assinar'**
  String get botaoAssinar;

  /// No description provided for @planoAtual.
  ///
  /// In pt, this message translates to:
  /// **'Plano atual'**
  String get planoAtual;

  /// No description provided for @assinaturaAtivada.
  ///
  /// In pt, this message translates to:
  /// **'Assinatura ativada.'**
  String get assinaturaAtivada;

  /// No description provided for @assinaturaIndisponivel.
  ///
  /// In pt, this message translates to:
  /// **'A assinatura não está disponível neste ambiente.'**
  String get assinaturaIndisponivel;

  /// No description provided for @falarComEquipe.
  ///
  /// In pt, this message translates to:
  /// **'Falar com a equipe'**
  String get falarComEquipe;

  /// No description provided for @contestarTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Contestar ficha'**
  String get contestarTitulo;

  /// No description provided for @contestarExplicacao.
  ///
  /// In pt, this message translates to:
  /// **'Diga o que você acha que está diferente na obra. Um editor vai rever a ficha e responder.'**
  String get contestarExplicacao;

  /// No description provided for @campoContestado.
  ///
  /// In pt, this message translates to:
  /// **'O que você quer contestar?'**
  String get campoContestado;

  /// No description provided for @campoOutro.
  ///
  /// In pt, this message translates to:
  /// **'Outro ponto da ficha'**
  String get campoOutro;

  /// No description provided for @motivo.
  ///
  /// In pt, this message translates to:
  /// **'Motivo'**
  String get motivo;

  /// No description provided for @dicaMotivo.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: a violência aparece só em uma cena curta, sem detalhes.'**
  String get dicaMotivo;

  /// No description provided for @botaoEnviar.
  ///
  /// In pt, this message translates to:
  /// **'Enviar'**
  String get botaoEnviar;

  /// No description provided for @contestacaoEnviada.
  ///
  /// In pt, this message translates to:
  /// **'Contestação enviada. Você será avisado da resposta.'**
  String get contestacaoEnviada;

  /// No description provided for @minhasContestacoes.
  ///
  /// In pt, this message translates to:
  /// **'Minhas contestações'**
  String get minhasContestacoes;

  /// No description provided for @contestacaoAberta.
  ///
  /// In pt, this message translates to:
  /// **'Em análise'**
  String get contestacaoAberta;

  /// No description provided for @contestacaoAceita.
  ///
  /// In pt, this message translates to:
  /// **'Aceita'**
  String get contestacaoAceita;

  /// No description provided for @contestacaoRecusada.
  ///
  /// In pt, this message translates to:
  /// **'Mantida'**
  String get contestacaoRecusada;

  /// No description provided for @metodologiaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Como classificamos'**
  String get metodologiaTitulo;

  /// No description provided for @metodologiaRegras.
  ///
  /// In pt, this message translates to:
  /// **'Regras do cálculo'**
  String get metodologiaRegras;

  /// No description provided for @metodologiaEixos.
  ///
  /// In pt, this message translates to:
  /// **'Os seis eixos'**
  String get metodologiaEixos;

  /// No description provided for @metodologiaFontes.
  ///
  /// In pt, this message translates to:
  /// **'De onde vem a análise'**
  String get metodologiaFontes;

  /// No description provided for @metodologiaContestacao.
  ///
  /// In pt, this message translates to:
  /// **'Como contestar'**
  String get metodologiaContestacao;

  /// No description provided for @metodologiaRecomendacoes.
  ///
  /// In pt, this message translates to:
  /// **'Recomendações'**
  String get metodologiaRecomendacoes;

  /// No description provided for @colunaNivel.
  ///
  /// In pt, this message translates to:
  /// **'Nível'**
  String get colunaNivel;

  /// No description provided for @colunaDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get colunaDescricao;

  /// No description provided for @colunaFaixa.
  ///
  /// In pt, this message translates to:
  /// **'Faixa'**
  String get colunaFaixa;

  /// No description provided for @acervoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Acervo'**
  String get acervoTitulo;

  /// No description provided for @novaListaAcervo.
  ///
  /// In pt, this message translates to:
  /// **'Nova lista de acervo'**
  String get novaListaAcervo;

  /// No description provided for @novaTurma.
  ///
  /// In pt, this message translates to:
  /// **'Nova turma'**
  String get novaTurma;

  /// No description provided for @idadeReferencia.
  ///
  /// In pt, this message translates to:
  /// **'Idade de referência'**
  String get idadeReferencia;

  /// No description provided for @anoEscolar.
  ///
  /// In pt, this message translates to:
  /// **'Ano escolar'**
  String get anoEscolar;

  /// No description provided for @importarCsv.
  ///
  /// In pt, this message translates to:
  /// **'Importar ISBNs (CSV)'**
  String get importarCsv;

  /// No description provided for @importacaoExplicacao.
  ///
  /// In pt, this message translates to:
  /// **'Envie um arquivo CSV com uma coluna chamada isbn. Cada linha é validada; obras sem ficha entram na fila de análise.'**
  String get importacaoExplicacao;

  /// No description provided for @importacaoAceitos.
  ///
  /// In pt, this message translates to:
  /// **'Aceitos'**
  String get importacaoAceitos;

  /// No description provided for @importacaoRejeitados.
  ///
  /// In pt, this message translates to:
  /// **'Rejeitados'**
  String get importacaoRejeitados;

  /// No description provided for @importacaoNaoEncontrados.
  ///
  /// In pt, this message translates to:
  /// **'Não encontrados'**
  String get importacaoNaoEncontrados;

  /// No description provided for @importacaoPendentes.
  ///
  /// In pt, this message translates to:
  /// **'Análises pendentes'**
  String get importacaoPendentes;

  /// No description provided for @importacaoAndamento.
  ///
  /// In pt, this message translates to:
  /// **'Importação em andamento…'**
  String get importacaoAndamento;

  /// No description provided for @relatorio.
  ///
  /// In pt, this message translates to:
  /// **'Relatório'**
  String get relatorio;

  /// No description provided for @distribuicaoFaixa.
  ///
  /// In pt, this message translates to:
  /// **'Distribuição por faixa'**
  String get distribuicaoFaixa;

  /// No description provided for @alertasFrequentes.
  ///
  /// In pt, this message translates to:
  /// **'Alertas mais frequentes'**
  String get alertasFrequentes;

  /// No description provided for @obrasAcimaIdade.
  ///
  /// In pt, this message translates to:
  /// **'Obras acima da idade de referência'**
  String get obrasAcimaIdade;

  /// No description provided for @nenhumaAcimaIdade.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma obra acima da idade de referência.'**
  String get nenhumaAcimaIdade;

  /// No description provided for @exportarCsv.
  ///
  /// In pt, this message translates to:
  /// **'Exportar CSV'**
  String get exportarCsv;

  /// No description provided for @membros.
  ///
  /// In pt, this message translates to:
  /// **'Membros'**
  String get membros;

  /// No description provided for @convidarMembro.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar membro'**
  String get convidarMembro;

  /// No description provided for @papelGestor.
  ///
  /// In pt, this message translates to:
  /// **'Gestor'**
  String get papelGestor;

  /// No description provided for @papelBibliotecario.
  ///
  /// In pt, this message translates to:
  /// **'Bibliotecário'**
  String get papelBibliotecario;

  /// No description provided for @papelProfessor.
  ///
  /// In pt, this message translates to:
  /// **'Professor'**
  String get papelProfessor;

  /// No description provided for @situacaoFicha.
  ///
  /// In pt, this message translates to:
  /// **'Situação da ficha'**
  String get situacaoFicha;

  /// No description provided for @semOrganizacao.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não participa de uma escola ou biblioteca.'**
  String get semOrganizacao;

  /// No description provided for @criarOrganizacao.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar escola ou biblioteca'**
  String get criarOrganizacao;

  /// No description provided for @nomeOrganizacao.
  ///
  /// In pt, this message translates to:
  /// **'Nome da instituição'**
  String get nomeOrganizacao;

  /// No description provided for @colunaObra.
  ///
  /// In pt, this message translates to:
  /// **'Obra'**
  String get colunaObra;

  /// No description provided for @colunaAlertas.
  ///
  /// In pt, this message translates to:
  /// **'Alertas'**
  String get colunaAlertas;

  /// No description provided for @colunaNivelLeitura.
  ///
  /// In pt, this message translates to:
  /// **'Nível de leitura'**
  String get colunaNivelLeitura;

  /// No description provided for @quantidade.
  ///
  /// In pt, this message translates to:
  /// **'Quantidade'**
  String get quantidade;

  /// No description provided for @removerMembro.
  ///
  /// In pt, this message translates to:
  /// **'Remover'**
  String get removerMembro;

  /// No description provided for @revisaoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Revisão editorial'**
  String get revisaoTitulo;

  /// No description provided for @filaRevisao.
  ///
  /// In pt, this message translates to:
  /// **'Fichas aguardando revisão'**
  String get filaRevisao;

  /// No description provided for @filaVazia.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma ficha aguardando revisão.'**
  String get filaVazia;

  /// No description provided for @contestacoesAbertas.
  ///
  /// In pt, this message translates to:
  /// **'Contestações abertas'**
  String get contestacoesAbertas;

  /// No description provided for @motivoMudanca.
  ///
  /// In pt, this message translates to:
  /// **'Motivo da mudança'**
  String get motivoMudanca;

  /// No description provided for @motivoObrigatorio.
  ///
  /// In pt, this message translates to:
  /// **'Descreva o motivo da mudança.'**
  String get motivoObrigatorio;

  /// No description provided for @publicarRevisao.
  ///
  /// In pt, this message translates to:
  /// **'Publicar revisão'**
  String get publicarRevisao;

  /// No description provided for @revisaoPublicada.
  ///
  /// In pt, this message translates to:
  /// **'Revisão publicada.'**
  String get revisaoPublicada;

  /// No description provided for @faixaRecalculada.
  ///
  /// In pt, this message translates to:
  /// **'Faixa recalculada: {faixa}'**
  String faixaRecalculada(String faixa);

  /// No description provided for @responderContestacao.
  ///
  /// In pt, this message translates to:
  /// **'Responder'**
  String get responderContestacao;

  /// No description provided for @aceitarContestacao.
  ///
  /// In pt, this message translates to:
  /// **'Aceitar'**
  String get aceitarContestacao;

  /// No description provided for @recusarContestacao.
  ///
  /// In pt, this message translates to:
  /// **'Manter ficha'**
  String get recusarContestacao;

  /// No description provided for @resposta.
  ///
  /// In pt, this message translates to:
  /// **'Resposta'**
  String get resposta;

  /// No description provided for @consultasN.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =0{Nenhuma consulta} =1{1 consulta} other{{n} consultas}}'**
  String consultasN(int n);

  /// No description provided for @carregando.
  ///
  /// In pt, this message translates to:
  /// **'Carregando…'**
  String get carregando;

  /// No description provided for @tentarNovamente.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get tentarNovamente;

  /// No description provided for @erroGenerico.
  ///
  /// In pt, this message translates to:
  /// **'Algo não saiu como esperado. Tente de novo em instantes.'**
  String get erroGenerico;

  /// No description provided for @erroRede.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão com o Entrelinhas. Confira sua internet.'**
  String get erroRede;

  /// No description provided for @erroSessao.
  ///
  /// In pt, this message translates to:
  /// **'Sua sessão expirou. Entre de novo.'**
  String get erroSessao;

  /// No description provided for @cancelar.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancelar;

  /// No description provided for @salvar.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get salvar;

  /// No description provided for @excluir.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get excluir;

  /// No description provided for @confirmar.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get confirmar;

  /// No description provided for @voltar.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get voltar;

  /// No description provided for @fechar.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get fechar;

  /// No description provided for @editar.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get editar;

  /// No description provided for @ok.
  ///
  /// In pt, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @copiado.
  ///
  /// In pt, this message translates to:
  /// **'Link copiado.'**
  String get copiado;

  /// No description provided for @verFichaCompleta.
  ///
  /// In pt, this message translates to:
  /// **'Ver a ficha completa'**
  String get verFichaCompleta;

  /// No description provided for @tipoAcervo.
  ///
  /// In pt, this message translates to:
  /// **'Acervo'**
  String get tipoAcervo;

  /// No description provided for @tipoTurma.
  ///
  /// In pt, this message translates to:
  /// **'Turma'**
  String get tipoTurma;

  /// No description provided for @situacaoPublicada.
  ///
  /// In pt, this message translates to:
  /// **'Publicada'**
  String get situacaoPublicada;

  /// No description provided for @situacaoEmAnalise.
  ///
  /// In pt, this message translates to:
  /// **'Em análise'**
  String get situacaoEmAnalise;

  /// No description provided for @situacaoSemFicha.
  ///
  /// In pt, this message translates to:
  /// **'Sem ficha'**
  String get situacaoSemFicha;

  /// No description provided for @situacaoEmRevisao.
  ///
  /// In pt, this message translates to:
  /// **'Em revisão'**
  String get situacaoEmRevisao;

  /// No description provided for @situacaoIndisponivel.
  ///
  /// In pt, this message translates to:
  /// **'Indisponível'**
  String get situacaoIndisponivel;

  /// No description provided for @botaoPrevia.
  ///
  /// In pt, this message translates to:
  /// **'Ver faixa recalculada'**
  String get botaoPrevia;
}

class _TextosDelegate extends LocalizationsDelegate<Textos> {
  const _TextosDelegate();

  @override
  Future<Textos> load(Locale locale) {
    return SynchronousFuture<Textos>(lookupTextos(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_TextosDelegate old) => false;
}

Textos lookupTextos(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'pt':
      return TextosPt();
  }

  throw FlutterError(
    'Textos.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
