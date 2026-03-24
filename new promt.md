<deliverables>
Create documentation files in markdown format:

1. docs/00_repository_overview.md
2. docs/01_architecture_explained_simple.md
3. docs/02_how_to_work_with_tasks.md
4. docs/03_cross_repo_analysis.md
5. docs/04_regression_and_legacy_impact.md
6. docs/05_glossary_simple.md

Also create:
7. docs/README.md — index of all generated documentation
</deliverables>

<cross_repo_focus>
Pay special attention to cross-repository analysis.

Example scenario:
A task affects both AMS and serverlessIntegration.

Explain:
- where the business flow starts
- where data leaves one repository
- where it enters another
- which contract binds them
- where compatibility can break
- what regression should be checked in both repositories
- how to determine the root cause repository
- how to trace the same business flow across multiple repositories
</cross_repo_focus>

<style_override>
Write in a warm, patient, teaching tone.
Do not sound arrogant or overly technical.
Explain as if teaching a confused but motivated person.
</style_override>