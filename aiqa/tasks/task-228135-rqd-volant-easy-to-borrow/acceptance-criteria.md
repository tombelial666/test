# Acceptance criteria — Task 228135 / Volant EasyToBorrow

## Product acceptance criteria

- **AC-1. Provider wiring**
  `Volant EasyToBorrow` is present in clearing configuration and resolves the expected provider/handler chain for Volant ETB processing.

- **AC-2. Provider parameter contract**
  The action exposes the expected Volant provider parameters required for file retrieval and parsing, including source path, delimiter, symbol/cusip indexes, header mode, and storage path.

- **AC-3. Handler parameter contract**
  The action exposes the expected handler parameters for ETB processing, including `setOthersFalse` and `clearingFirm`.

- **AC-4. Execution path**
  The action can be invoked successfully on INT2 through `systemactions/clearing` using the supported token flow and returns the requested action name in the response.

- **AC-5. Shared-handler backward compatibility**
  The task evidence demonstrates that the shared `EasyToBorrowHandler` still preserves default behavior when `setOthersFalse` is not explicitly disabled.

- **AC-6. Opt-out semantics are represented**
  The task evidence demonstrates that `setOthersFalse=false` is an intended and covered scenario for “do not reset missing securities”.

- **AC-7. Canonical boundary preserved**
  The task is fully indexed at the task-package level without promoting unsupported conclusions into canonical `repo-index.yaml` or `impact-map.yaml`.

## Testing completion criteria

- **TCOMP-1. Automation discovery completed**
  INT2 discovery checks are green for action existence, disabled state, provider handler presence, ETB handler presence, and parameter key shape.

- **TCOMP-2. Mutation-enabled API execution completed**
  Full INT2 suite with `RUN_MUTATING_CLEARING_TESTS=1` finishes green and confirms successful `PUT /systemactions/clearing` execution path.

- **TCOMP-3. Evidence captured**
  The package contains recorded run evidence: target hosts, auth path, test result summary, and the distinction between what automation proved and what remains manual.

- **TCOMP-4. Manual gaps are explicit**
  Open follow-up checks for DB/result-state, real file parsing, overridden securities, and schedule/timezone are listed explicitly, not implied or hidden.

## QA sign-off boundary

QA sign-off for the current package means:

- automation evidence is complete and reproducible;
- no hidden blockers remain in the API invocation path;
- all unresolved items are documented as manual/environment follow-up.

It does **not** mean:

- DB state was fully validated;
- actual RQD sample file semantics were fully proven;
- Octopus schedule execution was fully proven on a production-like timeline.
