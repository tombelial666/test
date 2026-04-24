# Task Handoff and Impact Prompt — Usage Guide

> Operational usage guide for `task-handoff-and-impact-prompt.md`.
> This file explains how to use the prompt in practice.
> It is a working instruction, not a canonical framework contract.

---

## Purpose

This prompt is used to turn incomplete task context into a structured handoff package for:

- task decomposition
- acceptance criteria drafting
- changed surface extraction
- impact and regression reasoning
- developer → QA handoff
- reviewer readiness assessment
- unit-test guidance
- QA automation prioritization
- targeted indexing requests when impact cannot be assessed safely

It is designed for **assisted workflow**, not full autonomy.

---

## Core Idea

The prompt has:
- **one shared decomposition flow**
- **one role switch**
- **one mandatory targeted indexing mechanism when impact context is insufficient**

The role switch does **not** create three separate workflows from zero.
It changes only the **priority of the output**.

---

## Actor Modes

Use the `<actor>` field to set the output focus.

### 1. `developer`

Use when the task is still being shaped on the development side.

**Focus:**
- implementation intent
- draft acceptance criteria
- changed surface
- developer-owned unit-test hints
- what must be documented before handoff to QA

**Expected output emphasis:**
- what changed
- what behavior is intended
- what should be covered by unit tests first
- what is still missing in the PR / task handoff
- what QA will otherwise have to reconstruct manually

---

### 2. `qa`

Use when the task is entering testing.

**Focus:**
- regression scope
- risk areas
- test cases
- evidence gaps
- what to automate now vs later

**Expected output emphasis:**
- what needs manual checking first
- what old behavior may break
- what assumptions are still unclear
- what automation is worth doing immediately
- what should be postponed until later

---

### 3. `reviewer`

Use when the goal is decision support rather than deep implementation or full QA planning.

**Focus:**
- readiness
- confidence
- blockers
- gaps
- risk summary

**Expected output emphasis:**
- what is proven
- what is inferred
- what remains open
- whether the task is ready for review / merge discussion / handoff

---

## Minimal Input Package

The prompt works best when at least some of the following are available:

- task / PBI description
- PR or diff
- changed files
- relevant code snippets
- existing documentation
- environment/config notes
- known related repositories
- logs/runtime evidence only if explicitly relevant

Not all of this is required.

If information is missing, the prompt should:
1. produce the best grounded draft possible,
2. list missing context,
3. ask only minimal high-value questions,
4. request targeted indexing only if needed.

---

## Minimal Usage Examples

### Developer mode

```text
<actor>
developer
</actor>

Task:
[insert PBI / PR / diff / context]