---
name: clearing-system-actions
description: Works with ETNA clearing system actions and ClearingTester automation. Use when the user mentions systemactions/clearing, Volant EasyToBorrow, clearing handlers, INT2 clearing checks, or qa/Tools/ClearingTester.
---

# Clearing System Actions

## When to use

- Нужно вызвать `GET` or `PUT /v1.0/systemactions/clearing`.
- Пользователь тестирует `Volant EasyToBorrow`, ETB handlers, or other clearing system actions.
- Нужно запустить или расширить `qa/Tools/ClearingTester`.

## Default workflow

1. Для токена использовать обычный `POST /api/token` с `username`, `password`, `Et-App-Key`.
2. Один полученный токен использовать для всего прогона.
3. Для runnable automation использовать `D:/DevReps/qa/Tools/ClearingTester`.
4. Разбивать сценарии на атомарные tests: discovery, disabled flag, provider shape, handler shape, payload checks, execute.
5. Не коммитить реальные payload secrets; использовать local payload copies or env vars.

## Auth note

Базовый токен-поток для INT2:

- `POST https://pub-api-etna-demo-ci-int-2.etnasoft.us/api/token`
- заголовки: `username`, `password`, `Et-App-Key`

Полученный токен затем передавать в `Authorization`, по умолчанию как `Bearer <token>`.

Для `systemactions/clearing` на INT2 использовать:

- `https://priv-api-etna-demo-ci-int-2.etnasoft.us/api/v1.0/systemactions/clearing`

## Current project paths

- `D:/DevReps/qa/Tools/ClearingTester/systemactions/`
- `D:/DevReps/qa/Tools/ClearingTester/tests/test_volant_easy_to_borrow_int2.py`
- `D:/DevReps/qa/Tools/ClearingTester/payloads/volant_easy_to_borrow_int2.template.json`

## Additional resources

- Примеры и команды: [examples.md](examples.md)
