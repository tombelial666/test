# Legacy hotspots — Task 228135 / RQD EasyToBorrow in Octopus

## Overview

Эта задача выглядит маленькой по diff size, но затрагивает два чувствительных слоя:

- `Oms.ClearingManager.Octopus.config` как runtime-конфиг SOD;
- `EasyToBorrowHandler.cs` как общий legacy handler для shortability updates.

Именно второй слой делает задачу регрессионно чувствительной.

## HS-1: Shared `EasyToBorrowHandler` behavior

**Location**: `Etna.Trading.Oms.Clearing/StartOfDay/Handlers/EasyToBorrowHandler.cs`

**Why hotspot**:

- класс уже используется как общий handler, а не только новым RQD/Volant потоком;
- изменение внесено в базовую ветку `Process`, а не только в отдельный provider;
- новый параметр меняет семантику массового сброса `AllowShort`.

**Risk**:

- потоки, которые полагались на implicit reset missing securities to false, не должны случайно поменяться;
- если параметр не передан, критично сохранить старое поведение.

**Mitigation already in PR**:

- `setOthersFalse` имеет дефолт `true`, что поддерживает обратную совместимость.

**QA focus**:

- проверить, что старые ETB-потоки с отсутствующим параметром работают как раньше;
- отдельно проверить новый Volant ETB поток с явным `setOthersFalse=true`.

## HS-2: AllowShort update semantics

**Location**: условие обновления в `Process`

Смысл изменения:

- раньше любое расхождение `security.AllowShort != allowShort` приводило к обновлению;
- теперь обновление делается только если `allowShort == true` или `_setOthersFalse == true`.

**Risk**:

- silent regression в сценариях, где файл является не полным snapshot, а delta/whitelist;
- silent regression в противоположную сторону, если ожидался жесткий full reset.

**QA focus**:

- явно разделять два режима: `setOthersFalse=true` и `setOthersFalse=false`;
- проверять не только positive-match securities, но и бумаги, отсутствующие в файле.

## HS-3: Overridden securities branch

**Location**: clearing-firm branch inside `EasyToBorrowHandler`

Почему hotspot:

- логика overridden securities уже условная и завязана на `clearingFirm`;
- новый Volant ETB конфиг всегда передает `CM.Volant.SOD_EOD_ClearingFirm`;
- ошибка здесь может не проявиться на обычных бумагах, но проявиться только на overridden subset.

**QA focus**:

- подтвердить, что clearing firm существует и корректно резолвится;
- при наличии стенда/данных проверить влияние на overridden securities отдельно от baseline securities.

## HS-4: Octopus SOD configuration

**Location**: `Oms.ClearingManager.Octopus.config`

Почему hotspot:

- конфиг runtime-driven и зависит от tenant variables;
- ошибка в имени файла, расписании, `HasHeaderRecord` или delimiter ломает job без компиляционной защиты.

**QA focus**:

- сверить все ключи с `228135-RQD-EasyToBorrow-Handler-in-Octopus.txt`;
- отдельно проверить `fileDelimeter=,`, `symbolColumnIndex=0`, `cusipColumnIndex=-1`, `HasHeaderRecord`;
- подтвердить, что путь хранения `Install.Root\\Clearing\\Volant` корректен для стенда.

## HS-5: Evidence drift between PR and local checkout

**Observed**:

- локальное содержимое `CorSodETBTest.json` в рабочем дереве может не содержать сценарий `setOthersFalse=false`, хотя branch diff его показывает.

**Why it matters**:

- нельзя делать вывод о полноте PR только по локальному файлу;
- task package должен ссылаться на branch diff как primary evidence.

**QA action**:

- для review и тест-плана использовать `origin/dev...origin/feature/228135-rqd-easy-to-borrow`;
- перед выполнением тестов убедиться, что checkout соответствует PR.
