# Identificação do livro pelo código de barras

**Escopo atual:** só código de barras (EAN-13 com ISBN). O reconhecimento pela capa
(detector no aparelho, OCR, modelo de imagem e a pasta `ml/`) foi retirado por enquanto.
A versão anterior está no histórico do git, no merge do PR #1.

## Fluxo

1. **Celular (Android/iOS).** O ML Kit lê EAN-13 ao vivo, a cerca de 9 quadros por segundo e fora da thread da interface. A
   máquina de estados (`app/lib/funcionalidades/escanear/dominio/maquina_scanner.dart`)
   reage assim:
   - EAN de **livro** (prefixo 978/979, dígito verificador correto): vibra e consulta
     `GET /v1/obras/isbn/{isbn}` na hora, sem enviar foto.
   - EAN que **não é de livro** (produto, revista): contorno em tom de alerta e o aviso
     "O código lido não é de um livro"; continua procurando.
   - Código visto mas ainda não decodificado: contorno branco acompanhando o código.
   - Pouca luz: sugere a lanterna.
2. **Web, galeria ou captura manual.** O app reduz a foto para cerca de 1600 px e envia a
   `POST /v1/reconhecimento`. O servidor tenta ler o código com zxing-cpp em várias versões
   da imagem: original, realce local (CLAHE), ampliada, binarizada e girada.
   A foto não é guardada.
3. Resultado:
   - `identificado`: abre a ficha.
   - `nao_identificado`: ISBN válido, mas fora do catálogo local e das fontes externas.
     Abre "Cadastrar obra" com o ISBN preenchido.
   - `nao_e_livro` ou `sem_codigo`: tela com "Escanear de novo", "Digitar ISBN" e "Buscar
     pelo título".

"Digitar ISBN" está sempre disponível na tela do scanner.

## API

`POST /v1/reconhecimento` (multipart):

| Campo | Obrigatório | Uso |
|---|---|---|
| `imagem` | sim, se não houver `isbn` | JPEG, PNG ou WebP, até 8 MB |
| `isbn` | não | ISBN já lido pelo aparelho; o servidor confere antes de aceitar |

Resposta: `{"status", "obra", "isbn", "tempo_ms"}`.

## Verificado e não verificado

- **Verificado:**
  - Leitura no servidor com testes: código em pé, girado, pequeno numa foto grande e EAN de
    produto.
  - Rota com testes: identificado, fora do catálogo, não é livro, sem código, ISBN do
    aparelho e validação da entrada.
  - Fluxo web de ponta a ponta no Chromium com câmera falsa: a captura leu o ISBN e abriu
    a ficha.
- **Não verificado:**
  - Leitura ao vivo com o ML Kit num celular de verdade (não há aparelho neste ambiente).
  - A orientação das caixas do ML Kit em relação à prévia.

## Para voltar a ter reconhecimento pela capa

O banco ainda tem as tabelas `capas` e `amostras_reconhecimento` e a coluna
`usuarios.contribuir_imagens`. Elas ficaram sem uso e foram mantidas para não exigir uma
migração destrutiva. O código e as medições anteriores (top-1 de 66% em capas sintéticas)
podem ser recuperados do histórico.
