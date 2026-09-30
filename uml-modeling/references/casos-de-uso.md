# Casos de Uso — Regras Detalhadas

Fonte: `RMAC_ModelacaoComUMLp1` (P1). O tipo de diagrama mais rico em regras de processo: captura as **funcionalidades primárias** do sistema num formato compreensível por utilizadores não técnicos. Os diagramas de casos de uso são os **elementos primários e inultrapassáveis da fase de análise** — tudo o que se segue se suporta neles.

## 1. Levantamento de requisitos

1. Realizar **da forma mais interativa possível** — é a tarefa que mais difere de todas as outras do ciclo de vida.
2. Expressar requisitos do utilizador na **terminologia própria do problema**, do **ponto de vista operacional**.
3. **Separar claramente** requisitos do utilizador (necessidades) de requisitos do sistema — estes são consequência natural daqueles. O erro clássico é a **amálgama**: necessidades do utilizador misturadas com modelos do sistema e decisões de conceção.
4. **Filtrar a informação do cliente**:
   - Demasiado genérica ("tem que ser fácil de usar") → pedir critério concreto e mensurável.
   - Orientada à solução ("eu quero uma base de dados") → eliminar a decisão de conceção, manter a necessidade por trás.
5. Atitude: requisitos **não são um fim em si mesmos**, são recursos para as fases seguintes. Um levantamento deficiente terá repercussões gravíssimas na conceção/implementação.

## 2. Fronteira do sistema — os 4 critérios ("casca da cebola")

O sistema é um macro-objeto que interage com o meio envolvente, modelado em camadas (utilizadores → sensores/atuadores → interfaces → sistema). Um objeto **NÃO pertence ao sistema** se:

1. O problema refere-o explicitamente na interface com **dispositivos já existentes**;
2. **Já existe** no ambiente do sistema (não será desenvolvido como componente do sistema);
3. **Fornece e/ou recebe** informações/comandos do sistema (não será entregue com o sistema);
4. É **implementado como pessoa** que monitoriza saídas, envia informações/comandos, ou é diretamente afetada pelas ações do sistema.

**Em todas as outras situações, pertence ao sistema a projetar.** O levantamento vai da camada mais externa (requisitos do utilizador) para a mais interna (requisitos do sistema).

## 3. Diagrama de contexto

- Modela **como caixa preta todas as camadas exceto a mais externa**.
- Cada ator representa um **papel** perante o sistema; atores podem corresponder a classes de utilizadores (um utilizador ↔ vários atores).
- **Nomenclatura de atores**: pensar unicamente em **papéis**, nunca em pessoas ("o António") nem profissões/títulos literais ("o técnico de reparação"). Um papel abstrato tipo "Operador" ou "Projetista" está certo; "Engenheiro de Manutenção Sénior" está errado.
- Atores não-humanos: usar **estereótipos** com símbolo adequado («worker», «internal worker», «entity», ou retângulo `«system»` para sistemas externos).
- **Erro a evitar**: representar fluxos de mensagens no diagrama de contexto é **prematuro** antes de existirem os casos de uso.
- Construir o contexto **antes** dos casos de uso: primeiro a lista de atores, depois os casos de uso de cada um. Iterar — atores podem surgir/alterar-se durante a descoberta; "os atores são um pretexto e um meio para chegar aos casos de uso".

## 4. Cenários e casos de uso

- **Caso de uso** = interação típica entre um ator e o sistema, com **objetivo do ator** (nome: verbo + complemento).
- Levantar **por cenários concretos** de utilização (instâncias do caso de uso), não por idealizações abstratas — pergunta-chave: "o que é que este ator precisa de conseguir fazer?"
- **Podar cenários**: manter apenas os indispensáveis; ignorar pequenas variações sem valor funcional. A explosão de cenários é o erro clássico.
- Stakeholders ficam representados pelos atores → requisitos organizados por sensibilidade de grupo.

## 5. Relações entre casos de uso

| Relação | Quando | Exemplo (P1) |
|---|---|---|
| **`«include»`** | Comportamento **obrigatório** do base, fatorizado num "inclusion use case" (concreto). O base **incorpora sempre** o incluído. | *Place Order* `«include»` *Supply Customer Data*, *Arrange Payment* |
| **`«extend»`** | Comportamento **opcional/variante** ("extension use case") que acrescenta ao base em condições específicas. | *Request Catalog* `«extend»` *Place Order* |
| **Generalização (UC)** | Variantes concretas especializam um caso **abstrato** ("abstract parent use case"). | *Pay Cash*, *Arrange Credit* ← filhos de *Arrange Payment* |
| **Generalização (atores)** | Um papel é especialização de outro e **herda as suas comunicações** — evita duplicar associações ator–UC. | *Salesperson* herda de *Supervisor* |

Regra prática: se dois casos de uso partilham passos **sempre presentes** → `«include»`; se o passo só acontece **às vezes** → `«extend»`; se há uma família de casos com diferenças substanciais → generalização.

## 6. Refinamento (sub-casos de uso)

- Um caso de uso refina-se em sub-casos em **duas (ou mais) vistas ortogonais** — mecanismo de **controlo da complexidade**:
  - Vista 1: refinamento **por especialização de funcionalidades** (`{U.C.n.m}` por sub-funcionalidade);
  - Vista 2: refinamento **por desagregação** (por passos/fases do fluxo).
- **Abordagem orientada ao risco (risk-driven)**: refinar primeiro as funcionalidades **mais complexas ou mais relevantes**; não refinar tudo.
- Erro a evitar: refinamento que espelha a arquitetura interna (módulos) em vez dos objetivos do ator — é decomposição funcional disfarçada.

## 7. Descrição de casos de uso

- **Para cada caso de uso deve existir uma descrição do comportamento** — sem exceção.
- **Primeira fase: texto informal em linguagem natural** (passos numerados, pré-/pós-condições). Razão: manter compatibilidade de linguagem com o cliente, preservando a sua capacidade de **analisar, criticar e validar**.
- Formalizar depois com diagramas de interação (ver `interacao.md`) — que documentam **cenários imputados a requisitos**.

## 8. Notação essencial

- Ator (boneco); caso de uso (elipse com `{U.C.n}` opcional dentro da fronteira); associação de comunicação ator–UC (linha sólida).
- **Fronteira do sistema**: retângulo com o **nome do sistema** — sempre presente.
- `«include»`/`«extend»`: dependência tracejada com estereótipo (seta do base para o incluído no include; do extension para o base no extend).
- Generalização: seta triangular vazia para o pai.
