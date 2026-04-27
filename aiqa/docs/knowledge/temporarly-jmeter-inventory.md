# Inventory notes — `D:\Reps\temporarly\Jmeter` and `D:\Reps\temporarly\Tradier scripts`

## What was found

- Both directories contain a **large collection** of JMeter plans (`.jmx`), including many backups.
- There are authored scenarios for orders, users creation, extended “Tradier” flows, and throughput/stress variants.
- There are historical result reports under `D:\Reps\temporarly\Tradier scripts\results\` (e.g. traceorders OFF vs ON comparisons).

## Security note (critical)

Many `.jmx` plans in these directories contain inline sensitive fields such as:

- `dbPass`
- `adminPass`
- `appKey`
- `Authorization` headers

Treat these as **secrets**. Do not commit them into versioned repo content. Prefer:

- `-J...` runtime properties, or
- local `.properties` files excluded from git.

## Conventions observed

- Some plans have multiple thread groups named like `50%flow`, `25%flow`, `rest%flow`.
  - This appears to be an authoring convention for “traffic mix by group”, not literal CPU percent.
- Many scenarios use `__P(...)` to accept runtime overrides (good), but also ship defaults (sometimes with secrets — bad).

## What to keep in the framework

Promote only **safe, reusable** pieces:

- Canonical “load smoke playbook”: `aiqa/docs/knowledge/load-smoke-playbook.md`
- Evidence template: `aiqa/templates/load-smoke-evidence-template.md`
- Canonical skill spec (no secrets): `aiqa/skills-catalog/load-smoke-jmeter-sqlserver.yaml`

Keep the big temporarly trees as **local reference**; index them by high-level notes only (this doc).

