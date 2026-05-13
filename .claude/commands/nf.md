---
name: nf
description: >-
  Conduct in-depth feature discovery interview to explore, challenge, and document a new trading feature.
  Use when asked to 'detail a feature', 'explore a new feature', 'feature discovery',
  'interview about feature', or 'spec out a feature'. NOT for quick brainstorming,
  NOT for implementation tasks (use /ct).
argument-hint: "[feature-name]"
user-invocable: true
---

# New Feature Discovery — ETNA_TRADER

## Objective

Conduct a comprehensive interview to fully understand and document a new trading feature using collaborative brainstorming, then create a formal specification. Trading features carry significant business and regulatory implications — challenge assumptions rigorously.

## Guidelines

- **Use `AskUserQuestion` tool for ALL clarifications** — provides interactive options for user to choose from
- **Never assume behavior**: if any behavior is unclear/ambiguous (order routing logic, risk rules, regulatory constraints, error states), you MUST ask
- Ask non-obvious, thought-provoking questions — especially about edge cases in financial workflows
- Actively challenge assumptions; do not be a yes-bot
- Offer alternatives, shortcuts, and "go deeper" paths
- Continue until the feature is fully understood
- Document everything in the specification file

## Workflow

### Platform Skill Gate (MANDATORY when feature touches UI/screens)

**Trigger:** If the feature will create or modify screens, components, grids, or styles in the ACAT frontend.

**MANDATORY steps (do BEFORE writing recommendations in the discovery/spec):**
- Read `.claude/rules/trading-component-patterns.md`
- Explicitly state in the discovery/spec that the rule was read and will be applied
- Extract relevant UI/component rules and record them under a "Skill Compliance" section

### Step 1: Codebase Exploration

Launch 1-3 parallel Explore agents based on feature complexity. Use Task tool in **single message**.

**Agents:**
1. Existing feature code and patterns in `frontend/ACAT/src/` and relevant backend API projects
2. Domain models, contracts, existing repositories: `src/Etna.Trading.Contracts/`, DAL projects (if 2+ agents)
3. Docs, existing tests, DB schema in `db/`, `qa/`, `docs/` (if 3 agents)

Synthesize findings, then proceed to design exploration.

### Step 2: External Research (Optional)

Default: skip for token efficiency.

Run only when:
- User explicitly asks for deeper/strict discovery
- Internal codebase context is insufficient
- Decision depends on external constraints (regulatory, exchange protocols, financial standards)

### Step 3: Design Exploration Phase

With gathered context:
- Ask questions to refine the idea (batch related questions)
- Propose 2-3 different approaches with trade-offs
- Present design incrementally for validation
- Consider ETNA_TRADER architecture constraints:
  - Which layer does this belong to? (Contracts → Services → DAL → API)
  - New service or extend existing? (`IOrderService`, `IPositionService`, etc.)
  - Backend-only, frontend-only, or full stack?
  - Database schema changes? New SSDT objects or alter existing tables?
  - EF or NHibernate for data access in this area?

### Step 4: Challenge & Deep-Dive

After design exploration, run one structured challenge pass:
- Identify assumptions and question each one
- Suggest 2-3 alternative approaches (including a lean/shortcut path)
- Flag potential risks, hidden costs, or complexity traps

**Technical Implementation:**
- Edge cases and failure scenarios specific to trading (partial fills, market closes, order expiry)
- Performance implications (high-frequency order flow, real-time position updates)
- Integration points with existing services (clearing, risk engine, market data feed)
- Security implications (account authorization, order tampering, privilege escalation)
- Concurrency and race conditions (double-click order placement, position race on close)

**Trading Domain Specifics:**
- Order lifecycle: New → Partially Filled → Filled / Cancelled / Rejected
- Position impact: long/short, cost-basis, unrealized P&L
- Account impact: buying power, margin, balance
- Market data dependencies: quotes, depth, halt status
- Regulatory / compliance considerations (e.g., pattern day trader rules, short-sale restrictions)

**Business & Product:**
- Success metrics and how to measure them
- MVP vs future scope boundaries (e.g., just Market orders first, Limit/Stop later)
- Multi-account / multi-user implications

### Step 5: Specification Writing

After design exploration and interview completion:

1. **Read template**: Read `docs/product-docs/templates/discovery-template.md` (if exists), otherwise use standard structure below
2. **Create task directory**: `tasks/task-<date>-[feature-name]/`
3. **Write specification** with at minimum these sections:
   - **Feature Summary**: one-paragraph description
   - **Business Context**: why this feature matters, who uses it
   - **Trading Domain Concepts**: orders/positions/accounts/market-data involved
   - **Acceptance Criteria**: numbered, testable
   - **Architecture Impact**: layers touched, new files/projects, DB changes
   - **Skill Compliance** (if UI): rules from `trading-component-patterns.md` that apply
   - **Open Questions**: unresolved items needing product/business decision
   - **Out of Scope**: explicit exclusions to prevent scope creep
   - **Risks**: technical and business risks
   - Output file: `discovery-[feature-name].md`
4. **Present summary** to user for confirmation

**If design exploration reveals the feature is not viable**: Document reasons in `discovery-[feature-name]-rejected.md` with rationale, and stop here.

## Output

`tasks/task-<date>-[feature-name]/discovery-[feature-name].md`
