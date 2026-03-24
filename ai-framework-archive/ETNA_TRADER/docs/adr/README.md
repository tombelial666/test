# Architecture Decision Records (ADR)

This directory contains Architecture Decision Records for ETNA_TRADER.

## What is an ADR?

An ADR documents a significant technical decision: its context, the options considered, and the outcome. ADRs are immutable records — if a decision changes, write a new ADR that supersedes the old one.

## When to Create an ADR

- Technology or library choices (ORM, caching, messaging)
- Architectural pattern decisions (service boundaries, async strategy)
- API design decisions with long-term impact
- DB schema decisions (data model trade-offs)
- Security architecture choices
- Third-party integration patterns

## When NOT to Create an ADR

- Routine bug fixes
- Minor refactors without architectural impact
- Config changes

## How to Create an ADR

1. Copy `TEMPLATE.md` → `NNNN-short-title.md` (increment number from last ADR)
2. Fill in all sections
3. Add an entry to the index table below
4. Commit with the related feature/fix

## Index

| # | Title | Status | Date |
|---|-------|--------|------|
| — | *(No ADRs yet — create the first one)* | — | — |

## Status Values

- **Proposed** — under discussion
- **Accepted** — decision made and implemented
- **Deprecated** — no longer in use
- **Superseded by [NNNN]** — replaced by a newer ADR
