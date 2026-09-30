# Outros Diagramas — Pacotes, Componentes, Deployment

Fonte: `RMAC_ModelacaoComUMLp5` (P5). Diagramas estruturais de organização e implantação.

## 1. Diagrama de Pacotes

- **Pacote**: agrupamento de elementos; nome no separador ou no corpo.
- **Subsistemas**: pacotes com estereótipo `«subsystem»` — unidades grandes de comportamento coeso.
- **Generalização de pacotes**: variações especializam um pacote base (ex.: `Kiosk Selection` e `Clerk Selection` especializam `Seat Selection`).
- **Dependências**: tracejada do dependente para o de que depende (incl. dependência de pacote externo).

### «access» vs «import» (semântica precisa)

| Estereótipo | Semântica |
|---|---|
| **`«access»`** | Y pode **ver** os conteúdos públicos de Z, **sem alterar** o namespace de Y |
| **`«import»`** | Z **adiciona** os conteúdos públicos de X **ao namespace** de Z (referências diretas sem prefixo) |

### Visibilidade de conteúdos

- `+Classe` — pública (visível fora do pacote).
- `-Classe` — privada (acessível **só dentro** do pacote, ex.: `class G` só dentro de `package X`).
- Pacotes **aninhados** (subpackage dentro de pacote) para hierarquias profundas.

**Erros comuns**: import em vez de access quando não se quer poluir o namespace; pacotes-dependências cíclicas sem justificação; pacotes "saco de gatos" sem coesão.

## 2. Diagrama de Componentes

- **Componente**: unidade substituível com interface definida.
- **Dois tipos de dependência**:
  - **Realização**: componente **realiza** uma interface/operação (tracejada com triângulo).
  - **Utilização** (`use`): tracejada com `«use»` — precisa de, mas não fornece (ex.: `ATM-GUI ..> Update`).
- **Interfaces supplier/client**: fornecedor disponibiliza a operação ao cliente (ex.: `TicketSeller` fornece `charge` à `CreditCardAgency`).
- **Estereótipos úteis**: `«database»` para componentes de dados (`Account`, `TicketDB`).
- **Ligação a atores**: cada ator liga-se ao componente/interface com que interage (`ManagerInterface`, `KioskInterface`, `ClerkInterface`).

**Erros comuns**: componente com muitas interfaces misturadas (sem coesão); dependências de utilização não marcadas (parece tudo realização).

## 3. Diagrama de Deployment (disposição)

- **Dois níveis — nunca misturar no mesmo diagrama**:
  - **Nível descrição**: **tipos** de nós e componentes (`TicketServer`, `Kiosk`) com dependências e multiplicidade de nós ("quantas instâncias existem tipicamente").
  - **Nível instância**: instâncias concretas — sintaxe `nomeInstância:TipoNó` (`Main St. kiosk: Kiosk`, `headquarters: TicketServer`), com componentes instância dentro (`c1:CompType`).
- **Nós**: cubos — dispositivo de execução (servidor, quiosque, terminal).
- **Communication links**: linhas entre nós, estereotipadas com o protocolo/meio `«connectionType»` (ex.: «TCP/IP»).
- **Interfaces** como círculos (lollipop): realização de interface pelo nó fornecedor; dependência de interface pelo cliente.
- **Bases de dados** como componente `«database»` dentro do nó servidor.

**Erros comuns**: tipos e instâncias no mesmo diagrama; esquecer o estereótipo do tipo de ligação; colocar componentes sem indicar em que nó executam.

## 4. Regras transversais aplicáveis

- Estereótipos, tagged values e constricções aplicam-se a **todos** estes diagramas — usar para adaptar a notação ao domínio.
- Estes diagramas descrevem **estrutura organizacional/implantação** — não lhes meter comportamento (isso é para sequência/estados/atividades).
- Nomes continuam a vir do domínio do problema; `«subsystem»` e componentes refletem unidades reconhecíveis pelo negócio, não camadas técnicas arbitrárias.
