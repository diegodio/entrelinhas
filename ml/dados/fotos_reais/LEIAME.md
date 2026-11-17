# Fotos reais rotuladas

Esta pasta começa vazia. Ela recebe fotos de livros tiradas pela equipe, em condições
reais (livraria, estante, mão segurando o livro), para medir o reconhecimento de verdade.

## Como adicionar

1. Fotografe o livro com o celular, como uma pessoa faria na livraria. Varie a luz, o
   ângulo, a distância, e inclua casos com reflexo, etiqueta de preço e dedos na capa.
2. Salve a foto aqui (JPEG ou PNG). Use nomes simples: `jardim_01.jpg`.
3. Acrescente uma linha em `rotulos.csv` (crie o arquivo na primeira vez):

   ```
   arquivo,obra
   jardim_01.jpg,g12
   ```

   `obra` é o rótulo da obra no conjunto de avaliação (o campo `obra` de
   `ml/dados/sinteticas/manifesto.json`) ou, para avaliar contra o catálogo real, o id
   da obra no banco.
4. Rode `PYTHONPATH=backend backend/.venv/bin/python ml/avaliar.py`. O relatório separa
   o resultado das fotos reais do resultado sintético.

## Cuidados

- Fotografe só o livro. Nada de rostos, documentos ou telas com dados pessoais.
- As imagens não vão para o Git (ver `.gitignore`); guarde-as num armazenamento da equipe.
