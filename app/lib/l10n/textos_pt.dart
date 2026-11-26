// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'textos.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class TextosPt extends Textos {
  TextosPt([String locale = 'pt']) : super(locale);

  @override
  String get nomeProduto => 'Entrelinhas';

  @override
  String get slogan => 'O que está entre as linhas, antes da leitura.';

  @override
  String get avisoIndependencia =>
      'Orientação editorial independente, sem vínculo com o Ministério da Justiça ou com o sistema ClassInd.';

  @override
  String get navInicio => 'Início';

  @override
  String get navEscanear => 'Escanear';

  @override
  String get navListas => 'Listas';

  @override
  String get navPerfil => 'Perfil';

  @override
  String get navAcervo => 'Acervo';

  @override
  String get navRevisao => 'Revisão';

  @override
  String get boasVindas1Titulo => 'Saiba o que há no livro antes da leitura';

  @override
  String get boasVindas1Texto =>
      'Aponte a câmera para a capa ou para o código de barras, ou busque pelo título. Em segundos, você vê a faixa de idade recomendada e os temas sensíveis da obra.';

  @override
  String get boasVindas2Titulo => 'Como ler uma ficha';

  @override
  String get boasVindas2Texto =>
      'O selo mostra a partir de que idade a leitura é recomendada. Os alertas indicam temas presentes, como luto ou bullying. O perfil de leitura diz quão exigente é o texto. Nenhum deles é um julgamento sobre a obra.';

  @override
  String get boasVindas3Titulo => 'Uma orientação independente';

  @override
  String get boasVindas3Texto =>
      'O Entrelinhas informa; quem decide é a família ou a escola. A faixa é calculada por uma regra pública, e editores revisam as fichas.';

  @override
  String get botaoContinuar => 'Continuar';

  @override
  String get botaoPular => 'Pular';

  @override
  String get botaoComecar => 'Começar';

  @override
  String get botaoEntrar => 'Entrar';

  @override
  String get botaoCriarConta => 'Criar conta';

  @override
  String get botaoAgoraNao => 'Agora não';

  @override
  String get botaoUsarSemConta => 'Usar sem conta';

  @override
  String get rotuloBuscar => 'Buscar um livro';

  @override
  String get dicaBusca => 'Título, autor ou ISBN';

  @override
  String get botaoApontar => 'Apontar para o livro';

  @override
  String get botaoApontarSub => 'Capa ou código de barras';

  @override
  String get consultasRecentes => 'Consultas recentes';

  @override
  String get semConsultasRecentes => 'Os livros que você consultar aparecem aqui.';

  @override
  String get paraQuemELeitura => 'Para quem é a leitura?';

  @override
  String get leitorNenhum => 'Para mim';

  @override
  String usoMes(int usadas, int limite) {
    return '$usadas de $limite fichas neste mês';
  }

  @override
  String get buscaMinimo => 'Digite ao menos 3 letras para buscar.';

  @override
  String get buscaVazia => 'Nenhuma obra encontrada. Confira a grafia ou tente o ISBN.';

  @override
  String get isbnInvalido => 'Este número não é um ISBN válido. Confira os dígitos.';

  @override
  String get buscaErroRede =>
      'Sem conexão com as fontes externas. Mostrando só a base Entrelinhas.';

  @override
  String get obraNaoEncontrada =>
      'ISBN válido, mas nenhuma fonte reconheceu a obra. Você pode cadastrá-la manualmente.';

  @override
  String get botaoCadastrarManual => 'Cadastrar obra';

  @override
  String get cadastroTitulo => 'Cadastrar obra';

  @override
  String get cadastroIsbn => 'ISBN';

  @override
  String get cadastroTituloObra => 'Título';

  @override
  String get cadastroAutores => 'Autores (separados por vírgula)';

  @override
  String get cadastroEditora => 'Editora';

  @override
  String get cadastroAno => 'Ano';

  @override
  String get cadastroPaginas => 'Páginas';

  @override
  String get semFichaAinda => 'Sem ficha ainda';

  @override
  String get emAnaliseCurto => 'Em análise';

  @override
  String get origemBase => 'Base Entrelinhas';

  @override
  String get origemGoogle => 'Google Books';

  @override
  String get origemOpenLibrary => 'Open Library';

  @override
  String get origemManual => 'Cadastro manual';

  @override
  String get rotuloDemonstracao => 'Demonstração';

  @override
  String get rotuloDemonstracaoLonga => 'Obra fictícia de demonstração';

  @override
  String get naoELivro =>
      'O código lido não é de um livro. Procure o código ISBN, geralmente na contracapa.';

  @override
  String get botaoEscanearDeNovo => 'Escanear de novo';

  @override
  String get botaoBuscarTitulo => 'Buscar pelo título';

  @override
  String get botaoDigitarIsbn => 'Digitar ISBN';

  @override
  String get digitarIsbnTitulo => 'Digitar ISBN';

  @override
  String get botaoConsultar => 'Consultar';

  @override
  String get enquadre => 'Aponte para o código de barras no verso do livro';

  @override
  String get enquadreManual => 'Enquadre o código de barras do verso e toque em Capturar';

  @override
  String get semCodigoNaFoto =>
      'Não encontramos um código de barras legível na foto. Chegue mais perto do código, com boa luz, ou digite o ISBN.';

  @override
  String get identificando => 'Consultando o livro…';

  @override
  String get permissaoCameraTitulo => 'Precisamos da câmera';

  @override
  String get permissaoCameraTexto =>
      'A câmera é usada só para reconhecer o livro. Você também pode escolher uma foto da galeria ou digitar o ISBN.';

  @override
  String get botaoAbrirConfiguracoes => 'Abrir configurações';

  @override
  String get poucaLuz => 'Pouca luz. Experimente ligar a lanterna.';

  @override
  String get semRedeCaptura => 'Sem conexão. A foto foi guardada; tente enviar de novo.';

  @override
  String get botaoTentarDeNovo => 'Tentar de novo';

  @override
  String get botaoGaleria => 'Escolher da galeria';

  @override
  String get botaoLanterna => 'Lanterna';

  @override
  String get botaoCapturar => 'Capturar';

  @override
  String get botaoFechar => 'Fechar';

  @override
  String get semCamera =>
      'Não encontramos uma câmera neste dispositivo. Envie uma foto do livro ou digite o ISBN.';

  @override
  String get botaoEnviarFoto => 'Enviar foto';

  @override
  String get salvarNaLista => 'Salvar na lista';

  @override
  String get compartilhar => 'Compartilhar';

  @override
  String get exportarPdf => 'Exportar PDF';

  @override
  String get contestar => 'Contestar ficha';

  @override
  String get maisOpcoes => 'Mais opções';

  @override
  String get rotuloOrientacao => 'ORIENTAÇÃO DE LEITURA';

  @override
  String paginasN(int n) {
    return '$n páginas';
  }

  @override
  String faixaAnos(String idade) {
    return '$idade anos';
  }

  @override
  String get faixaLivre => 'Livre';

  @override
  String dentroDaFaixa(String nome, int idade) {
    return 'Dentro da faixa para $nome ($idade anos).';
  }

  @override
  String acimaDaIdade(String faixa, String nome, int idade) {
    return 'A faixa é $faixa; $nome tem $idade. A orientação é leitura com mediação de adulto ou aguardar.';
  }

  @override
  String get confiancaAnalise => 'Confiança da análise';

  @override
  String get confiancaBaixa => 'Baixa';

  @override
  String get confiancaMedia => 'Média';

  @override
  String get confiancaAlta => 'Alta';

  @override
  String get revisadoHumano => 'Revisado por editor humano';

  @override
  String get emRevisao => 'Ficha em revisão após contestação';

  @override
  String get avisoEstimativa =>
      'Esta ficha é uma estimativa gerada sem acesso ao texto da obra. Trate a faixa como orientação inicial, não como análise.';

  @override
  String get conteudoSensivel => 'Conteúdo sensível';

  @override
  String get defineAFaixa => 'Define a faixa';

  @override
  String get notaAgravante => 'Dois ou mais eixos em 16 anos ou acima elevam a faixa em um degrau.';

  @override
  String get alertasConteudo => 'Alertas de conteúdo';

  @override
  String get semAlertas => 'Nenhum alerta de conteúdo.';

  @override
  String get perfilLeitura => 'Perfil de leitura';

  @override
  String get nivelLeitura => 'Nível de leitura';

  @override
  String get repertorioQueAjuda => 'Repertório que ajuda';

  @override
  String get valorFormativo => 'Valor formativo';

  @override
  String get comoClassificamos => 'Como classificamos';

  @override
  String get avisoA5 =>
      'Trechos desta obra não são reproduzidos por descreverem conduta de risco. A orientação se baseia em descrição neutra das cenas.';

  @override
  String get estadoAnalisando => 'Estamos analisando esta obra. Isso leva alguns instantes.';

  @override
  String get estadoSemFicha => 'Obra localizada, ainda sem ficha Entrelinhas.';

  @override
  String get estadoIndisponivel => 'Não conseguimos gerar a ficha desta obra agora.';

  @override
  String get botaoPedirAnalise => 'Pedir análise';

  @override
  String get analisePedida => 'Análise pedida. Avisaremos quando a ficha estiver pronta.';

  @override
  String get limiteAtingidoTitulo => 'Você usou as fichas gratuitas deste mês';

  @override
  String get limiteAtingidoTexto =>
      'O selo e a recomendação continuam visíveis. Para ver a ficha completa agora, conheça os planos.';

  @override
  String get botaoVerPlanos => 'Ver planos';

  @override
  String get entrarParaVerFicha =>
      'Entre na sua conta para ver a ficha completa: conteúdo sensível, alertas e perfil de leitura.';

  @override
  String evidenciaFonte(String fonte) {
    return 'Fonte: $fonte';
  }

  @override
  String get trechoLiteral => 'Trecho';

  @override
  String get justificativa => 'Justificativa';

  @override
  String get dimensaoVocabulario => 'Vocabulário';

  @override
  String get dimensaoEstrutura => 'Estrutura narrativa';

  @override
  String get dimensaoDensidade => 'Densidade temática';

  @override
  String get dimensaoExtensao => 'Extensão';

  @override
  String get semRepertorio => 'Nenhum repertório prévio necessário.';

  @override
  String nivelDe(int nivel, int maximo) {
    return 'Nível $nivel de $maximo';
  }

  @override
  String fichaVersao(int versao, String rubrica) {
    return 'Versão $versao da ficha · Rubrica $rubrica';
  }

  @override
  String get eixoA1 => 'Violência física';

  @override
  String get eixoA2 => 'Sexo e intimidade';

  @override
  String get eixoA3 => 'Linguagem ofensiva';

  @override
  String get eixoA4 => 'Substâncias';

  @override
  String get eixoA5 => 'Risco à integridade';

  @override
  String get eixoA6 => 'Abuso, trauma e opressão';

  @override
  String get nivel0 => 'Ausente';

  @override
  String get nivel1 => 'Leve';

  @override
  String get nivel2 => 'Moderado';

  @override
  String get nivel3 => 'Intenso';

  @override
  String get nivel4 => 'Extremo';

  @override
  String semanticaEixo(String eixo, int nivel, String rotulo) {
    return '$eixo: nível $nivel de 4, $rotulo';
  }

  @override
  String semanticaSelo(String faixa) {
    return 'Orientação de leitura: $faixa';
  }

  @override
  String semanticaConfianca(String rotulo) {
    return 'Confiança da análise: $rotulo';
  }

  @override
  String semanticaCapa(String titulo) {
    return 'Capa de $titulo';
  }

  @override
  String semanticaDimensao(String dimensao, int valor) {
    return '$dimensao: $valor de 5';
  }

  @override
  String get fonteTextoIntegral => 'Análise do texto integral';

  @override
  String get fonteAmostragem => 'Análise por amostragem de trechos';

  @override
  String get fontePublicas => 'Análise a partir de sinopse e resenhas públicas';

  @override
  String get fonteMetadados => 'Estimativa sem acesso ao texto';

  @override
  String get flagMorteDePersonagemPrincipal => 'Morte de personagem principal';

  @override
  String get flagLuto => 'Luto';

  @override
  String get flagMorteOuMausTratosDeAnimal => 'Morte ou maus-tratos de animal';

  @override
  String get flagDoencaTerminal => 'Doença terminal';

  @override
  String get flagBullying => 'Bullying';

  @override
  String get flagViolenciaEscolar => 'Violência escolar';

  @override
  String get flagGravidezIndesejada => 'Gravidez indesejada';

  @override
  String get flagAborto => 'Aborto';

  @override
  String get flagViolenciaSexualForaDeCena => 'Violência sexual fora de cena';

  @override
  String get flagSequestroOuCarcere => 'Sequestro ou cárcere';

  @override
  String get flagAutomutilacao => 'Automutilação';

  @override
  String get flagSuicidio => 'Suicídio';

  @override
  String get flagTranstornoAlimentar => 'Transtorno alimentar';

  @override
  String get flagDependenciaQuimica => 'Dependência química';

  @override
  String get flagRelacaoAbusivaRomantizada => 'Relação abusiva romantizada';

  @override
  String get flagDiferencaDePoderEmRelacaoAfetiva => 'Diferença de poder em relação afetiva';

  @override
  String get flagDiscriminacaoSemCriticaNarrativa => 'Discriminação sem crítica narrativa';

  @override
  String get flagConteudoReligiosoSensivel => 'Conteúdo religioso sensível';

  @override
  String get flagFinalTragico => 'Final trágico';

  @override
  String get flagAcidenteGrave => 'Acidente grave';

  @override
  String get flagArmaDeFogo => 'Arma de fogo';

  @override
  String get marcadorEmpatia => 'Empatia';

  @override
  String get marcadorRepertorioCultural => 'Repertório cultural';

  @override
  String get marcadorPensamentoCritico => 'Pensamento crítico';

  @override
  String get marcadorQualidadeEstetica => 'Qualidade estética';

  @override
  String get marcadorConhecimentoHistorico => 'Conhecimento histórico';

  @override
  String get marcadorDesenvolvimentoMoral => 'Desenvolvimento moral';

  @override
  String get listasTitulo => 'Listas';

  @override
  String get listaQueroLer => 'Quero ler';

  @override
  String get listaAprovados => 'Aprovados';

  @override
  String get novaLista => 'Nova lista';

  @override
  String get nomeDaLista => 'Nome da lista';

  @override
  String get filtroFaixa => 'Faixa';

  @override
  String get filtroLeitor => 'Leitor';

  @override
  String get filtroTodas => 'Todas';

  @override
  String get filtroTodos => 'Todos';

  @override
  String get listaVazia => 'Nenhum livro nesta lista ainda.';

  @override
  String get semListas => 'Crie listas para guardar os livros que você consultou.';

  @override
  String get removerDaLista => 'Remover da lista';

  @override
  String salvoEm(String lista) {
    return 'Salvo em $lista';
  }

  @override
  String get escolherLista => 'Escolha a lista';

  @override
  String get paraLeitor => 'Para qual leitor?';

  @override
  String get entrarParaListas => 'Entre na sua conta para criar listas.';

  @override
  String itensN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n livros',
      one: '1 livro',
      zero: 'Nenhum livro',
    );
    return '$_temp0';
  }

  @override
  String get perfilTitulo => 'Perfil';

  @override
  String get conta => 'Conta';

  @override
  String get leitores => 'Leitores';

  @override
  String get adicionarLeitor => 'Adicionar leitor';

  @override
  String get editarLeitor => 'Editar leitor';

  @override
  String get apelido => 'Apelido';

  @override
  String get anoNascimento => 'Ano de nascimento';

  @override
  String get icone => 'Ícone';

  @override
  String get leitoresExplicacao =>
      'Guardamos só o apelido, o ano de nascimento e um ícone. Nada de nome completo, foto ou escola.';

  @override
  String get limitePerfis =>
      'O plano gratuito permite um leitor. Conheça os planos para adicionar mais.';

  @override
  String get plano => 'Plano';

  @override
  String get planoGratuito => 'Gratuito';

  @override
  String get planoFamilia => 'Família';

  @override
  String get planoEscola => 'Escola';

  @override
  String planoValidoAte(String data) {
    return 'Válido até $data';
  }

  @override
  String get usoDoMes => 'Uso do mês';

  @override
  String get privacidade => 'Privacidade';

  @override
  String get exportarDados => 'Exportar meus dados';

  @override
  String get dadosExportados => 'Seus dados foram preparados.';

  @override
  String get excluirConta => 'Excluir conta';

  @override
  String get excluirContaConfirmar =>
      'Excluir sua conta apaga leitores, listas, histórico e imagens guardadas. Isso não pode ser desfeito.';

  @override
  String get termos => 'Termos de uso';

  @override
  String get politica => 'Política de privacidade';

  @override
  String get sair => 'Sair';

  @override
  String get naoConectado => 'Você não está conectado.';

  @override
  String get entrarTitulo => 'Entrar';

  @override
  String get criarContaTitulo => 'Criar conta';

  @override
  String get email => 'E-mail';

  @override
  String get senha => 'Senha';

  @override
  String get nome => 'Nome';

  @override
  String get esqueciSenha => 'Esqueci a senha';

  @override
  String get recuperarSenhaTitulo => 'Recuperar senha';

  @override
  String get recuperarSenhaTexto => 'Enviaremos um link para criar uma nova senha.';

  @override
  String get botaoEnviarLink => 'Enviar link';

  @override
  String get linkEnviado => 'Se houver uma conta com este e-mail, o link chegará em instantes.';

  @override
  String get novaSenha => 'Nova senha';

  @override
  String get senhaRedefinida => 'Senha redefinida. Entre com a nova senha.';

  @override
  String get entrarComGoogle => 'Continuar com Google';

  @override
  String get entrarComApple => 'Continuar com Apple';

  @override
  String get ou => 'ou';

  @override
  String get aceitoTermos => 'Li e aceito os Termos de uso e a Política de privacidade.';

  @override
  String get erroAceiteTermos => 'É preciso aceitar os termos para criar a conta.';

  @override
  String get erroCredenciais => 'E-mail ou senha incorretos.';

  @override
  String get senhaCurta => 'A senha precisa ter ao menos 8 caracteres.';

  @override
  String get emailInvalido => 'Confira o e-mail.';

  @override
  String get campoObrigatorio => 'Preencha este campo.';

  @override
  String get jaTemConta => 'Já tem conta? Entrar';

  @override
  String get naoTemConta => 'Não tem conta? Criar conta';

  @override
  String get loginSocialIndisponivel => 'Este acesso ainda não está configurado.';

  @override
  String get planosTitulo => 'Planos';

  @override
  String planoGratuitoDescricao(int limite) {
    return 'Busca e câmera ilimitadas, selo sempre visível, $limite fichas completas novas por mês e 1 leitor.';
  }

  @override
  String get planoFamiliaDescricao =>
      'Fichas ilimitadas, leitores e listas ilimitados e exportação em PDF.';

  @override
  String get planoEscolaDescricao =>
      'Tudo do Família para a equipe, com painel de acervo, importação em lote e relatórios.';

  @override
  String get precoFamilia => '[PREÇO FAMÍLIA]';

  @override
  String get precoEscola => '[PREÇO ESCOLA]';

  @override
  String get botaoAssinar => 'Assinar';

  @override
  String get planoAtual => 'Plano atual';

  @override
  String get assinaturaAtivada => 'Assinatura ativada.';

  @override
  String get assinaturaIndisponivel => 'A assinatura não está disponível neste ambiente.';

  @override
  String get falarComEquipe => 'Falar com a equipe';

  @override
  String get contestarTitulo => 'Contestar ficha';

  @override
  String get contestarExplicacao =>
      'Diga o que você acha que está diferente na obra. Um editor vai rever a ficha e responder.';

  @override
  String get campoContestado => 'O que você quer contestar?';

  @override
  String get campoOutro => 'Outro ponto da ficha';

  @override
  String get motivo => 'Motivo';

  @override
  String get dicaMotivo => 'Ex.: a violência aparece só em uma cena curta, sem detalhes.';

  @override
  String get botaoEnviar => 'Enviar';

  @override
  String get contestacaoEnviada => 'Contestação enviada. Você será avisado da resposta.';

  @override
  String get minhasContestacoes => 'Minhas contestações';

  @override
  String get contestacaoAberta => 'Em análise';

  @override
  String get contestacaoAceita => 'Aceita';

  @override
  String get contestacaoRecusada => 'Mantida';

  @override
  String get metodologiaTitulo => 'Como classificamos';

  @override
  String get metodologiaRegras => 'Regras do cálculo';

  @override
  String get metodologiaEixos => 'Os seis eixos';

  @override
  String get metodologiaFontes => 'De onde vem a análise';

  @override
  String get metodologiaContestacao => 'Como contestar';

  @override
  String get metodologiaRecomendacoes => 'Recomendações';

  @override
  String get colunaNivel => 'Nível';

  @override
  String get colunaDescricao => 'Descrição';

  @override
  String get colunaFaixa => 'Faixa';

  @override
  String get acervoTitulo => 'Acervo';

  @override
  String get novaListaAcervo => 'Nova lista de acervo';

  @override
  String get novaTurma => 'Nova turma';

  @override
  String get idadeReferencia => 'Idade de referência';

  @override
  String get anoEscolar => 'Ano escolar';

  @override
  String get importarCsv => 'Importar ISBNs (CSV)';

  @override
  String get importacaoExplicacao =>
      'Envie um arquivo CSV com uma coluna chamada isbn. Cada linha é validada; obras sem ficha entram na fila de análise.';

  @override
  String get importacaoAceitos => 'Aceitos';

  @override
  String get importacaoRejeitados => 'Rejeitados';

  @override
  String get importacaoNaoEncontrados => 'Não encontrados';

  @override
  String get importacaoPendentes => 'Análises pendentes';

  @override
  String get importacaoAndamento => 'Importação em andamento…';

  @override
  String get relatorio => 'Relatório';

  @override
  String get distribuicaoFaixa => 'Distribuição por faixa';

  @override
  String get alertasFrequentes => 'Alertas mais frequentes';

  @override
  String get obrasAcimaIdade => 'Obras acima da idade de referência';

  @override
  String get nenhumaAcimaIdade => 'Nenhuma obra acima da idade de referência.';

  @override
  String get exportarCsv => 'Exportar CSV';

  @override
  String get membros => 'Membros';

  @override
  String get convidarMembro => 'Adicionar membro';

  @override
  String get papelGestor => 'Gestor';

  @override
  String get papelBibliotecario => 'Bibliotecário';

  @override
  String get papelProfessor => 'Professor';

  @override
  String get situacaoFicha => 'Situação da ficha';

  @override
  String get semOrganizacao => 'Você ainda não participa de uma escola ou biblioteca.';

  @override
  String get criarOrganizacao => 'Cadastrar escola ou biblioteca';

  @override
  String get nomeOrganizacao => 'Nome da instituição';

  @override
  String get colunaObra => 'Obra';

  @override
  String get colunaAlertas => 'Alertas';

  @override
  String get colunaNivelLeitura => 'Nível de leitura';

  @override
  String get quantidade => 'Quantidade';

  @override
  String get removerMembro => 'Remover';

  @override
  String get revisaoTitulo => 'Revisão editorial';

  @override
  String get filaRevisao => 'Fichas aguardando revisão';

  @override
  String get filaVazia => 'Nenhuma ficha aguardando revisão.';

  @override
  String get contestacoesAbertas => 'Contestações abertas';

  @override
  String get motivoMudanca => 'Motivo da mudança';

  @override
  String get motivoObrigatorio => 'Descreva o motivo da mudança.';

  @override
  String get publicarRevisao => 'Publicar revisão';

  @override
  String get revisaoPublicada => 'Revisão publicada.';

  @override
  String faixaRecalculada(String faixa) {
    return 'Faixa recalculada: $faixa';
  }

  @override
  String get responderContestacao => 'Responder';

  @override
  String get aceitarContestacao => 'Aceitar';

  @override
  String get recusarContestacao => 'Manter ficha';

  @override
  String get resposta => 'Resposta';

  @override
  String consultasN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n consultas',
      one: '1 consulta',
      zero: 'Nenhuma consulta',
    );
    return '$_temp0';
  }

  @override
  String get carregando => 'Carregando…';

  @override
  String get tentarNovamente => 'Tentar de novo';

  @override
  String get erroGenerico => 'Algo não saiu como esperado. Tente de novo em instantes.';

  @override
  String get erroRede => 'Sem conexão com o Entrelinhas. Confira sua internet.';

  @override
  String get erroSessao => 'Sua sessão expirou. Entre de novo.';

  @override
  String get cancelar => 'Cancelar';

  @override
  String get salvar => 'Salvar';

  @override
  String get excluir => 'Excluir';

  @override
  String get confirmar => 'Confirmar';

  @override
  String get voltar => 'Voltar';

  @override
  String get fechar => 'Fechar';

  @override
  String get editar => 'Editar';

  @override
  String get ok => 'Ok';

  @override
  String get copiado => 'Link copiado.';

  @override
  String get verFichaCompleta => 'Ver a ficha completa';

  @override
  String get tipoAcervo => 'Acervo';

  @override
  String get tipoTurma => 'Turma';

  @override
  String get situacaoPublicada => 'Publicada';

  @override
  String get situacaoEmAnalise => 'Em análise';

  @override
  String get situacaoSemFicha => 'Sem ficha';

  @override
  String get situacaoEmRevisao => 'Em revisão';

  @override
  String get situacaoIndisponivel => 'Indisponível';

  @override
  String get botaoPrevia => 'Ver faixa recalculada';

  @override
  String get simplesNaoCadastrado => 'Livro não cadastrado';

  @override
  String simplesNaoCadastradoTexto(String isbn) {
    return 'Lemos o ISBN $isbn, mas ele não está entre os livros cadastrados.';
  }

  @override
  String get simplesVerCatalogo => 'Livros cadastrados';

  @override
  String simplesIsbn(String isbn) {
    return 'ISBN $isbn';
  }

  @override
  String get simplesSaudacao => 'Aponte a câmera para o código de barras e descubra o livro.';

  @override
  String get simplesBuscarDica => 'Buscar por título, autor ou ISBN';

  @override
  String get simplesEscanearTitulo => 'Escanear um livro';

  @override
  String get simplesEscanearTexto => 'Use o código de barras no verso';

  @override
  String get simplesEscanear => 'Escanear';

  @override
  String get simplesRecentes => 'Vistos recentemente';

  @override
  String get simplesVerTudo => 'Ver tudo';

  @override
  String get simplesInicio => 'Início';

  @override
  String get simplesHistorico => 'Histórico';

  @override
  String get simplesHistoricoVazio => 'Os livros que você escanear aparecem aqui.';

  @override
  String get simplesLimparHistorico => 'Limpar';

  @override
  String get simplesNadaEncontrado => 'Nenhum livro cadastrado com esse nome.';

  @override
  String get simplesDadosLivro => 'Dados do livro';

  @override
  String get simplesCampoTitulo => 'Título';

  @override
  String get simplesCampoAutor => 'Autor';

  @override
  String get simplesCampoEditora => 'Editora';

  @override
  String get simplesCampoIsbn => 'ISBN';

  @override
  String get simplesEscanearOutro => 'Escanear outro livro';

  @override
  String get simplesCadastrado => 'Livro cadastrado';

  @override
  String get simplesForaDoCatalogo => 'Fora do catálogo';

  @override
  String simplesResultados(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n resultados',
      one: '1 resultado',
    );
    return '$_temp0';
  }
}
