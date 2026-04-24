# PBI 228128 — Manual Approve из ActionRequired: обход повторной Trulioo verification

## Идентификатор и заголовок

- **PBI / задача:** 228128 — ручное одобрение заявки из статуса **ActionRequired** не должно повторно запускать **AccountRequestVerify** (Trulioo), если первичная верификация уже привела к ActionRequired.
- **Репозиторий:** `AMS` (Account Management).
- **Связанный PR (Azure DevOps):** PR **15452** (сверять содержимое с веткой ниже).
- **Ветка:** `feature/228128-bypass-AccountRequestVerify-on-manual-approve`.

## Дистиллированные бизнес-правила (из задачи + кода)

**Из формулировки задачи:**

- Оператор выполняет **Manual Approve**, пока заявка в **ActionRequired** (часто после неуспешной или блокирующей Trulioo verification).
- **Ожидание:** на этом шаге **не** требуется повторный проход через Trulioo; доверие к решению оператора.

**Подтверждение в изменённом коде (`ModifyAccountRequestHandler`):**

- До `switch (command.Action)` вычисляется флаг:  
  `isApproveAfterActionRequired = (Action == Approve && Status == ActionRequired)` (статус — **до** перехода).
- Блок вызова `IsVerificationNeeded` / `AccountRequestVerify` выполняется только если  
  `Status == Approved && !isApproveAfterActionRequired`.  
  После `request.Approve(...)` статус становится `Approved`; если исходный переход был «из ActionRequired», флаг остаётся `true` → верификация **пропускается**.
- Для обычного первого **Approve** из `Submitted` (и т.п.) флаг `false` → поведение как **до** PR: при необходимости вызывается Trulioo.

## Допущения

- Основной сценарий — **Open**-заявка с обязательной верификацией по настройкам адаптера; `IsVerificationNeeded` по-прежнему опирается на `Trafix`/Trulioo-конфигурацию вне этого diff.
- Другие команды/обработчики одобрения (если появятся) могут не наследовать это поведение — проверять при расширении API.

## Источник evidence

| Что | Где |
|-----|-----|
| Полный патч | `git diff origin/dev...origin/feature/228128-bypass-AccountRequestVerify-on-manual-approve` в репозитории **AMS** (ожидаемо **один** файл). |
| Фокусный файл | `src/Etna.AccountManagement.Application/Accounts/Commands/ModifyAccountRequest.cs` — `ModifyAccountRequestHandler.Handle`. |
| База сравнения | `origin/dev` (локальный remote после `git fetch`). |
