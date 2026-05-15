---
name: security-review
description: Performs security-focused review of code, config, dependencies, and operational changes. Use when asked to review security, auth, secrets, permissions, input handling, data exposure, or supply-chain risk.
---

# Security Review

## Quick Start

Load relevant repo context, then review for exploitable behavior first. Treat theoretical style concerns as secondary.

## Workflow

1. Define scope: changed files, threat boundary, data sensitivity, deployment surface.
2. Inspect authn/authz, input validation, output encoding, secrets, storage, logging, dependency use, and network calls.
3. Check default-deny behavior, least privilege, and safe failure modes.
4. Verify with tests, static checks, or concrete reasoning from code paths.
5. Report findings first, ordered by severity, with file/line references and practical fixes.

## Output

Use this format:

- Severity: Critical, High, Medium, Low
- Location: file and line
- Risk: exploit or failure mode
- Fix: smallest actionable remediation
- Verification: test or command that should prove the fix

