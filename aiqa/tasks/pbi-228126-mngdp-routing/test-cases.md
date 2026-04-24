# Test cases — PBI 228126

## Detailed test cases

### TC-228126-01
- **Title:** MNGD default + PRE → 57=MNGDP, 336=P  
- **Priority:** P1  
- **Preconditions:** Apex `OrderConverter`, `Exchange` ведёт к базовому MNGD (как в JSON — null).  
- **Test data:** `ExtendedHours=PRE`, equity.  
- **Steps:** Сконвертировать New order; прочитать FIX 57, 336.  
- **Expected:** 57=`MNGDP`; 336=`P` (per Apex FIX spec; SetTradingSessionId maps PreMarket → P).  
- **Evidence:** дамп сообщения, лог OMS.

### TC-228126-02
- **Title:** MNGD default + POST → 57=MNGDP, 336=4  
- **Priority:** P1  
- **Preconditions:** как TC-01.  
- **Test data:** `ExtendedHours=POST`, equity.  
- **Steps:** Конвертация New.  
- **Expected:** 57=`MNGDP`; 336=`4`.  
- **Evidence:** дамп FIX.

### TC-228126-03
- **Title:** MNGD default + REG → без MNGDP, без 336  
- **Priority:** P1  
- **Test data:** `ExtendedHours=REG`.  
- **Expected:** 57=`MNGD`; 336 отсутствует.  
- **Evidence:** `MngdRegSessionNewOrder`.

### TC-228126-04
- **Title:** MNGD + single-leg option → 204=8, 5729=VR63  
- **Priority:** P1  
- **Expected:** 57=`MNGD`; 204=8; 5729=`VR63`.  
- **Evidence:** `MngdOptionNewOrder`, снимок 204/5729.

### TC-228126-05
- **Title:** Modify опциона на MNGD сохраняет 204/5729 и OrigClOrdID  
- **Priority:** P1  
- **Expected:** как `MngdOptionModifyOrder` (57, 204, 5729, 41).  
- **Evidence:** сообщение modify.

### TC-228126-06
- **Title:** Регрессия QUIK + option  
- **Priority:** P1  
- **Expected:** 57=`QUIK`; 204=0; 5729 отсутствует.  
- **Evidence:** `QuikOptionNewOrder`.

### TC-228126-07
- **Title:** MNGD + equity без 204/5729  
- **Priority:** P2  
- **Evidence:** `MngdNonOptionNewOrder`.

### TC-228126-08
- **Title:** RepCode Firm/Pro на MNGD + option → всё равно 204=8  
- **Priority:** P1  
- **Preconditions:** аккаунт с RepCode из firm/pro списков.  
- **Expected:** 204=8 (override).  
- **Evidence:** сравнение с прежним поведением на `dev`.

### TC-228126-09 (граница)
- **Title:** Явный `Exchange=MNGD` (whitelist) + PRE/POST  
- **Priority:** P2  
- **Expected:** базовый MNGD → **MNGDP**; подтвердить (в JSON чаще null Exchange).  
- **Evidence:** прогон с `Exchange="MNGD"`.

### TC-228126-10 (негатив)
- **Title:** Невалидная строка ExtendedHours  
- **Priority:** P3  
- **Expected:** исключение из `SetTradingSessionId` (поведение `dev`).  
- **Evidence:** стек/сообщение.
