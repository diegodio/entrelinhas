// Tradução das chaves da rubrica (vindas da API) para os textos do ARB.

import '../../l10n/textos.dart';

extension RotulosRubrica on Textos {
  String eixo(String id) => switch (id) {
    'A1' => eixoA1,
    'A2' => eixoA2,
    'A3' => eixoA3,
    'A4' => eixoA4,
    'A5' => eixoA5,
    'A6' => eixoA6,
    _ => id,
  };

  String nivel(int n) => switch (n) {
    0 => nivel0,
    1 => nivel1,
    2 => nivel2,
    3 => nivel3,
    4 => nivel4,
    _ => '$n',
  };

  /// Em frases: "14+" vira "14 anos"; no selo continua "14+".
  String faixaEmFrase(String faixa) =>
      faixa == 'Livre' ? faixaLivre : faixaAnos(faixa.replaceAll('+', ''));

  String fonteAnalise(String fonte) => switch (fonte) {
    'texto_integral' => fonteTextoIntegral,
    'amostragem' => fonteAmostragem,
    'fontes_publicas' => fontePublicas,
    'metadados_e_conhecimento_previo' => fonteMetadados,
    _ => fonte,
  };

  String origem(String origem) => switch (origem) {
    'google_books' => origemGoogle,
    'open_library' => origemOpenLibrary,
    'cadastro_manual' => origemManual,
    _ => origemBase,
  };

  String plano(String plano) => switch (plano) {
    'familia' => planoFamilia,
    'escola' => planoEscola,
    _ => planoGratuito,
  };

  String papelOrganizacao(String papel) => switch (papel) {
    'gestor' => papelGestor,
    'bibliotecario' => papelBibliotecario,
    _ => papelProfessor,
  };

  String marcador(String chave) => switch (chave) {
    'empatia' => marcadorEmpatia,
    'repertorio_cultural' => marcadorRepertorioCultural,
    'pensamento_critico' => marcadorPensamentoCritico,
    'qualidade_estetica' => marcadorQualidadeEstetica,
    'conhecimento_historico' => marcadorConhecimentoHistorico,
    'desenvolvimento_moral' => marcadorDesenvolvimentoMoral,
    _ => chave,
  };

  String alerta(String chave) => switch (chave) {
    'morte_de_personagem_principal' => flagMorteDePersonagemPrincipal,
    'luto' => flagLuto,
    'morte_ou_maus_tratos_de_animal' => flagMorteOuMausTratosDeAnimal,
    'doenca_terminal' => flagDoencaTerminal,
    'bullying' => flagBullying,
    'violencia_escolar' => flagViolenciaEscolar,
    'gravidez_indesejada' => flagGravidezIndesejada,
    'aborto' => flagAborto,
    'violencia_sexual_fora_de_cena' => flagViolenciaSexualForaDeCena,
    'sequestro_ou_carcere' => flagSequestroOuCarcere,
    'automutilacao' => flagAutomutilacao,
    'suicidio' => flagSuicidio,
    'transtorno_alimentar' => flagTranstornoAlimentar,
    'dependencia_quimica' => flagDependenciaQuimica,
    'relacao_abusiva_romantizada' => flagRelacaoAbusivaRomantizada,
    'diferenca_de_poder_em_relacao_afetiva' => flagDiferencaDePoderEmRelacaoAfetiva,
    'discriminacao_sem_critica_narrativa' => flagDiscriminacaoSemCriticaNarrativa,
    'conteudo_religioso_sensivel' => flagConteudoReligiosoSensivel,
    'final_tragico' => flagFinalTragico,
    'acidente_grave' => flagAcidenteGrave,
    'arma_de_fogo' => flagArmaDeFogo,
    _ => chave.replaceAll('_', ' '),
  };

  String rotuloConfianca(double c) =>
      c < 0.45 ? confiancaBaixa : (c < 0.75 ? confiancaMedia : confiancaAlta);
}
