# Proveniência — `skill-inspector`

Vendored verbatim de um repositório de terceiros. **Não é de authorship
local.** Este ficheiro existe para deixar registado de onde veio, com que
licença, e o que exatamente foi trazido.

## Origem

| Campo | Valor |
|---|---|
| Projeto | NVIDIA SkillSpector |
| Repositório | <https://github.com/NVIDIA/SkillSpector> |
| Ficheiro | `skills/skill-inspector/SKILL.md` |
| Commit | `2226747e4ca97198bb82faf5085b8a75f2e1dc02` (main, 2026-09-30) |
| Licença | Apache License 2.0 (SPDX `Apache-2.0`) — <https://github.com/NVIDIA/SkillSpector/blob/main/LICENSE> |
| Retrieved | 2026-09-30 |

## O que foi trazido

Apenas `SKILL.md` (7213 bytes), cópia byte-exata do upstream no commit acima.
A pasta `skills/skill-inspector/` do upstream contém apenas este ficheiro, pelo
que a cópia está completa.

## O que NÃO foi trazido

O repositório upstream tem ~490 ficheiros. Ficaram de fora, deliberadamente:

- `src/` — o scanner em Python (116 ficheiros); a skill invoca o binário
  `skillspector` se estiver instalado no sistema e, caso contrário, recorre à
  revisão manual described no próprio `SKILL.md`.
- `tests/` — 186 fixtures, muitos deles skills **maliciosas** de propósito
  (prompt injection, exfiltração). Não devem entrar neste repositório.
- `.github/`, `Dockerfile`, `Makefile`, `pyproject.toml`, `package.json`,
  `uv.lock`, `contrib/`, `docs/`, `.opencode/`, `.env.example`, `.pre-commit-config.yaml`.

Se alguma vez precisares do scanner, instala-o à parte a partir do upstream —
não o copies para aqui.

## Notas de manutenção

- O `SKILL.md` está **inalterado**: não foi reformatado, nem traduzido, nem
  alinhado com as convenções deste repositório (ver `../AGENTS.md` §Skill
  Conventions). É deliberado — assim a diferença face ao upstream é sempre
  zero e uma atualização é só substituir o ficheiro.
- Para atualizar: descarregar o `SKILL.md` do commit novo, substituir o
  ficheiro, e atualizar o SHA e a data na tabela acima.
- `SKILL.md` não tem header de licença próprio; a Apache-2.0 do repositório
  aplica-se ao conteúdo. Este ficheiro cumpre a atribuição devida.
