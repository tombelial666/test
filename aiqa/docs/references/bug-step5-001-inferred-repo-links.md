# BUG-STEP5-001 — Inferred repo links (`repo-index.yaml`)

**Step:** 5.1 hard validation (canonical hardening).  
**Scope:** `aiqa/repo-index.yaml` and supporting Step 5 notes only.

---

## 1. Summary

Проверены все записи `linked_repos` в `aiqa/repo-index.yaml`. Единственные рёбра — **ETNA_TRADER ↔ qa** (ид репозитория `qa` — отдельный корень `qa/`, не `ETNA_TRADER/qa/`). Они опираются на **инвентарь и именование** в `detailed-repositories-index.md`, а не на проверенный граф проектных ссылок или контрактов. В YAML добавлены поля **`confidence`**, **`evidence_basis`**, **`review_only`**, уточнены текстовые `evidence`, чтобы не смешивать доказательства внутрирепозиторного `ETNA_TRADER/qa/` с утверждением о связи с автономным репо `qa`. В `step-5-assumptions.md` зафиксированы смысл полей и консервативная трактовка.

---

## 2. Current inferred links reviewed

| Repo (from) | `linked_repos` target | `relationship` |
|-------------|------------------------|----------------|
| ETNA_TRADER | qa | `test_and_automation_consumer` |
| qa | ETNA_TRADER | `tests_etna_trader_surface` |
| ServerlessIntegrations | — | пустой список |

Симметричная пара **ETNA_TRADER ↔ qa** — единственная зона неопределённости: это **межрепозиторная** семантика, а не факт «в ETNA есть папка qa».

---

## 3. Evidence strength per link

### ETNA_TRADER → qa

- **Сильное (внутри ETNA, не ребро к id `qa`):** в индексе описан каталог `ETNA_TRADER/qa/` как тестовые проекты внутри платформы — это **другой корень**, не автономный репозиторий `qa`.
- **Частично выведенное (ребро к id `qa`):** автономный `qa/` описан отдельной секцией; наличие проектов с префиксами `Etna.QA.*`, `Etna.Trader.*` и т.п. **предполагает** потребление/тестирование поверхностей Etna, но индекс **не** приводит полный список ссылок на `ETNA_TRADER/src` или решений сборки.
- **Слишком слабое для «высокой уверенности»:** прежняя формулировка evidence, где первая строка ссылалась на `ETNA_TRADER/qa/`, **усиливала впечатление** доказанной связи с отдельным репо — исправлено.

### qa → ETNA_TRADER

- **Частично выведенное:** те же основания — имена проектов (`Etna.Trader.WebService`, `Etna.QA.*`) и структура индекса; логично читать как «тестирует поверхности Etna Trader», без перечисления конкретных контрактов в YAML-входах.
- **Сильнее не помечено:** прямого цитирования solution/project reference paths к `ETNA_TRADER` в канонических входах Step 5 нет.

### ServerlessIntegrations

- Рёбер нет; менять не требуется.

---

## 4. YAML changes made

Файл: `aiqa/repo-index.yaml`.

- Для обоих элементов `linked_repos` (ETNA_TRADER→qa и qa→ETNA_TRADER) добавлено:
  - `confidence: medium`
  - `evidence_basis: [workspace_index_naming]`
  - `review_only: true`
- Переписаны списки `evidence`: убрана ложная опора на `ETNA_TRADER/qa/` как доказательство связи с **отдельным** репо `qa`; явно сказано, что связь межрепозиторная выводится из именования и инвентаря индекса, без проверенного графа в тех же входах.

Дополнительно: `aiqa/docs/references/step-5-assumptions.md` — подраздел про поля неопределённости и уточнение абзаца про ETNA_TRADER ↔ qa.

---

## 5. Why the new encoding is safer

- **Разделение силы доказательства:** потребитель YAML видит `confidence: medium` и `review_only: true` и не трактует ребро как SSOT уровня CI-графа.
- **Машиночитаемые теги:** `evidence_basis` позволяет будущим скриптам валидции отличать, например, `workspace_index_naming` от гипотетических будущих `declared_in_solution` без ломки структуры.
- **Честные текстовые evidence:** не смешиваются два разных факта (внутрирепозиторный `ETNA_TRADER/qa/` и отдельный корень `qa/`), что снижает риск ложной уверенности у ревьюера.

---

## 6. Go / No-Go for closing BUG-STEP5-001

**Go** — при соблюдении критериев приёмки:

- Выведенные `linked_repos` помечены полями неопределённости (`confidence`, `evidence_basis`, `review_only`).
- Из YAML отличимы отсутствие рёбер (ServerlessIntegrations) от **осознанно средней** уверенности по ETNA_TRADER ↔ qa.
- Текст evidence и `step-5-assumptions.md` согласованы: не утверждается большая уверенность, чем дают входы.

Если позже появятся проверенные артефакты (например, явные project references в репо), можно поднять `confidence` до `high`, расширить `evidence_basis` и снять `review_only` отдельным изменением.
