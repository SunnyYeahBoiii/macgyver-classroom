# CI Readiness Rule

Use this rule before handing off, opening a PR, or claiming work is complete.

## Required Checks

- Relevant tests pass locally or the limitation is documented with the exact failing command.
- Lint, typecheck, format, build, and migration checks are run when available and relevant.
- Dependency, lockfile, generated-code, and schema changes are intentional and included.
- No secrets, local paths, debug logs, snapshots, or machine-specific artifacts are committed.
- CI scripts are deterministic and do not depend on interactive prompts or local-only services.
- New environment variables are documented with safe examples.

## Handoff Standard

Report the commands run and their result. If a check was skipped, state why and what risk remains.

