# Thinh - Backend CRUD Tasks

## Scope

Owner: Thinh

Role: Backend CRUD, auth/profile data, core resource APIs, admin operations, analytics storage.

Primary source docs:

- `features/01-authentication-account-prd.md`
- `features/02-teacher-profile-school-context-prd.md`
- `features/03-vision-catalog-prd.md`
- `features/04-property-mapping-prd.md`
- `features/07-lesson-library-prd.md`
- `features/08-export-sharing-prd.md`
- `features/10-content-admin-prd.md`
- `features/11-landing-page-prd.md`
- `features/12-analytics-feedback-prd.md`

Do not edit `CITYFARM-2.0/` unless the task explicitly changes legacy/reference material.

## Backend CRUD Responsibilities

- Own NestJS controller/service/repository CRUD patterns for stable resources.
- Keep DTO validation, pagination, filtering, sorting, and auth guards consistent.
- Coordinate response contracts with Phuong and Thu.
- Provide persistence boundaries that Phong's AI pipeline can call without owning CRUD modules.

## THINH-01 - API Foundation, Auth Guards, And Validation

Type: AFK

Parent:

- `features/01-authentication-account-prd.md`
- `docs/macgyver-classroom-srs.md`

What to build:

Stabilize the API foundation for all feature modules: auth guards, role guards, DTO validation, error shape, pagination query, and test conventions.

Acceptance criteria:

- [ ] JWT access/refresh pattern is represented in auth service/controller contracts.
- [ ] Teacher, School Admin, and Content Admin roles are enforced through guards.
- [ ] Shared validation pipe and consistent error shape are configured.
- [ ] Pagination query DTO is reused by list endpoints.
- [ ] API tests cover protected route behavior and validation failures.
- [ ] Contract notes are shared with Phuong and Thu.

Blocked by:

- None - can start immediately.

## THINH-02 - Identity, Organization, And Teacher Profile APIs

Type: AFK

Parent:

- `features/01-authentication-account-prd.md`
- `features/02-teacher-profile-school-context-prd.md`

What to build:

Build CRUD and account-facing APIs for users, organizations, teacher profiles, and lesson context defaults.

Acceptance criteria:

- [ ] Teacher can register and sign in with email/password.
- [ ] Optional Google OAuth sign-in is available only when OAuth config is enabled.
- [ ] API returns JWT access token and refresh token using the agreed auth pattern.
- [ ] API supports access-token refresh without requiring the teacher to re-enter credentials.
- [ ] API supports current-device logout and invalidates the relevant refresh token/session state.
- [ ] Teacher profile supports school, subject, grade band, common classes, and updates after onboarding.
- [ ] Organization data can support pilot-school context without full school directory management.
- [ ] Profile endpoints return data needed by mobile and web onboarding.
- [ ] Private profile data is protected by owner/role checks.
- [ ] Unit tests cover create, update, get-current-profile, and authorization.

Blocked by:

- `THINH-01 - API Foundation, Auth Guards, And Validation`

## THINH-03 - Material, Property, Experiment, And Curriculum CRUD APIs

Type: AFK

Parent:

- `features/04-property-mapping-prd.md`
- `features/05-experiment-matching-prd.md`
- `features/10-content-admin-prd.md`

What to build:

Build content CRUD APIs for canonical materials, aliases, material properties, alternatives, curated experiments, curriculum mapping, and disabled states.

Acceptance criteria:

- [ ] Content Admin can create, edit, disable, list, filter, and sort materials and aliases.
- [ ] Content Admin can manage material properties and safe alternatives.
- [ ] Content Admin can create, edit, disable, list, filter, and sort experiment templates.
- [ ] Curriculum fields support grade band, subject, topic, duration, and difficulty.
- [ ] Disabled materials, mappings, and experiments are excluded from teacher-facing suggestions.
- [ ] Tests cover CRUD, disabled filtering, pagination, and role protection.

Blocked by:

- `THINH-01 - API Foundation, Auth Guards, And Validation`

## THINH-04 - Inventory Scan, Confirmed Item, And Asset APIs

Type: AFK

Parent:

- `features/03-vision-catalog-prd.md`

What to build:

Build the non-AI inventory APIs: scan lifecycle, image asset metadata, detected item persistence, teacher corrections, confirmed item CRUD, and status transitions.

Acceptance criteria:

