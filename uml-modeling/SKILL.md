---
name: uml-modeling
description: "Boas práticas de modelação UML (base RMAC/UMinho): diagramas de casos de uso, sequência/comunicação, classes, atividades, estados, pacotes/componentes/deployment. Trigger phrases: casos de uso, diagrama de casos de uso, use case diagram, diagrama UML, UML diagram, diagrama de classes, class diagram, diagrama de sequência, sequence diagram, diagrama de estados, diagrama de atividades, modelo UML, atores do sistema, include extend"
---

# Modelação UML — Boas Práticas

Regras destiladas dos materiais de Modelação com UML (R. J. Machado, Universidade do Minho — `RMAC_ModelacaoComUMLp1–p5`, `RMAC_MetodosOrientadosAosObjectos`), escritas como instruções acionáveis. Terminologia UML 2.x. Exemplos renderizáveis em PlantUML em `examples/plantuml-exemplos.md`.

## Quando usar

- Levantar e especificar requisitos com casos de uso (atores, fronteira do sistema, cenários).
- Produzir ou rever qualquer diagrama UML: casos de uso, sequência/comunicação, classes, atividades, estados, pacotes, componentes, deployment.
- Decidir relações entre casos de uso (include/extend/generalização) ou entre classes (associação vs. agregação vs. composição).
- Refinar casos de uso em sub-casos sem cair em decomposição funcional.

## Processo de modelação (ordem obrigatória)

1. **Separar requisitos do utilizador dos requisitos do sistema** — nunca os misturar no mesmo diagrama/nível. Requisitos do utilizador: terminologia do problema, ponto de vista operacional (P1).
2. **Filtrar a informação do cliente**: eliminar decisões de conceção demasiado restritivas ("quero uma base de dados") e rejeitar requisitos vagos ("fácil de usar") — pedindo concreto (P1).
3. **Diagrama de contexto ANTES dos casos de uso**: é mais fácil listar primeiro os atores/papéis e depois obter os casos de uso de cada um. Iterativo — atores podem nascer/morrer durante a descoberta dos casos de uso; o importante são os casos de uso (P1).
4. **Capturar por cenários concretos**, não por idealizações abstratas — cenários são instâncias de um caso de uso. Podar variantes sem valor funcional (P1).
5. **Refinar risk-driven**: só os casos de uso mais complexos/relevantes se refinam; usar vistas ortogonais (especialização + desagregação) para controlar a explosão de sub-casos (P1).
6. **Descrição de cada caso de uso em linguagem natural** na primeira fase (passos numerados, pré/pós-condições) — o cliente tem de conseguir validar. Formalizar depois com diagramas de interação, que documentam *cenários* imputados a requisitos (P1, P2).

## Regras transversais

- **Nomes vêm do domínio do problema**, nunca da tecnologia (MET).
- **Ator = papel**, nunca pessoa ("o António") nem cargo profissional literal ("o supervisor de produção"); um utilizador pode desempenhar vários papéis (P1).
- **Nível de abstração correto**: nem demasiado alto nem demasiado baixo; a classificação depende da perspetiva relevante para o problema (MET).
- **Num diagrama de contexto, tudo menos a camada mais externa é caixa preta**; fluxos de mensagens no contexto são prematuros antes dos casos de uso (P1).
- Modelos devem ser: compreensíveis, completos, expressivos, corretos (P1).
- UML é notação, não método — o processo é nosso (MET).

## Guias de decisão rápidos

| Dúvida | Regra | Detalhe |
|---|---|---|
| Elemento dentro ou fora do sistema? | Fora se: interface com dispositivos existentes, já existe, fornece/recebe info do sistema, ou é pessoa que monitoriza/é afetada. Caso contrário, dentro (P1) | `references/casos-de-uso.md` |
| `«include»` vs `«extend»`? | include: comportamento **obrigatório** fatorizado do base; extend: comportamento **opcional/variante** que acrescenta ao base (P1) | `references/casos-de-uso.md` |
| Ator herda associações? | Generalização entre atores quando um papel é especialização de outro (Salesperson → Supervisor) (P1) | `references/casos-de-uso.md` |
| Sequência vs comunicação? | Comportamento complexo → sequência (mais legível); relações estáticas simples → comunicação (P2) | `references/interacao.md` |
| Agregação ou composição? | Parte pode existir fora do todo → agregação (diamante oco); parte só existe no todo → composição (diamante cheio) (P3) | `references/classes.md` |
| Que evento num estado? | call `op(a:T)` · change `when(exp)` · signal `sname(a:T)` · time `after(time)` (P4) | `references/atividades-estados.md` |
| «access» vs «import» entre pacotes? | access: ver públicos sem mudar namespace; import: adiciona públicos ao namespace (P5) | `references/outros-diagramas.md` |

## Erros comuns a evitar

- Amálgama de requisitos: necessidades do utilizador misturadas com conceção no mesmo artefacto (P1).
- Atores com nomes de pessoas ou de cargos (P1).
- Explosão de cenários: manter só os indispensáveis, ignorar pequenas variações (P1).
- Fluxos de mensagens no diagrama de contexto antes dos casos de uso existirem (P1).
- Refinar tudo em vez de risk-driven (P1).
- Diagramas de comunicação para comportamentos complexos (ficam ilegíveis) (P2).
- Restrições deixadas implícitas quando a notação não as cobre — usar constricções/OCL (P3).
- Guards de branch não mutuamente exclusivos ou incompletos (P4).

## Referências detalhadas

| Ficheiro | Conteúdo |
|---|---|
| `references/casos-de-uso.md` | Fronteira, atores, cenários, relações, refinamento, descrições — regras completas |
| `references/interacao.md` | Sequência e comunicação: níveis, notação, critério de escolha |
| `references/classes.md` | Classes: notação, associações, herança, todo-parte, interfaces, OCL |
| `references/atividades-estados.md` | Atividades e estados: notação, sintaxe de eventos/ações, decomposição |
| `references/outros-diagramas.md` | Pacotes, componentes, deployment |
| `examples/plantuml-exemplos.md` | PlantUML renderizável por tipo de diagrama |

## Renderização

Para gerar PNG a partir de `.puml`:

```bash
java -jar plantuml.jar -charset UTF-8 -o <pasta_saida> ficheiro.puml
```
