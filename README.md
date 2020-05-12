## Iniciando o projeto
Dentro da raiz do diretório do projeto, a partir do terminal, executar o arquivo `bin/setup`
para que todas as dependências sejam instaladas e o banco de dados configurado. Nesta etapa, a
aplicação fará uso de uma API para que o banco de dados seja carregado com todas as cidades e
estados do brasil, e portanto, é imprescindível que a internet esteja acessível

Uma vez que o carregamento tenha sido concluído, basta executar o seguinte comando: `ruby index.rb`.

## Funcionamento
A execução do projeto ocorre inteiramente pelo terminal e consiste em uma tela de menu a partir da
qual todas as suas funcionalidades podem ser acessadas:
  1. Ranking dos nomes mais comuns em uma determinada Unidade Federativa (UF)
  2. Ranking dos nomes mais comuns em uma determinada cidade
  3. Frequência do uso de um nome ao longo dos anos

Durante o seu ciclo de vida, para cada uma das funcionalidades, a aplicação tende a fazer uso das
informações provindas do banco de dados (sqlite3), do arquivo 'assets/populacao_2019.csv' e também
das APIs disponibilizadas pelo IBGE.

## Gems utilizadas
`rest-client` e `terminal-table`

## Observações
Foi observado que para a listagem da frequência de nomes, as décadas retornadas poderiam não ser
iguais para todos eles
  Ex: O nome 'João' retornava a frequência de nomes dos anos 1930 até 2010, já o nome 'Abreu'
  retornava a frequência de nomes somente a partir de 1940
Para que a exibição das tabelas não fosse afetada, antes de qualquer nome ser consultado, a aplicação
antes de mais nada faz uma requisição a um nome que possivelmente trará de fato todas as décadas
disponibilizadas pelo IBGE e que servirá então de base no momento em que as consultas de outros
nomes forem efetuadas