- [ ] Teacher can create an inventory scan and attach image assets.
- [ ] Scan status supports pending, analyzing, completed, failed, and confirmed.
- [ ] Detected items can be stored with label, confidence, evidence, and AI run reference.
- [ ] Teacher can correct, remove, and manually add items before confirmation.
- [ ] Confirmed item list is readable by matching/generation flows.
- [ ] Ownership checks prevent teachers from reading another teacher's scans.
- [ ] Tests cover scan lifecycle, item correction, confirmation, and access control.

Blocked by:

- `THINH-01 - API Foundation, Auth Guards, And Validation`
- `PHONG-02 - Vision Scan Analysis Pipeline` for final detected-item payload shape.

## THINH-05 - Lesson Library, Versioning, Export, And Share APIs

Type: AFK

Parent:

- `features/06-lesson-plan-generation-prd.md`
- `features/07-lesson-library-prd.md`
- `features/08-export-sharing-prd.md`

What to build:

Build persistence and CRUD APIs for generated lessons, lesson versions, library search/filter, duplicate/favorite/archive/delete actions, export records, PDF generation trigger, copy/share metadata, and read-only share links.

Acceptance criteria:

- [ ] Generated lesson can be saved with experiment, inventory, teacher context, AI run, and safety metadata.
- [ ] Editing a lesson creates or updates version data according to the agreed contract.
- [ ] Teacher can list, search, filter, open, edit, duplicate, favorite, archive, and delete lessons they own where delete is enabled.
- [ ] Export endpoint returns PDF or starts export generation with clear status.
- [ ] Markdown/plain-text copy payload includes required lesson sections and safety notes.
- [ ] PDF/export payload includes source/generated timestamp where useful.
- [ ] Share links are read-only and respect organization policy.
- [ ] Tests cover owner access, duplicate, favorite, archive, delete confirmation contract, versioning, export content requirements, and share policy.

Blocked by:

- `THINH-02 - Identity, Organization, And Teacher Profile APIs`
- `PHONG-06 - Lesson Generation Pipeline` for structured lesson JSON contract.

## THINH-06 - Leads, Feedback, Analytics, And School Metrics APIs

Type: AFK

Parent:

- `features/11-landing-page-prd.md`
- `features/12-analytics-feedback-prd.md`

What to build:

Build CRUD/storage APIs for pilot leads, product events, lesson feedback, issue reports, and school-level aggregate metrics.

Acceptance criteria:

- [ ] Landing lead form can create lead records with validation and spam-safe rate limits where available.
- [ ] Lead submission can trigger optional internal notification when configured without exposing notification status to the public response.
- [ ] Core events can be recorded from mobile/web: auth, scan, confirmation, match, generation, save, export, feedback.
- [ ] Event names align with the analytics event taxonomy, including lesson generation, export, feedback, rating, safety block, and report events.
- [ ] Feedback supports rating, issue type, optional comment, qualitative preparation-time feedback, lesson reference, and reporter.
- [ ] Unsafe or inappropriate content reports can be submitted through `POST /feedback/reports` or equivalent, with severity/status fields for admin review.
- [ ] School Admin can read aggregate usage metrics without seeing private teacher content.
- [ ] Content Admin can list and update lead/feedback review status.
- [ ] Tests cover event creation, feedback creation, aggregate metrics, and role visibility.

Blocked by:

- `THINH-01 - API Foundation, Auth Guards, And Validation`

## THINH-07 - Content Admin Audit, Review Queues, And Status Transitions

Type: AFK

Parent:

- `features/10-content-admin-prd.md`
- `features/09-safety-quality-guardrails-prd.md`

What to build:

Build the admin operational layer: review queues, moderation/status transitions, reviewer notes, timestamps, and audit log for content changes.

Acceptance criteria:

- [ ] Admin list endpoints support real pagination, filters, and sort.
- [ ] Experiments, materials, curriculum, safety rules, leads, and feedback expose review status transitions.
- [ ] Unsafe/inappropriate content reports enter the review queue and can disable affected content according to admin policy.
- [ ] Reviewer ID, note, status, and timestamp are persisted.
- [ ] Audit entries include actor, action, entity, before/after summary, and timestamp.
- [ ] Risky experiments can be disabled immediately by Content Admin.
- [ ] Tests cover status transitions, audit creation, filters, and Content Admin guard.

Blocked by:

- `THINH-03 - Material, Property, Experiment, And Curriculum CRUD APIs`
- `THINH-06 - Leads, Feedback, Analytics, And School Metrics APIs`
