# MacGyver Classroom Claude Guide

## Project

MacGyver Classroom is a classroom science assistant for teachers. The product goal is to turn available classroom objects and photos into safe experiment ideas, structured lesson plans, reusable lesson libraries, and pilot-school lead capture.

Current workspace is a TypeScript monorepo:

- `apps/web` - Next.js web app.
- `apps/api` - NestJS API.
- `packages/ui` - shared React UI package.
- `packages/eslint-config` and `packages/typescript-config` - shared tooling.
- `docs/` - BRD, PRD, FRS, SRS for product requirements.
- `CITYFARM-2.0/` - reference/legacy material; do not edit unless the task explicitly targets it.

## Source Of Truth

- Product scope: `docs/macgyver-classroom-prd.md`
- Functional requirements: `docs/macgyver-classroom-frs.md`
- Technical requirements: `docs/macgyver-classroom-srs.md`
- Business context: `docs/macgyver-classroom-brd.md`
- Agent harness: `.agents/README.md`

## Commands

- Root build: `npm run build`
- Root lint: `npm run lint`
- Root typecheck: `npm run check-types`
- Root format: `npm run format`
- Web dev: `npm --workspace web run dev`
- API dev: `npm --workspace api run start:dev`
- API tests: `npm --workspace api run test`

## Documentation Lookup

Use Context7 MCP whenever the task asks about a library, framework, SDK, API, CLI tool, or cloud service. Start with `resolve-library-id`, then `query-docs`. Prefer this over web search for library docs.

## Rules

Apply `.agents/rules` explicitly:

- `code-quality.md` for implementation, refactor, and review.
- `docs-maintainer.md` when behavior, setup, API, deployment, or workflow changes.
- `ci-readiness.md` before handoff or completion.
- `tdd.md` for behavior changes and bug fixes.
- `unit-test.md` for unit tests and test review.

## Skills

Use `.agents/skills` when the task matches:

- `code-review` for PR/code review against code quality.
- `security-review` for auth, secrets, permissions, input handling, data exposure, and supply-chain risk.
- `debug` for failing tests, crashes, flaky behavior, or regressions.
- `tdd` for test-first feature work, bug fixes, and risky refactors.

## Sub-Agents

When sub-agent delegation is available and allowed, prefer the migrated prompts in `.agents/agents`:

- `codebase-locator` to find files and ownership.
- `codebase-analyzer` to inspect implementation details.
- `codebase-pattern-finder` to find existing patterns before adding new ones.
- `thoughts-locator` and `thoughts-analyzer` for research notes and historical planning.
- `web-search-researcher` only for current external facts that Context7 cannot cover.

If the runtime cannot delegate, use these files as role guidance and perform the work locally.

## Working Rules

Keep changes scoped. Do not revert unrelated dirty files. Prefer existing repo patterns over new abstractions. Update tests and docs in proportion to the risk and user-visible impact.

