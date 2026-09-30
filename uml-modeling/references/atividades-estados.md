# Diagramas de Atividades e de Estados

Fonte: `RMAC_ModelacaoComUMLp4` (P4). Dois diagramas de comportamento: atividades modelam **fluxos de trabalho** (ações e ordem); estados modelam **ciclo de vida** de um objeto (eventos e reações).

## PARTE A — Diagramas de Atividades

### 1. Elementos e regras

- **Atividade**: ação com nome **verbal** ("set up order", "charge credit card"); iniciar nomes por verbo de ação.
- **Nó inicial e nó final** de atividade — todo o diagrama tem um começo e um (ou mais) fim(ns) explícitos.
- **Transição de conclusão** (seta simples): dispara quando a atividade termina — é o fluxo por omissão.

### 2. Decisões e paralelismo

- **Branch/decision**: losango com **guard conditions** entre parênteses rectos — `[single order]` / `[subscription]`.
  - **Regra**: guards mutuamente exclusivos e **completos** (cobrir todos os casos; usar `[else]` se necessário).
- **Merge**: losango que reúne alternativas (unbranch) — sem guards.
- **Fork/join** (barra de sincronização, "synch bar"):
  - **Fork** lança atividades **concorrentes**; **join** espera que **todas** terminem antes de prosseguir.
  - **Regra**: cada fork deve ter o seu join correspondente; não misturar fluxo de controlo e fluxo de objetos na mesma barra sem intenção clara.

### 3. Fluxo de objetos e responsabilidades

- **Objetos com estado** fluem entre atividades: `Order [Placed]` → Take Order → `Order [Entered]` → Fill Order → `Order [Filled]` → … → `Order [Delivered]`.
- **Regra**: usar o par atividade ↔ estado do objeto para mostrar a transformação dos dados ao longo do fluxo.
- **Afectação de responsabilidades**: responsável (ator/classe) ligado por tracejado às atividades que executa (ex.: Customer, Sales, Stockroom) — swimlanes/partições em UML 2.x.

### 4. Erros comuns

- Guards incompletos (faltam casos) ou sobrepostos.
- Fork sem join (fluxos concorrentes nunca sincronizados).
- Nomes de atividades substantivos ("processamento") em vez de verbos ("processar encomenda").
- Diagrama único misturando níveis de abstração (atividades de negócio com passos técnicos).

## PARTE B — Diagramas de Estados

Modelam o **ciclo de vida de um objeto de uma classe**: em que estados pode estar e como reage a eventos. Usar para objetos com comportamento dependente do histórico (Order, Reservation, Invoice).

### 1. Estrutura de um estado

- **Nome**: adjectivo/substantivo de situação (`Waiting`, `Available`, `Locked`, `Sold`, `Confirming`).
- **Entry action**: `entry / ação` — executa ao **entrar** no estado.
- **Exit action**: `exit / ação` — executa ao **sair**.
- **Transições internas**: `evento / ação` dentro do estado — respondem a eventos **sem mudar de estado e sem executar entry/exit**.

### 2. Transições

Sintaxe completa: `evento (parâmetros) [guard] / ação1; ação2`
Exemplos: `receive order [amount > $25]` · `approved / debit account()`

| Tipo | Semântica |
|---|---|
| **External** | Causa mudança de estado (ou auto-transição) com ação; **executa** exit/entry dos estados abandonado/entrado |
| **Internal** | Executa a ação **sem** mudar de estado **nem** exit/entry |
| **Completion** | **Sem evento trigger** — dispara quando a atividade do estado termina |

- Transição que **sai de um estado composto aborta** a atividade interna aninhada.

### 3. Eventos — 4 tipos (sintaxe)

| Tipo | Descrição | Sintaxe |
|---|---|---|
| **call** | pedido síncrono que espera resposta | `op (a:T)` |
| **change** | mudança de valor de expressão booleana | `when (exp)` |
| **signal** | comunicação assíncrona nomeada | `sname (a:T)` |
| **time** | tempo absoluto ou relativo | `after (time)` |

### 4. Ações — 8 tipos (sintaxe)

`target := expression` (atribuição) · `opname(arg, arg)` (call) · `new Cname(arg, arg)` (create) · `object.destroy()` (destroy) · `return value` (return) · `sname(arg, arg)` (send) · `terminate` · `[language specific]` (uninterpreted)

### 5. Decomposição e reutilização

- **Decomposição sequencial**: estado composto com sub-estados, inicial/final internos; **submachine reference** `include Identify` para reutilizar máquinas.
- **Decomposição concorrente**: regiões paralelas separadas por barra tracejada (ex.: `Incomplete` dividido em Lab / TermProject / FinalTest); a passagem ao estado seguinte exige **conclusão normal de todas as regiões**; saídas anormais (`abnormal exit`) levam a estados alternativos (`Failed`).
- **Regra**: fatorizar comportamento comum em **submáquinas** reutilizáveis (`include Help` a partir de vários estados).

### 6. Erros comuns

- Estados com nomes de atividades ("Processing" em vez da situação "Processing complete"/"Confirmed").
- External transition onde bastava internal (força entry/exit desnecessárias).
- Regiões concorrentes sem definição clara de quando o estado composto completa.
- Eventos de tipos misturados sem critério (signal vs. call indistintos).
