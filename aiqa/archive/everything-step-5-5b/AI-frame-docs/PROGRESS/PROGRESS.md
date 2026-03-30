# AI QA Framework — Progress Tracker

**Last updated:** 2026-03-24
**Status:** Phase 1 COMPLETE · Phase 1.5 — DEV/QA Modes + Repository Index (COMPLETE)

---

## Текущее состояние

Архитектура полностью задокументирована и выверена. Реализация не начата — все ниже это план с отметками выполненного.

---

## DONE — Что уже готово

### Архитектура и дизайн
- [x] Архитектурный документ `AI_QA_Framework_V1_Architecture.md` — task-centric модель, repo roles, contracts/adapters, orchestrator, evals
- [x] `deep-research-report.md` — PBI с acceptance criteria, YAML-схемами сущностей, mermaid-диаграммами lifecycle
- [x] `IDE_Task_Carrier_Pipeline_V1.md` — Task Carrier концепция, lifecycle, section ownership model
- [x] Полный requirements analysis (30 REQ, 7 GAP, 6 RISK) — зафиксирован в сессии 2026-03-24
- [x] System decomposition (10 компонентов, data flow, interfaces, dependencies)
- [x] Implementation plan — folder structure, Python скелеты, YAML контракты, CLI скрипты

### ETNA_TRADER — AI инфраструктура (repo: `domain`)
- [x] `.claude/` + `.cursor/` — 32 md / 38 mdc файлов (agents, rules, skills)
- [x] Skills: `/nf`, `/ct`, `/si`, `/sr`, `/udoc`, `/parallelization`, `/ai-settings`, `/skill-creator`
- [x] Rules: `tasks-artifact-layout`, `framework-qa`, `sync`, trading-specific conventions
- [x] Hooks: PostToolUse auto-sync `.claude` ↔ `.cursor`
- [x] docs/: `project-structure.md`, `testing-guide.md`, ADR templates
- [x] `tasks/` folder convention установлен

### Стратегия распространения на другие репо
- [x] Определены роли репозиториев: core / domain / experimental / external
- [x] Определён принцип: contracts → `generate_adapters.py` → `.claude/` / `.cursor/` в каждый репо
- [x] mobileLiteApp классифицирован как external, read-only, diagnostics-only

---

## TODO — Что осталось сделать

### Phase 1 — Foundation ✓ COMPLETE

**Core repo:** `C:/Reps/ai-tools/` — clean git init, full folder structure

- [x] Core repo `C:/Reps/ai-tools/` создан (git init, без истории из _ai-tools-export)
- [x] `aiqa/contracts/schemas/` — все 6 схем:
  - [x] `task_carrier.v1.yaml`
  - [x] `task_bundle.v1.yaml`
  - [x] `person_profile.v1.yaml`
  - [x] `person_state.v1.yaml`
  - [x] `repository.v1.yaml`
  - [x] `service.v1.yaml`
- [x] `aiqa/contracts/skills/` — 3 QA skill контракта:
  - [x] `qa.generate_test_plan.yaml`
  - [x] `qa.generate_test_cases.yaml`
  - [x] `qa.coverage_review.yaml`
- [x] `aiqa/contracts/agents/qa-agent.yaml`
- [x] `aiqa/orchestrator/taxonomy.yaml` — routing rules (keywords → skill, deterministic-first)
- [x] `aiqa/memory/people/profiles/` — artem.yaml, sergey.yaml, _template.yaml
- [x] `aiqa/memory/repositories/index/etna-trader.yaml` — subsystems, artifacts, paths
- [x] `aiqa/memory/services/service_map.yaml` — 5 сервисов etna-trader
- [x] `aiqa/infra/tool_permissions/allowlist.yaml` — role-based, default deny
- [x] `ETNA_TRADER/.aiqa/` — task carrier storage + шаблоны + gitignore
- [x] `ETNA_TRADER/.aiqa/people/active/` — artem.active.yaml, sergey.active.yaml

**Ключевые решения Phase 1:**
- GAP-1 ЗАКРЫТ: core repo = `C:/Reps/ai-tools/`, отдельный чистый репозиторий
- `.aiqa/` (с точкой) = runtime data в domain репо; `aiqa/` (без точки) = framework source в core репо

### Phase 1.5 — DEV/QA Modes + Repository Index ✓ COMPLETE

**Схемы (расширены):**
- [x] `repository.v1.yaml` — добавлены: `size_type`, `team`, `artifacts.docs`, `hotspots`
- [x] `task_bundle.v1.yaml` — добавлены: `mode`, `selection_strategy`, `hotspots_included`
- [x] `task_carrier.v1.yaml` — добавлен: `mode: {enum: [qa, dev, docs, rca]}`

**DEV mode:**
- [x] `contracts/skills/dev.release_notes.yaml`
- [x] `contracts/skills/dev.impact_review.yaml`
- [x] `contracts/skills/dev.rca_analysis.yaml`
- [x] `contracts/agents/dev-agent.yaml`
- [x] `orchestrator/taxonomy.yaml` — +4 DEV правила (r04–r07, ru+en)
- [x] `infra/tool_permissions/allowlist.yaml` — +`dev_agent` role с `vcs.diff`

