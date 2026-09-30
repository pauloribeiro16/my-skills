# Diagramas de Interação — Sequência e Comunicação

Fonte: `RMAC_ModelacaoComUMLp2` (P2). Formalizam **cenários** (não os requisitos em si): cenários concebidos como formas típicas de funcionamento, **imputados aos requisitos** que documentam — manter esta rastreabilidade cenário ↔ requisito.

## 1. Os dois tipos

| Tipo | O que mostra | Quando preferir |
|---|---|---|
| **Sequência** | Fluxo e precedências das mensagens **explicitamente** (ordem visual no tempo) | Comportamentos **complexos** — mais dinâmico e legível |
| **Comunicação** (UML 2.x; "colaboração" em UML 1.x) | Relações estáticas (links) + mensagens **numeradas** | Comportamentos simples; quando interessa a **estrutura estática** |

**Critério do autor**: para comportamentos menos simples, os diagramas de comunicação tornam-se pouco legíveis e nada intuitivos — **erro a evitar**: usar comunicação para lógica complexa.

**Pré-condição de processo**: ambos exigem objetos — é preciso primeiro o **mapeamento casos de uso → objetos** do primeiro diagrama de objetos, que representa a arquitetura ideal **ainda não estrutural** (sem decisões de conceção estrutural).

## 2. Progressão em 3 níveis (nunca misturar níveis no mesmo diagrama)

**Diagramas de sequência** — cenários de:
1. Interação **sistema ↔ ambiente**, puramente funcional, **sem decisões de conceção**;
2. Interação **interna** entre componentes, ainda **funcional**, sem decisões estruturais;
3. Interação interna **com decisões de conceção estrutural** (estruturas de dados, proceduralização).

**Diagramas de comunicação** — os mesmos 3 níveis adaptados:
1. Contexto **com fluxo de mensagens**;
2. Interação **mista** (externa + interna);
3. Interação **interna**.

## 3. Notação — diagrama de sequência

- **Objeto**: `nome:Classe` (ex.: `:Order`); sublinhado. Objeto ativo vs. passivo.
- **Lifeline**: linha tracejada vertical abaixo do objeto.
- **Barra de ativação**: retângulo fino sobre a lifeline — sombreado/cheio = ativo (a computar); branco = passivo (à espera).
- **Mensagem síncrona**: seta cheia →; **retorno**: seta tracejada ← (opcional, com valor: `cost := reserve(order)`).
- **Criação**: mensagem para objeto novo (ou `create()`); seta para a cabeça do objeto criado no momento da criação.
- **Destruição**: `X` no fim da lifeline (ou `object.destroy()`).
- **Chamada recursiva**: mensagem do objeto para a própria ativação (nova barra por cima).
- **Iteração**: quadro de interação `loop` ou notação antiga `*[i:=1..n]`.
- **Concorrência**: paralelismo com `par` (UML 2.x) ou prefixos de thread (`F:`, `G1:`).

## 4. Notação — diagrama de comunicação

- Objetos ligados por **links** (como num diagrama de objetos) + mensagens numeradas sobre os links.
- **Numeração aninhada**: `1`, `1.1`, `1.1.1` — indica sequência e aninhamento de chamadas; sufixos `a`/`b` para respostas concorrentes.
- **Iteração**: `1.1 *[i:=1..n]: drawSegment(i)`.
- **Links estereotipados**: `«parameter»` (objeto passado como parâmetro), `«local»` (variável local), `«self»` (ligação a si próprio).
- **`{new}`**: objeto criado durante a interação; **multiobjeto**: coleção (ex.: `:Order[*]`) com mensagem à coleção ou a um elemento.
- Retorno com atribuição: `2: cost := reserve(order)`.

## 5. Erros comuns

- Saltar para o nível 3 (com conceção estrutural) durante a análise — misturar níveis.
- Fazer diagramas de interação sem o mapeamento prévio casos de uso → objetos.
- Comunicação com numeração profundamente aninhada (ilegível) — migrar para sequência.
- Cenários sem imputação a requisitos (perde-se a rastreabilidade).
