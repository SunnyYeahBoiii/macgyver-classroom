# Phuong - Mobile + Project Lead Tasks

## Scope

Owner: Phuong

Role: Mobile implementation and project lead.

Primary source docs:

- `features/01-authentication-account-prd.md`
- `features/02-teacher-profile-school-context-prd.md`
- `features/03-vision-catalog-prd.md`
- `features/05-experiment-matching-prd.md`
- `features/06-lesson-plan-generation-prd.md`
- `features/07-lesson-library-prd.md`
- `features/08-export-sharing-prd.md`
- `features/12-analytics-feedback-prd.md`

Do not edit `CITYFARM-2.0/` unless the task explicitly changes legacy/reference material.

## Lead Responsibilities

- Keep the MVP dependency order visible: auth, profile, vision catalog, property mapping, safety guardrails, experiment matching, lesson generation, lesson library, export, analytics, landing, content admin.
- Maintain API contract checklist between mobile, frontend, CRUD backend, and AI backend.
- Review completed slices against acceptance criteria before demo.
- Track blockers across `THINH-*`, `PHONG-*`, and `THU-*` tasks.

## PHUONG-01 - Project Delivery Board And Integration Contract

Type: HITL

Parent:

- `features/README.md`

What to build:

Create the delivery board, sprint grouping, demo checklist, and API contract checklist that the team uses to coordinate implementation.

Acceptance criteria:

- [ ] Every task in these four files is represented in the team board.
- [ ] Each task has owner, status, blocker, target milestone, and verification command.
- [ ] Shared API contract table includes endpoint, request DTO, response DTO, auth requirement, owner, and consumer.
- [ ] Demo checklist follows the teacher path: sign in, profile, scan, confirm inventory, match experiment, generate lesson, save, export, feedback.
- [ ] Risks are tracked for AI safety, image privacy, auth, and missing mobile app scaffold.

Blocked by:

- None - can start immediately.

## PHUONG-02 - Mobile App Shell, Auth Session, And Navigation

Type: AFK

Parent:

- `features/01-authentication-account-prd.md`

What to build:

Create or own the mobile app shell with auth-aware navigation, token/session storage, protected routes, loading/error states, and sign-out flow.

Acceptance criteria:

- [ ] Mobile app has routes/screens for sign in, sign up, onboarding/profile, inventory scan, suggestions, lesson editor, library, export, and feedback.
- [ ] Email/password auth and optional Google OAuth entry are represented, with Google hidden/disabled when OAuth config is off.
- [ ] Auth session can be created, restored after app restart, refreshed, and cleared on sign out.
- [ ] Current-device logout clears local access/refresh token state without affecting unrelated devices.
- [ ] Protected screens redirect unauthenticated users to auth.
- [ ] Role-aware state is ready for Teacher, School Admin, and Content Admin even if mobile only exposes teacher MVP.
- [ ] Auth failures show actionable errors without leaking token details.

Blocked by:

- `THINH-01 - API Foundation, Auth Guards, And Validation`
- `THINH-02 - Identity, Organization, And Teacher Profile APIs`

## PHUONG-03 - Mobile Teacher Profile And Lesson Context Flow

Type: AFK

Parent:

- `features/02-teacher-profile-school-context-prd.md`

What to build:

Implement mobile onboarding and editable profile screens for school, subject, grade band, common classes, and lesson-specific topic/objective.

Acceptance criteria:

- [ ] New teacher is prompted to complete profile after first sign-in.
- [ ] Profile can be edited later without losing current session.
- [ ] Lesson generation context can override profile defaults for one lesson.
- [ ] Empty, validation, save-success, and API-error states are covered.
- [ ] Profile data is passed into experiment matching and lesson generation requests.

Blocked by:

- `PHUONG-02 - Mobile App Shell, Auth Session, And Navigation`
- `THINH-02 - Identity, Organization, And Teacher Profile APIs`

## PHUONG-04 - Mobile Inventory Capture, Upload, And Confirmation Flow

Type: AFK

Parent:

- `features/03-vision-catalog-prd.md`

What to build:

Implement the mobile photo-to-inventory path: capture/select image, upload, trigger scan analysis, review detected items, correct labels, and confirm classroom inventory.

Acceptance criteria:

