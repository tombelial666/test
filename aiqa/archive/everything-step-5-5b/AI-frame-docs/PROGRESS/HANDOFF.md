# AI QA Framework — Session Handoff

> Прочитай этот файл и PROGRESS.md, затем продолжай с раздела "Следующий шаг".

---

## Контекст проекта

Строим **task-centric AI QA Framework** для команды ETNA Trader.

### Ключевые принципы
- **Work item = primary entity**, не репо
- **Task Carrier** — YAML файл `.aiqa/tasks/<ID>/task.yaml` в domain-репо, обогащается по цепочке Lead → Dev → QA → RCA
- **Task Bundle** — ephemeral runtime контекст, собирается оркестратором перед каждым запуском
- **Contracts as source of truth** — `aiqa/contracts/` в core репо; `.claude/.cursor` — generated adapters
- **Deterministic-first routing** — taxonomy.yaml правила → LLM fallback при низкой уверенности
- **Read-only по умолчанию** — write только в `.aiqa/tasks/<id>/artifacts/`

### Роли репозиториев
| Repo | Роль | Путь |
|------|------|------|
| `ai-tools` | **core** — framework source of truth; основной рабочий слой, НЕ legacy | `C:/Reps/ai-tools/` |
| `ETNA_TRADER` | **domain** — основной торговый монолит | `d:/DevReps/ETNA_TRADER/` |
| `qa-automation` | **domain** — тесты | `d:/DevReps/qa-automation/` (не трогали) |
| `AI-framework-4-myMommy` | **experimental / R&D** — источник фич и паттернов для адаптации; не dependency, не production | (не трогали) |
| `mobileLiteApp` | **external / legacy** — чужой репо, не наша зона; ТОЛЬКО для диагностики когда нужно доказать что проблема на чужой стороне | readonly |

### Разграничение папок
- `.aiqa/` (с точкой) — runtime data **в domain репо** (task carriers, people states)
- `aiqa/` (без точки) — framework source **в core репо** `C:/Reps/ai-tools/`

---

## Что уже сделано (Phase 1 — COMPLETE)

### Core repo `C:/Reps/ai-tools/`
```
aiqa/
  contracts/
    schemas/
      task_carrier.v1.yaml      ✓
      task_bundle.v1.yaml       ✓
      person_profile.v1.yaml    ✓
      person_state.v1.yaml      ✓
      repository.v1.yaml        ✓
      service.v1.yaml           ✓
    skills/
      qa.generate_test_plan.yaml    ✓
      qa.generate_test_cases.yaml   ✓
      qa.coverage_review.yaml       ✓
    agents/
      qa-agent.yaml             ✓
  orchestrator/
    taxonomy.yaml               ✓  (4 deterministic rules + LLM fallback)
  memory/
    people/profiles/
      artem.yaml                ✓
      sergey.yaml               ✓
      _template.yaml            ✓
    repositories/index/
      etna-trader.yaml          ✓  (5 subsystems, paths, artifacts)
    services/
      service_map.yaml          ✓  (5 сервисов: trading-engine, oms, clearing, account-opening, api-gateway)
  infra/tool_permissions/
    allowlist.yaml              ✓  (role-based, default deny)
  evals/checks/                 (пустые .gitkeep)
  tools/                        (пустые .gitkeep)
adapters/claude/                (пустые .gitkeep)
adapters/cursor/                (пустые .gitkeep)
scripts/                        (пустые .gitkeep)
```

### Domain repo `d:/DevReps/ETNA_TRADER/`
```
.aiqa/
  README.md                     ✓
  .gitignore                    ✓
  tasks/_template/
    task.yaml                   ✓  (полный шаблон carrier со всеми полями)
    context.md                  ✓
    artifacts/.gitkeep          ✓
  people/active/
    artem.active.yaml           ✓
    sergey.active.yaml          ✓
```

---

## Следующий шаг — Phase 2: Routing MVP

Создать Python-скелеты в `C:/Reps/ai-tools/`:

```
aiqa/orchestrator/
  classifier.py          ← deterministic rules из taxonomy.yaml → skill_id
  bundle_builder.py      ← carrier + repo_index + people → TaskBundle
  context_loader.py      ← загружает people profiles/state, repo index, service map
  router.py              ← main entrypoint: принимает carrier path + person_id → запускает pipeline
  trace_logger.py        ← пишет trace в task.yaml (updated_by, last_run_at, last_pipeline)

scripts/
  create_carrier.py      ← CLI: python create_carrier.py --id EXT-12345 --repo etna-trader
  run_pipeline.py        ← CLI: python run_pipeline.py --task EXT-12345 --person artem
```

После этого — первый runnable QA pipeline:
```
aiqa/orchestrator/workflows/
  qa_plan.py             ← carrier → test_plan.md (минимальный end-to-end)
```

**Затем Phase 3 — Eval MVP:**
```
aiqa/evals/checks/
  schema_check.py
  ac_coverage_check.py
  trace_check.py
aiqa/evals/reports/
  report_writer.py       → eval-report.md
```

---

## Открытые GAPs (решить до Phase 2)

| ID | Gap | Статус |
|----|-----|--------|
| GAP-3 | Home repo selection алгоритм для cross-repo задач | Открыт |
| GAP-4 | PersonState update mechanism — кто обновляет и когда | Открыт |
| GAP-7 | ADO sync — какие поля синкаются, в каком направлении | Phase 4 |

---

## Ключевые файлы для чтения перед продолжением

1. `d:\DevReps\tasks\строим FrameWork\PROGRESS.md` — полный трекер
2. `C:\Reps\ai-tools\aiqa\contracts\schemas\task_carrier.v1.yaml` — главная схема
3. `C:\Reps\ai-tools\aiqa\orchestrator\taxonomy.yaml` — routing logic
4. `C:\Reps\ai-tools\aiqa\contracts\agents\qa-agent.yaml` — agent definition
5. `C:\Reps\ai-tools\aiqa\infra\tool_permissions\allowlist.yaml` — permissions

---

## Команда

- **Artem** — QA Engineer (artem.yaml в profiles)
- **Sergey** — Backend Dev (sergey.yaml в profiles)
- Язык общения в сессиях: **русский**
