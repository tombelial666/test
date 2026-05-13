---
name: skill-creator
description: Guide for creating effective skills in ETNA_TRADER. This skill should be used when users want to create a new skill (or update an existing skill) that extends Claude's capabilities with specialized knowledge, workflows, or tool integrations specific to the trading system.
license: Complete terms in LICENSE.txt
user-invocable: true
---

# Skill Creator — ETNA_TRADER

This skill provides guidance for creating effective skills tailored to the ETNA_TRADER trading system.

## About Skills

Skills are modular, self-contained packages that extend Claude's capabilities by providing specialized knowledge, workflows, and tools. Think of them as "onboarding guides" for specific domains or tasks — they transform Claude from a general-purpose agent into a specialized agent equipped with procedural knowledge that no model can fully possess.

### What Skills Provide

1. Specialized workflows — Multi-step procedures for specific domains (e.g., order placement flow, DB migration review)
2. Tool integrations — Instructions for working with specific file formats, APIs, or CI pipelines
3. Domain expertise — ETNA_TRADER-specific knowledge: trading domain concepts, C# conventions, SSDT patterns
4. Bundled resources — Scripts, references, and assets for complex and repetitive tasks

### ETNA_TRADER Skill Anatomy

Every skill consists of a required `skill.md` file and optional bundled resources:

```
.claude/skills/<skill-name>/
├── skill.md           (required)
│   ├── YAML frontmatter metadata (required)
│   │   ├── name: (required)
│   │   └── description: (required)
│   └── Markdown instructions (required)
└── Bundled Resources (optional)
    ├── scripts/       - Executable code (PowerShell/Python/Bash)
    ├── references/    - Documentation loaded into context as needed
    └── assets/        - Templates, schema files, boilerplate
```

### YAML Frontmatter Fields

```yaml
---
name: <kebab-case>
description: >-
  One or two sentences. Third-person. When this skill is used, what it does.
  Include trigger phrases users might say (e.g., "when asked to...").
argument-hint: [optional-arg]         # shown to user as hint
allowed-tools: [Read, Write, Edit, Grep, Glob, Bash, Task, AskUserQuestion]
disable-model-invocation: true        # optional: for doc-only/script-only skills
---
```

## ETNA_TRADER Skill Locations

All skills live under:
```
d:/DevReps/ETNA_TRADER/.claude/skills/<skill-name>/skill.md
```

After creating a skill, update the skills index:
```
d:/DevReps/ETNA_TRADER/.claude/skills/README.md
```

## Skill Creation Process

### Step 1: Understand the Skill with Concrete Examples

Before writing anything, gather concrete usage scenarios. Ask:
- "What would a developer say to trigger this skill?"
- "What problem does this solve that Claude doesn't do well without it?"
- "Are there ETNA_TRADER-specific patterns (C#, NUnit, SSDT, Unity DI) this skill needs to know?"

Example trigger phrases for ETNA_TRADER skills:
- "Review my DB migration" → could trigger a `db-review` skill
- "Generate release notes for sprint 42" → triggers `ai-settings` skill in RELEASE_NOTES mode
- "Check this C# for trading conventions" → triggers `ai-settings` skill in REPO_STYLE_ALIGNMENT mode

### Step 2: Plan Reusable Contents

Analyze each example to identify what reusable resources would help:

| Resource type | When to include | ETNA_TRADER examples |
|--------------|-----------------|----------------------|
| `scripts/` | Repeated code generation / automation | PowerShell to scaffold a new .NET service project |
| `references/` | Domain knowledge Claude lacks | `references/trading-domain.md` (order lifecycle, position math) |
| `assets/` | Templates used in output | `assets/controller-template.cs`, `assets/builder-template.cs` |

### Step 3: Create the Skill File

Create `d:/DevReps/ETNA_TRADER/.claude/skills/<skill-name>/skill.md`.

ETNA_TRADER skill naming conventions:
- Core workflow skills: `nf`, `ct`, `si`, `sr`, `udoc`
- Domain-specific: use descriptive kebab-case names (`db-review`, `order-flow-tracer`)
- AI automation: `ai-settings`

### Step 4: Write the Skill

Writing style:
- **Imperative/infinitive form** — verb-first instructions, not second person
- `To accomplish X, do Y` rather than `You should do X`
- Objective, instructional language optimized for AI consumption

**ETNA_TRADER-specific content to include:**
- Reference the relevant `.claude/rules/` files when the skill involves code generation
- Specify which layer (Contracts / Services / DAL / API / Frontend / DB) the skill affects
- Include test commands (`dotnet test`, `npx vitest run`) appropriate to the affected layer
- Mention async/await and `CancellationToken` requirements for .NET code
- Mention `ConfigureAwait(false)` requirement for library code

**Skill body must answer:**
1. What is the purpose? (2-3 sentences)
2. When should it be used? (trigger conditions, NOT conditions)
3. How should Claude use it? (step-by-step workflow, gates, agents to invoke)

### Step 5: Register in README

After creating the skill, add an entry to `d:/DevReps/ETNA_TRADER/.claude/skills/README.md`:

```markdown
| `/skill-name` | One-line description |
```

Place it in the appropriate section (Core Workflow, Supporting, or Domain-Specific).

### Step 6: Iterate

After first use:
1. Note where Claude struggled or produced incorrect output
2. Identify missing context (domain knowledge, path conventions, code examples)
3. Update `skill.md` or add a `references/` file
4. Test again on a real task

## Progressive Disclosure Design Principle

Skills use a three-level loading system to manage context efficiently:

1. **Metadata** (name + description) — Always in context (~100 words); determines when skill triggers
2. **skill.md body** — Loaded when skill triggers (<5k words target)
3. **Bundled resources** — Loaded only as needed by Claude (unlimited)

Keep `skill.md` focused on workflow. Move detailed domain knowledge, schemas, and code examples to `references/` files.

## Anti-Patterns to Avoid

- Do NOT duplicate information from `.claude/rules/` files in `skill.md` — reference them instead
- Do NOT hardcode absolute file paths that may change — use relative paths from repo root
- Do NOT write skills that overlap significantly with existing skills without clear differentiation
- Do NOT omit the `name` and `description` frontmatter fields — they are required for skill discovery