- [ ] Teacher can add one or more classroom photos to an inventory scan.
- [ ] Upload progress, retry, and failure states are visible.
- [ ] Detected items show label, confidence, evidence, and editable quantity/notes where available.
- [ ] Teacher can remove false positives and add missing items manually.
- [ ] Confirmed inventory is persisted and can be used by experiment matching.
- [ ] Analytics events are emitted for scan created, image uploaded, analysis started/failed, inventory confirmed, and item corrected.

Blocked by:

- `PHUONG-02 - Mobile App Shell, Auth Session, And Navigation`
- `THINH-04 - Inventory Scan, Confirmed Item, And Asset APIs`
- `PHONG-02 - Vision Scan Analysis Pipeline`

## PHUONG-05 - Mobile Experiment Suggestions And Lesson Generation Context

Type: AFK

Parent:

- `features/05-experiment-matching-prd.md`
- `features/06-lesson-plan-generation-prd.md`

What to build:

Implement mobile screens for experiment suggestions, filters, details, safety notes, generation context review, and generation start.

Acceptance criteria:

- [ ] Suggestions show title, grade, subject, topic, duration, difficulty, available/missing materials, and safety category.
- [ ] Teacher can filter suggestions without getting trapped in an unclear empty state.
- [ ] Details screen shows reasoning and safety notes before generation.
- [ ] Teacher can adjust grade, subject, topic, materials, and duration before generating.
- [ ] Generation progress, schema failure, safety failure, and retry states are visible.

Blocked by:

- `PHUONG-03 - Mobile Teacher Profile And Lesson Context Flow`
- `PHUONG-04 - Mobile Inventory Capture, Upload, And Confirmation Flow`
- `PHONG-04 - Safety Guardrails Engine`
- `PHONG-05 - Experiment Matching Engine`
- `PHONG-06 - Lesson Generation Pipeline`

## PHUONG-06 - Mobile Lesson Editor, Library, Export, And Feedback

Type: AFK

Parent:

- `features/07-lesson-library-prd.md`
- `features/08-export-sharing-prd.md`
- `features/12-analytics-feedback-prd.md`

What to build:

Complete the post-generation mobile loop: editable lesson plan, save/version, searchable library, export/share, and quality feedback.

Acceptance criteria:

- [ ] Generated lesson appears in an editable view with objectives, materials, flow, questions, assessment, and safety notes.
- [ ] Teacher can save edits and return to the lesson from the library.
- [ ] Library supports search/filter basics and clear empty state.
- [ ] Teacher can duplicate, favorite, archive, and delete lessons where enabled, with confirmation before destructive delete.
- [ ] Teacher can export PDF and copy Markdown/plain text where supported.
- [ ] Feedback captures rating, issue type, optional comment, qualitative preparation-time feedback, and unsafe/inappropriate content reports.
- [ ] Export and feedback events are recorded for pilot metrics.
- [ ] Mobile event names align with the analytics event taxonomy, including `lesson_rating_submitted` and safety/report events.

Blocked by:

- `PHUONG-05 - Mobile Experiment Suggestions And Lesson Generation Context`
- `THINH-05 - Lesson Library, Versioning, Export, And Share APIs`
- `THINH-06 - Leads, Feedback, Analytics, And School Metrics APIs`

## PHUONG-07 - MVP QA, Release Readiness, And Demo Runbook

Type: HITL

Parent:

- `docs/macgyver-classroom-prd.md`
- `features/README.md`

What to build:

Own final cross-platform verification and prepare the pilot-ready demo runbook.

Acceptance criteria:

- [ ] Demo data exists for one realistic classroom photo-to-lesson scenario.
- [ ] Full teacher workflow passes on mobile and web/admin surfaces needed for the demo.
- [ ] Known issues are classified as blocker, workaround, or post-MVP.
- [ ] Build, typecheck, lint, and test status are recorded for web/api/mobile where applicable.
- [ ] Demo runbook includes accounts, environment variables, startup commands, expected screens, and rollback notes.

Blocked by:

- `PHUONG-06 - Mobile Lesson Editor, Library, Export, And Feedback`
- `THU-07 - Admin Portal And Content Review UI`
- `THINH-07 - Content Admin Audit, Review Queues, And Status Transitions`
- `PHONG-07 - AI Observability, Evaluation Fixtures, And Fallbacks`
