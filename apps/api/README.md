# MacGyver Classroom API

NestJS backend for MacGyver Classroom. The current API surface is scaffolded by
domain so later feature work can add route handlers, DTO validation, persistence,
and external integrations without reshaping the source tree.

## Current Scope

- `src/app.module.ts` wires all domain modules.
- Route controllers are intentionally method-free scaffold classes, except
  `GET /health`.
- Supabase Auth is the chosen auth source of truth; local auth files are only
  boundary scaffolds.
- Prisma generated client wiring is deferred until `prisma generate` is part of
  the normal API setup. The schema currently targets `generated/prisma`.

## Module Map

- `common` - decorators, guards, filters, interceptors, shared DTOs.
- `config` - typed config service boundary.
- `database` - Prisma/database boundary placeholders.
- `auth` - Supabase Auth and session context boundary.
- `users` - user and teacher profile boundary.
- `organizations` - schools, memberships, and role context.
- `storage` and `assets` - private storage and media metadata boundaries.
- `inventory` - scan sessions, scan images, detected items, confirmed items.
- `materials` - canonical materials, aliases, properties, alternatives.
- `curriculum` - curriculum standards and experiment mappings.
- `experiments` - experiment templates and matching boundary.
- `ai` - model API, AI runs, prompt version boundary.
- `safety` - rules, checks, and safety confirmation boundary.
- `lessons` - lesson generation, library, and versions.
- `exports` - PDF, Markdown, and share-link boundary.
- `leads` - pilot lead capture and lead events.
- `analytics` - event ingestion and aggregate boundary.
- `feedback` - ratings, reports, moderation queue boundary.
- `admin` - admin composition, reviews, status history, audit.
- `health` - readiness/health endpoint.

## Commands

```bash
npm --workspace api run check-types
npm --workspace api run test
npm --workspace api run build
```
