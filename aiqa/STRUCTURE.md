# Framework Structure

## Why This Repository Is Structured This Way

The structure separates canonical framework truth from generated runtime adapters and from execution artifacts.  
This avoids ambiguity, keeps decisions deterministic, and allows adapters to evolve without changing canonical contracts.

## Layers

### Canonical Layer

Primary source of truth under `aiqa/`:

- `aiqa/MANIFEST.md`
- `aiqa/STRUCTURE.md`
- `aiqa/task-schema.yaml`
- `aiqa/docs/` (domain, policy, and reference docs)
- `aiqa/docs/knowledge/` (supporting operational and design knowledge migrated from transition buckets; **not** canonical policy unless promoted with evidence)
- `aiqa/templates/` (canonical templates and reusable prompt shells)
- `aiqa/archive/` (preserved historical bundles — **not** canonical definitions)

### Generated Runtime Adapter Layer

Generated integration layers such as `.cursor/` and `.claude/`:

- Not canonical
- Rebuildable from canonical inputs
- Allowed to change format as tooling evolves

### Task Artifact Layer

Task execution outputs (for example task folders, test runs, intermediate artifacts):

- Context-specific and time-bound
- Useful for execution and audit
- Not canonical framework definitions
- When a task has sufficient evidence/context, the task folder should contain a complete task package rather than a single summary artifact
- New useful artifacts discovered during task analysis should be indexed at the task level first (for example via `README.md`, evidence notes, dependency mapping, and linked task docs)
- Promotion from task-level indexing into canonical artifacts such as `repo-index.yaml` or `impact-map.yaml` requires explicit scope and reusable evidence; task discovery alone is not enough

### Temporary / Experimental / Reference Layer

Experimental directories, archived material, and external/reference repositories:

- Can inform design and diagnostics
- Must not be treated as production dependencies for canonical architecture

## Boundary Rules

- Canonical truth is authored and maintained in `aiqa/`.
- Generated adapters mirror or consume canonical truth, but do not define it.
- Runtime orchestration details are intentionally deferred to later implementation steps.
