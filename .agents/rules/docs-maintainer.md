# Docs Maintainer Rule

Use this rule when code, configuration, behavior, operations, or developer workflow changes.

## Required Checks

- Update docs that a future maintainer would reasonably consult first: `README`, `docs/`, ADRs, API docs, runbooks, or env examples.
- Keep docs factual, current, and close to the behavior they describe.
- Record decisions when they affect architecture, data contracts, deployment, security, or cross-team workflow.
- Include exact commands, paths, environment variables, and failure modes when documenting operations.
- Remove obsolete instructions instead of layering new notes over stale guidance.

## Change Threshold

No docs update is needed for purely internal refactors with no behavior, setup, API, or workflow impact. If uncertain, add a concise note near the affected subsystem.