**Repository Index (реальные пути из локальных репо):**
- [x] `memory/repositories/index/etna-trader.yaml` — 7 подсистем, 5 hotspots, db/docs/tests
- [x] `memory/repositories/index/ams.yaml` — 8 подсистем, 5 hotspots, 10 брокерных интеграций
- [x] `memory/repositories/index/serverless-integrations.yaml` — 6 подсистем, 4 hotspots, 12 Lambda
- [x] `memory/repositories/index/qa-automation.yaml` — 6 подсистем, 4 hotspots, Python+C# стек

**Service Map (расширен):**
- [x] Добавлены: `cross_repo`, `docs_path`, `hotspot_refs` для всех сервисов
- [x] Новые сервисы: `ams-api`, `ams-router`, `ams-kyc`
- [x] Новые Lambda: `lambda-sftp-to-s3`, `lambda-kyc-flags`, `lambda-serenity-sync`, `lambda-report-any`
- [x] Итого в service_map: 13 сервисов

---

### Phase 2 — Routing MVP (P0)

- [ ] `aiqa/orchestrator/classifier.py` — deterministic rules + heuristic fallback
- [ ] `aiqa/orchestrator/bundle_builder.py` — минимальный bundle из carrier + index
- [ ] `aiqa/orchestrator/context_loader.py` — загрузка people/repos/services
- [ ] `aiqa/orchestrator/router.py` — основной entrypoint
- [ ] `aiqa/orchestrator/trace_logger.py`
- [ ] `scripts/create_carrier.py` — CLI: создать Task Carrier + link to ADO
- [ ] `scripts/run_pipeline.py` — CLI: запустить orchestrator для task ID
- [ ] QA pipeline `qa_plan.py` — минимальный runnable: carrier → test-plan.md

**Параллельные задачи (разблокируют Phase 2):**
- [ ] Разобрать автотесты Алексея — какой фреймворк, как запускать, что покрывают, как встроить в pipeline
- [ ] Добавить профили для остальных членов команды (Lead, BA если есть)
- [ ] Решить GAP-3: cross-repo routing алгоритм

### Phase 3 — Eval MVP (P0)

- [ ] `aiqa/evals/checks/schema_check.py`
- [ ] `aiqa/evals/checks/ac_coverage_check.py`
- [ ] `aiqa/evals/checks/trace_check.py`
- [ ] `aiqa/evals/reports/report_writer.py` → `eval-report.md`

### Phase 4 — Expand (P1)

- [ ] Dev pipeline (`dev_release_notes.py`)
- [ ] Docs pipeline (`docs_update.py`)
- [ ] RCA pipeline (`rca_analysis.py`)
- [ ] `aiqa/memory/services/service_map.yaml`
- [ ] `aiqa/memory/repositories/index/qa-automation.yaml`
- [ ] ADO sync policy — update work item при изменении stage carrier

### Phase 5 — Multi-repo adapters (P1)

- [ ] `scripts/generate_adapters.py` — contracts → `.cursor/.claude` для каждого репо
- [ ] Запустить для `ETNA_TRADER` — заменить ручную поддержку на generated
- [ ] Запустить для `qa-automation`
- [ ] Задокументировать процесс onboarding нового репо (5 шагов)

### Phase 6 — IDE Integration (P2)

- [ ] `.vscode/tasks.json` в ETNA_TRADER — команды create/enrich carrier
- [ ] VSCode extension (QuickPick UI) — опционально, после MVP

---

## Текущие GAPs (нужно решение перед реализацией)

| ID | Gap | Блокирует |
|----|-----|-----------|
| ~~GAP-1~~ | ~~Где живёт `aiqa/` core~~  → **ЗАКРЫТ**: `C:/Reps/ai-tools/` | ~~Phase 1~~ |
| GAP-3 | **Cross-repo task routing**: routing должен быть by_work_item → by_person_context → by_service_map → repo (repo = secondary). TaskBundle собирает relevant_paths из нескольких реп под один work item | Phase 2, P0 |
| GAP-4 | PersonState update mechanism — кто обновляет и когда | Phase 2 |
| GAP-7 | ADO sync — какие поля синкаются, в каком направлении | Phase 4 |

---

## Ключевые решения (зафиксированы)

| Решение | Обоснование |
|---------|-------------|
| Task-centric, не repo-centric | Задачи всегда затрагивают несколько репо |
| Contracts → generated adapters | Устраняет split-brain .cursor/.claude |
| Deterministic-first routing | Auditable, обсуждаемо с командой |
| Task Carrier в repo (YAML) + link в ADO | Версионирование + привычный трекер |
| Tools read-only by default | Безопасность, явный allowlist на write |
| mobileLiteApp = external/diagnostics only | Чужой код, нет ownership; использовать только чтобы доказать что проблема на чужой стороне |
| ai-tools = основной рабочий слой (не legacy) | qa-agent и весь слой активно используется; legacy только mobileLiteApp |
| AI-framework-4-myMommy = experimental/R&D | Источник фич и паттернов для адаптации в QA/Dev/Docs pipelines; не dependency |
| Routing: by_work_item first | Задача стягивает людей, сервисы, репо — не наоборот |

---

## Связанные документы

- [AI_QA_Framework_V1_Architecture.md](./AI_QA_Framework_V1_Architecture.md) — основной архитектурный документ
- [deep-research-report.md](./deep-research-report.md) — PBI с детальным дизайном и YAML схемами
- [IDE_Task_Carrier_Pipeline_V1.md](./IDE_Task_Carrier_Pipeline_V1.md) — Task Carrier lifecycle и IDE flow
