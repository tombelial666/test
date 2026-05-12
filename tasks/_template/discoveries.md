# Discoveries — [название задачи]

> Заполняется командой `/learn` в конце сессии.
> Не удаляй даже если нашёл мало — пустой файл тоже сигнал.

**Дата сессии:** YYYY-MM-DD
**Задача:** [task.id]
**Домен:** [область: oms / trading / auth / leaderboard / clearing / ...]

---

## Находки

<!-- /learn заполняет этот раздел автоматически -->
<!-- Ручной формат если заполняешь сам: -->

<!--
### [Короткое название находки]

**Тип:** hotspot | impact_rule | domain_pattern | test_gap | open_question | config_risk
**Статус:** draft | ready | promoted

**Что нашли:**
[2-4 конкретных предложения. Не "код плохой" — а "MarginCallService читает конфиг в конструкторе до инициализации DI"]

**Доказательство:**
- [конкретный файл:строка, лог, SQL, тест]

**Почему важно:**
[Что сломается если не учесть это в следующий раз]

**Следующий шаг:**
- [ ] [конкретное действие]
-->

---

## Кандидаты на промоцию в канон

> Только для типов `hotspot` и `impact_rule`.
> Скопируй YAML в нужный файл когда будешь готов.

<!-- /learn генерирует эти блоки автоматически -->

<!--
### → repo-index.yaml (hotspot)

```yaml
# Добавить под repos.[REPO_ID].hotspots:
hotspots:
  - path: [путь]
    label: [метка]
    risk_level: high
    reason: [одно предложение]
    discovered_in: tasks/[папка]/discoveries.md
```

### → impact-map.yaml (новое правило)

```yaml
# Добавить в rules:
- id: [kebab-case-id]
  review_mode: manual
  confidence: low
  evidence_basis:
    - task_discovery
  when:
    any_paths:
      - [путь или glob]
  expand:
    repos: [REPO_ID]
    domains: [домен]
  required_checks:
    - id: [check-id]
      type: impact_review
      mode: manual
      blocking: false
      description: [что проверить]
```
-->
