---
name: debug
description: Guides disciplined diagnosis for failing tests, broken behavior, crashes, flaky flows, or performance regressions. Use when debugging is requested or when an issue is reported as broken, failing, throwing, or inconsistent.
---

# Debug

## Workflow

1. Reproduce the failure with the smallest command or interaction.
2. Capture exact symptoms: error text, logs, inputs, environment, and recent changes.
3. Minimize the case until the failing boundary is clear.
4. Form one hypothesis at a time and instrument only what validates it.
5. Fix the root cause, not the symptom.
6. Add or update a regression test.
7. Run focused verification, then broader checks based on blast radius.

## Guardrails

- Do not patch from guesswork while reproduction is still unclear.
- Do not hide errors unless the product requirement says to degrade gracefully.
- Keep diagnostics out of production output unless they are intentional logging.

