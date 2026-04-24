Use when:

developer wants to prepare a clean QA handoff
acceptance criteria are weak or implicit
changed surface needs to be described
unit-test priorities are not yet clear
QA mode
<actor>
qa
</actor>

Task:
[insert PBI / PR / diff / context]

Use when:

QA receives a task with incomplete handoff
regression scope is unclear
test cases must be built quickly
automation priorities must be chosen
Reviewer mode
<actor>
reviewer
</actor>

Task:
[insert PBI / PR / diff / context]

Use when:

lead/reviewer wants a readiness summary
risk and confidence need to be clarified
it must be clear what is proven vs assumed
What the Prompt Produces

The prompt should return:

Executive Summary
Task Summary
Changed Surface
Draft Acceptance Criteria
Impact and Regression
Open Questions
QA Plan
Test Cases
Unit-Test Hints
Automation Now vs Later
Actor-Specific Guidance
Handoff Readiness
Missing Context / Targeted Indexing Requests

The structure stays the same across actors.
Only the emphasis changes.

Unit-Test Hints — Meaning

This block exists primarily for developer mode.

Purpose:

identify what should be covered by developer-owned unit tests first
reduce unnecessary back-and-forth with QA
push cheap/fast checks left when possible

Rule of thumb:

if behavior can be isolated and verified cheaply in code, suggest it as a unit-test candidate
QA should not be the first line of defense for logic that can be cheaply guarded by unit tests
Automation Now vs Later — Meaning

This block exists primarily for QA mode.

Purpose:

separate what is worth automating immediately from what should be postponed
avoid over-automating too early
give QA a practical automation triage

Typical interpretation:

automate now if:
the flow is stable enough
high-value regression risk exists
manual repetition cost is high
setup is realistic now
postpone if:
behavior is still unstable or ambiguous
environment dependency is too heavy
cost of automation is higher than immediate value
scope is likely to change again soon
Mandatory Targeted Indexing Request — Meaning

This is important.

If impact cannot be assessed safely from current inputs, the prompt must issue a mandatory targeted indexing request.

This means:

do not pretend confidence you do not have
do not ask to index the whole workspace
ask only for the smallest extra slice needed for safe impact reasoning

Good cases for targeted indexing:

public contract / API changed
another repo may consume the changed surface
legacy behavior may depend on nearby handlers/services/tests
local diff is insufficient to reason about downstream impact

Good request examples:

“Review consumer tests in repo X before finalizing regression scope.”
“Fetch related handler/tests for this integration path.”
“Inspect only the consumer paths affected by this contract change.”
When to Use This Prompt

Use it when:

task handoff is incomplete
QA has to reconstruct too much manually
changed surface is not clearly documented
regression reasoning is missing
unit-test priorities were not stated
automation priorities are unclear
impact may cross repo boundaries

Do not rely on it as a replacement for:

actual code review
actual testing
actual runtime proof
merge gates
CI/CD enforcement

It structures reasoning and outputs.
It does not replace missing facts.

Recommended Team Usage
Developer

Run before handing the task to QA.

Goal:

improve task handoff quality
identify missing acceptance/impact details
identify unit-test priorities early
QA

Run when receiving the task.

Goal:

reduce intake chaos
structure regression and test planning faster
decide what to automate now vs later
Reviewer / Lead

Run when deciding whether the task is ready enough for review or discussion.

Goal:

see risk and readiness clearly
separate proof from assumptions
identify blockers early
Rule of Thumb

If the task is messy:

use the prompt.

If the task is cross-repo or legacy-sensitive:

use the prompt and allow targeted indexing requests.

If the task is already fully documented:

use it as a consistency check, not as a crutch.