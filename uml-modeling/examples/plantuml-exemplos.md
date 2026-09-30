# Exemplos PlantUML por Tipo de Diagrama

Exemplos renderizáveis que modernizam a notação UML 1.x dos materiais RMAC (diagramas de "colaboração" → comunicação UML 2.x). Renderizar com:

```bash
java -jar plantuml.jar -charset UTF-8 -o ../media diagrama.puml
```

## 1. Diagrama de Contexto (casca da cebola — caixa preta)

```plantuml
@startuml
left to right direction
actor "Projetista" as Prj
actor "Empreiteiro Geral" as Emp

rectangle "Sistema X" {
  usecase "Funcionalidade principal" as CORE
}

Emp --> CORE : (in) dados de entrada
CORE --> Emp : (out) entregáveis
@enduml
```

Nota: sem fluxos de mensagens detalhados — são prematuros antes dos casos de uso (P1). Atores = papéis.

## 2. Diagrama de Casos de Uso (nível zero, com include/extend/generalização)

```plantuml
@startuml
left to right direction
skinparam usecase {
  BackgroundColor White
  BorderColor Black
}

actor Projetista
actor Administrador

rectangle "Plataforma" {
  usecase "{U.C.1}\nAutenticar" as UC1
  usecase "{U.C.2}\nGerir Projetos" as UC2
  usecase "Validar Dados" as UC2x
  usecase "Pagar" as Pay
  usecase "Pagar com Cartão" as Card
  usecase "Pagar em Numerário" as Cash
}

Projetista -- UC1
Projetista -- UC2
Administrador -- UC1

UC2 ..> UC2x : <<include>>
Card --|> Pay
Cash --|> Pay
@enduml
```

Nota: `«include»` para obrigatório; generalização (triângulo) para variantes de um caso abstrato. `«extend»` seria `Extension ..> Base : <<extend>>`.

## 3. Diagrama de Sequência (comportamento complexo)

```plantuml
@startuml
actor Projetista
participant ":Plataforma" as P
participant ":ModuloRisco" as M
database ":BD" as BD

Projetista -> P : acionar análise()
activate P
P -> M : avaliar(dados)
activate M
M -> BD : ler precedências()
BD --> M : matriz
M --> P : perfil de risco
deactivate M
P --> Projetista : confirmação
deactivate P
@enduml
```

Nota: ativações cheias = a computar; retornos tracejados. Nível 2 (interno funcional, sem conceção estrutural).

## 4. Diagrama de Comunicação (ex-colaboração; interações simples)

```plantuml
@startuml
object ":Order" as o
object ":Customer" as c

c -> o : 1: confirm()
o -> c : 1.1: validar dados()
@enduml
```

Nota: numeração aninhada `1.1` marca a sequência; usar só quando a lógica é simples.

## 5. Diagrama de Classes (associação, composição, herança)

```plantuml
@startuml
class Order {
  -date: Date
  +confirm(): void
  +cancel(): void
}
class LineItem {
  -quantity: int
}
abstract class Payment {
  +{abstract} authorize(): bool
}
class CardPayment
class CashPayment

Order "1" *-- "1..*" LineItem : inclui
Order "1" --> "1" Payment : Arrange Payment
Payment <|-- CardPayment
Payment <|-- CashPayment
@enduml
```

Nota: composição = diamante cheio (`*--`); agregação seria diamante oco (`o--`). Abstrata em itálico (PlantUML: `abstract`). Visibilidade `+`/`#`/`-`.

## 6. Diagrama de Atividades (branch + fork/join + fluxo de objetos)

```plantuml
@startuml
start
:Receber encomenda;
if (tipo?) then (simples)
  :Processar direta;
else (assinatura)
  :Agendar entregas;
endif
fork
  :Preparar artigos;
fork again
  :Preparar faturação;
end fork
:Expedir;
:Order [Delivered];
stop
@enduml
```

Nota: guards entre `[...]` mutuamente exclusivos e completos; fork/join em par; objeto com estado entre `[...]`.

## 7. Diagrama de Estados (entry/exit, transição interna)

```plantuml
@startuml
[*] --> Available
Available --> Sold : buy / emit ticket()
Sold --> Sold : exchange / reprint()  [mesma sessão]
Sold --> Available : unlock
Available --> [*]
@enduml
```

Nota: `evento [guard] / ação`; transição interna (`Sold --> Sold`) não re-executa entry/exit; estados = situações (adjectivos), eventos = verbos.

## 8. Diagrama de Pacotes («access» vs «import»)

```plantuml
@startuml
package "UI" {
}
package "Negocio" {
  class ServicoEncomendas
}
package "Dados" {
  class Repositorio
}

UI ..> Negocio : <<import>>
Negocio ..> Dados : <<access>>
@enduml
```

Nota: `«import»` adiciona públicos ao namespace; `«access»` apenas permite ver.

## 9. Diagrama de Componentes e Deployment

```plantuml
@startuml
node "Servidor" as srv {
  component "TicketSeller" as ts
  database "TicketDB" as db
}
node "Kiosk" as k {
  component "KioskUI" as kui
}

ts -- db
kui -- ts : <<TCP/IP>>
@enduml
```

Nota: nível de descrição (tipos) e nível de instância (`nome:Tipo`) não se misturam no mesmo diagrama.

## 10. Checklist de revisão antes de dar o diagrama por bom

- [ ] Nomes vêm do domínio do problema (nada de "Manager"/"Handler")?
- [ ] Atores são papéis (não pessoas/cargos)?
- [ ] Fronteira do sistema presente e com nome?
- [ ] Nível único de abstração no diagrama (sem misturar análise com conceção)?
- [ ] include vs extend corretos (obrigatório vs opcional)?
- [ ] Multiplicidades e guards completos?
- [ ] Restrições não representáveis em constricções/OCL, não em prosa?
