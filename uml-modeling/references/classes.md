# Diagramas de Classes — Regras e Notação

Fonte: `RMAC_ModelacaoComUMLp3` (P3), com princípios de `RMAC_MetodosOrientadosAosObjectos` (MET). Catálogo de notação + convenções inferidas dos exemplos do autor.

## 1. Convenções de nomenclatura (dos exemplos, tratadas como regra)

- **Classes**: substantivos capitalizados (`Subscription`, `Reservation`, `Customer`) — vocabulário do **domínio do problema**, nunca da tecnologia (MET).
- **Atributos**: substantivos minúsculos com tipo (`date: Date`, `priceCategory: Category`).
- **Operações**: verbos (`cost()`, `reserve(...)`, `cancel()`, `confirm()`).
- **Nível de abstração**: "nem demasiado alto nem demasiado baixo"; a classificação correta depende da perspetiva relevante para o problema (MET).

## 2. Estrutura da classe

- Três compartimentos: **nome / atributos / operações** (compartimentos vazios podem omitir-se).
- **Itálico** = classe abstrata (ou `{abstract}`).
- **Estereótipo** acima do nome (`«interface»`, `«entity»`); **tagged values** `{tag = value}`.
- Compartimento opcional de **responsabilidades** (texto) quando a semântica não cabe na notação.

## 3. Visibilidade e sintaxe

| Símbolo | Visibilidade |
|---|---|
| `+` | pública |
| `#` | protegida |
| `-` | privada |

- Atributo: `nome: Tipo = valorInicial`; multiplicidade `[*]` para "muitos".
- Operação: `nomeOp(p1: T1): TRetorno`; operação abstrata em itálico.

## 4. Associações

- **Associação binária**: linha com nome (verbo/ substantivo verbalizado), **role names** nos extremos (`source`, `owner`) quando o papel não é óbvio pelo nome da associação.
- **Multiplicidades**: `1`, `0..1`, `*`, `1..*`, `3..6`, `{ordered}` para coleções ordenadas.
- **Auto-associação**: associação de uma classe consigo própria (com roles para distinguir extremos).
- **Associação qualificada**: qualificador junto à classe que qualifica; a multiplicidade depois do qualificador exprime o acesso (ex.: `Show [performance: Date, seat: SeatNumber] → Ticket` com multiplicidade `0..1` — acesso a um bilhete único).
- **Association class** (classe de associação): atributos que pertencem à **relação** e não a nenhuma das classes (ex.: `DonationLevel` entre `Organization` e `Person`) — tracejado da classe para a linha de associação.

## 5. Generalização / herança

- Seta triangular vazia para a superclasse; dois estilos: **direto** (setas individuais) ou **árvore** (tronco partilhado — preferir para muitos filhos).
- Tipos: **simples**, **múltipla** (filho herda de 2+ pais — herda atributos e operações de ambos), **múltipla repetida** (mesmo ancestral chega por 2 caminhos).
- Subclasses **redefinem** operações (ex.: `confirm()` abstrato em `Order`, implementado em `MailOrder` e `BoxOfficeOrder`).
- Usar quando existe relação "**é-um**" com partilha real de estrutura e comportamento — não para classificar por conveniência.

## 6. Todo–parte: agregação vs. composição

| Relação | Notação | Semântica | Exemplo |
|---|---|---|---|
| **Agregação** | diamante **oco** no todo | a parte pode **existir fora** do todo | `Subscription ○— Performance` |
| **Composição** | diamante **cheio** no todo | a parte **só existe** no todo (nasce e morre com ele) | `Order ◆— LineItem`, `Order ◆— CustomerInfo` |

Teste: se a parte faz sentido sozinha e pode ser partilhada → agregação; se é criada/destruída pelo todo → composição.

## 7. Interfaces e realização

- Interface `«interface»` define operações (`setDefault(choice: Choice)`, `getChoice(): Choice`).
- **Realização**: tracejada com triângulo vazio (especificação → implementações, ex.: `ChoiceBlock` ← `PopUpMenu`, `RadioButtonArray`).

## 8. Constricções e OCL

- **Regra**: restrições que a notação gráfica não cobre **nunca ficam implícitas** — exprimir em constricção `{...}` junto ao elemento.
- OCL ex.: `self.attrB <= self.comp.attrA`; constricção entre objetos: `{person.employer = person.boss.employer}`.
- Notas (retângulo com dobra) para semântica textual complementar.

## 9. Diagrama de objetos

- Instâncias `nome:Classe` sublinhadas com **valores** de atributos (`x = 0.0`) e **links** nomeados (`PartOf`).
- Função: exemplificar **instantes concretos** do diagrama de classes; na análise, o **primeiro diagrama de objetos** é o artefacto que liga casos de uso aos diagramas de interação (arquitetura ideal, ainda não estrutural — ver `interacao.md`).

## 10. Erros comuns

- Nomes tecnológicos em vez do domínio ("DataManager", "Handler").
- Herança sem relação "é-um" real (herança por reutilização de código).
- Multiplicidades por preencher — toda a associação tem de as ter.
- Atributos da relação pendurados numa das classes em vez de numa association class.
- Restrições descritas em prosa fora do diagrama em vez de constricções.
