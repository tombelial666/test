# Framework Rule: OPEN Questions — Evidence-First Only

## RULE #1: OPEN Questions Must Be Backed by Code Evidence

**Severity**: CRITICAL

**Rule**: Никакие OPEN questions не могут быть добавлены без:
1. ✓ **Direct code inspection** (git diff, grep, read_file)
2. ✓ **Explicit context verification** (где логика определяется? какие конвертеры/конфиги?)
3. ✓ **Negative check** (можно ли это объяснить существующей архитектурой?)

**Bad Example** (❌ Как я сделал):
```
User shows BO Settings:
  OMG_MG_Apex_DefaultFixRoute = MNGD
  OMG_MG_Instinet_DefaultFixRoute = SMART

Me: "Несогласованность! OPEN-7: Why different values?"
```

**Why it's wrong**:
- Не проверил, читают ли они один и тот же конвертер
- Не посмотрел на контекст (Apex vs Instinet = разные venue)
- Добавил фиктивный OPEN question

**Good Example** (✓ Как нужно делать):
```
User shows BO Settings.
Me: 
  1. grep_search("OMG_MG_Apex_DefaultFixRoute") → OrderConverter.cs:394
  2. read_file → вижу: _settingManager.GetByKey("OMG_MG_Apex_DefaultFixRoute")
  3. grep_search("OMG_MG_Instinet_DefaultFixRoute") → ДРУГОЙ конвертер
  4. Вывод: Это разные конвертеры для разных venue. Нет OPEN.
```

---

## RULE #2: Verification Checklist for OPEN Questions

**Before writing OPEN question**, always:

- [ ] Search for the referenced setting/code in the actual codebase
- [ ] Trace which module/converter reads this setting
- [ ] Check if there are multiple readers (Apex, Instinet, Serenity — разные ветки)
- [ ] Read 10 lines of context around each reference
- [ ] If behavior is divergent, check if that's intentional (by design, not bug)
- [ ] Only if truly unexplained → mark as OPEN with evidence

**Evidence format for OPEN question**:
```
**OPEN-X**: [Specific contradiction]
- Evidence A: [Code path 1 shows X]
- Evidence B: [Code path 2 shows Y]
- Why it matters: [Impact if unresolved]
- Required action: Ask developer OR check design doc [reference]
```

---

## RULE #3: OPEN Questions Must Have High Signal-to-Noise Ratio

**Definition**: Каждый OPEN question должен быть **реальным аномалием**, не гадаением.

**Questions that should NOT be OPEN**:
- ❌ "I wonder if..." (без кода)
- ❌ "This looks suspicious" (без контраста с baseline)
- ❌ "Why different values?" (без проверки контекста)
- ❌ "Is this a bug?" (без доказательства)

**Questions that SHOULD be OPEN**:
- ✓ "Code path A returns MNGDP, but test data expects MNGD for same input" (explicit contradiction)
- ✓ "PR says Tag 204 = 8 for ALL options, but code only applies to single-leg" (explicit divergence)
- ✓ "ExtendedHours = ALL has no test case; behavior undefined" (provable gap)

---

## RULE #4: Code Review Before Writing OPEN

**Mandatory steps**:

1. **Local Search**: grep_search in actual files
2. **Context Read**: read_file 20-50 lines around match (not just line number)
3. **Trace Caller**: who calls this? on what path?
4. **Check Variants**: is there a v1, v2 pattern? (Apex vs Instinet)
5. **Baseline Compare**: same behavior on `dev` branch or changed?

**Tool priority**:
```
FIRST: grep_search + read_file (evidence from actual code)
THEN: semantic_search (if code location unclear)
THEN: AI reasoning (only after facts gathered)

NEVER: Assume from interface alone (BO Settings screenshot ≠ code behavior)
```

---

## RULE #5: Meta-Review of OPEN Questions

**Before committing OPEN questions to docs, ask**:

- [ ] Did I search the codebase for this?
- [ ] Did I read ≥10 lines of context?
- [ ] Could this be explained by existing architecture (Apex vs Instinet, etc.)?
- [ ] Is this a real contradiction or a misunderstanding?
- [ ] Would a developer waste time on a fake question?

**If answer to any is "No/Maybe", DO NOT add OPEN.**

---

## Regression Test for This Rule

**Scenario**: New feature adds a setting or configuration.

**Anti-pattern** (❌):
```
Me: "Different values for two settings! OPEN question: Why?"
```

**Pattern** (✓):
```
Me: 
  1. Check which code READS each setting
  2. If OrderConverter reads A and MessageGateways read B → OK (different code paths)
  3. If both read same setting → check if intentional (feature toggle, A/B testing, etc.)
  4. Only if truly orphaned → OPEN
```

---

## How to Fix This Personally

Going forward:

1. **Every OPEN question** gets a comment in code search first
2. **Search output** is stored in evidence docs
3. **Negative proof** ("I searched X locations and found nothing") is acceptable OPEN
4. **Positive proof** ("Code shows X, doc says Y") is required for contradictions

---

## Contract for QA Framework

**If you see an OPEN question without:**
- explicit code evidence (grep, read, line numbers)
- negative checks (what was ruled out?)
- impact statement (why it matters)

**REJECT it.** This is the bar.

---

## Example: What Should Have Happened

**User shows**: BO Settings with Apex_DefaultFixRoute = MNGD, Instinet_DefaultFixRoute = SMART

**Me (correct flow)**:
```
1. grep_search("OMG_MG_Apex_DefaultFixRoute")
   → Found in OrderConverter.cs:394
   
2. read_file(OrderConverter.cs, 390-400)
   → var defaultRouteSetting = _settingManager.GetByKey("OMG_MG_Apex_DefaultFixRoute");
   
3. grep_search("OMG_MG_Instinet")
   → Found in DifferentConverter.cs (not Apex!)
   
4. Conclusion: Different converters, different settings. Intentional. No OPEN.
```

**Me (what I did)** ❌:
```
User shows screenshot → "Looks inconsistent!" → Add OPEN-7 → User corrects me
```

---

## Sign-off

**This rule is now part of the framework.** Any OPEN question without code evidence will be rejected.

**Severity**: Non-negotiable.
