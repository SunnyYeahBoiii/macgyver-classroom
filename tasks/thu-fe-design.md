# Thu - Frontend Design Tasks

## Scope

Owner: Thu

Role: Frontend design, web UX, landing page, admin UI, shared components, responsive polish.

Primary source docs:

- `docs/macgyver-classroom-design-system.md`
- `features/01-authentication-account-prd.md`
- `features/02-teacher-profile-school-context-prd.md`
- `features/03-vision-catalog-prd.md`
- `features/05-experiment-matching-prd.md`
- `features/06-lesson-plan-generation-prd.md`
- `features/07-lesson-library-prd.md`
- `features/08-export-sharing-prd.md`
- `features/10-content-admin-prd.md`
- `features/11-landing-page-prd.md`
- `features/12-analytics-feedback-prd.md`

Do not edit `CITYFARM-2.0/` unless the task explicitly changes legacy/reference material.

## Design Responsibilities

- Keep UI teacher-first, utilitarian, and easy to scan.
- Cover loading, empty, error, disabled, and permission states.
- Keep safety notes visible in matching, generation, export, and admin review flows.
- Reuse `packages/ui` patterns where possible before adding new components.

## THU-01 - Design System Baseline And Shared UI Inventory

Type: HITL

Parent:

- `docs/macgyver-classroom-design-system.md`

What to build:

Define the first usable web design baseline for the product: tokens, page shells, form patterns, cards, tables, status badges, safety labels, and feedback states.

Acceptance criteria:

- [ ] Shared visual tokens are documented or implemented for color, typography, spacing, border radius, focus, and status states.
- [ ] Core reusable components exist or are specified: button, input, textarea, select, card, table, badge, tabs, modal, toast, empty state, error state.
- [ ] Safety labels have distinct visual states for allowed, caution, blocked, and teacher-check-required.
- [ ] Responsive behavior is defined for mobile, tablet, and desktop.
- [ ] Accessibility basics are covered: labels, focus states, keyboard reachability, color contrast, and error text association.

Blocked by:

- None - can start immediately.

## THU-02 - Landing Page And Pilot Lead Capture UI

Type: AFK

Parent:

- `features/11-landing-page-prd.md`

What to build:

Build the public landing experience that explains the photo-to-lesson workflow, addresses safety/data concerns, and captures qualified pilot leads.

Acceptance criteria:

- [ ] First viewport clearly communicates MacGyver Classroom and the pilot CTA.
- [ ] Page explains the 4-step pipeline: photos, vision catalog, experiment match, lesson plan.
- [ ] A concrete demo case shows materials turning into an experiment and lesson output.
- [ ] Lead capture form collects required lead fields and validates errors.
- [ ] FAQ covers safety, image data, and GDPT 2018 alignment.
- [ ] Submit success and failure states are implemented.
- [ ] UI does not expose whether optional internal lead notification succeeded or failed.

Blocked by:

- `THU-01 - Design System Baseline And Shared UI Inventory`
- `THINH-06 - Leads, Feedback, Analytics, And School Metrics APIs`

## THU-03 - Web Auth, Profile, And Teacher Context Screens

Type: AFK

Parent:

- `features/01-authentication-account-prd.md`
- `features/02-teacher-profile-school-context-prd.md`

What to build:

Build web screens for auth entry, protected teacher shell, onboarding/profile, and lesson context selection.

Acceptance criteria:

- [ ] Sign in, sign up, sign out, and session loading states are represented in the UI.
- [ ] Optional Google OAuth entry appears only when OAuth config is enabled.
- [ ] Current-device logout and expired-session states are clear to the teacher.
- [ ] Teacher profile form captures school, subject, grade band, and classes.
- [ ] Profile can be edited after onboarding.
- [ ] Lesson-specific topic/objective can be selected before generation.
- [ ] Role/permission errors show clear next steps.

Blocked by:

- `THU-01 - Design System Baseline And Shared UI Inventory`
- `THINH-01 - API Foundation, Auth Guards, And Validation`
- `THINH-02 - Identity, Organization, And Teacher Profile APIs`

## THU-04 - Inventory Scan Review And Confirmation UI

Type: AFK

Parent:

- `features/03-vision-catalog-prd.md`

What to build:

Build the web UI for upload/review/confirmation of detected classroom objects, matching the mobile flow where possible.

Acceptance criteria:

- [ ] Teacher can create an inventory scan and upload images.
- [ ] UI shows analysis pending, success, low confidence, and failure states.
- [ ] Detected items show label, confidence, evidence, and teacher-edit controls.
- [ ] Teacher can add missing items, remove false positives, and confirm inventory.
- [ ] Confirmed inventory summary is ready to feed experiment matching.

Blocked by:

- `THU-03 - Web Auth, Profile, And Teacher Context Screens`
- `THINH-04 - Inventory Scan, Confirmed Item, And Asset APIs`
- `PHONG-02 - Vision Scan Analysis Pipeline`

## THU-05 - Experiment Matching And Lesson Generation UI

Type: AFK

Parent:

- `features/05-experiment-matching-prd.md`
- `features/06-lesson-plan-generation-prd.md`
- `features/09-safety-quality-guardrails-prd.md`

What to build:

Build the teacher web flow from confirmed inventory to suggested experiments, safety review, generation context, and editable generated lesson.

Acceptance criteria:

- [ ] Suggestion cards show title, grade/subject/topic, duration, difficulty, material fit, and safety category.
- [ ] Filters and empty states make it clear why no experiment matched.
- [ ] Experiment detail shows reasoning, missing materials, alternatives, and safety notes.
- [ ] Generation context form is editable before submit.
- [ ] Lesson editor shows structured sections and preserves safety notes.
- [ ] Blocked/unsafe output cannot be presented as ready-to-use.
- [ ] Teacher can report unsafe or inappropriate generated content from lesson or experiment detail views.

Blocked by:

- `THU-04 - Inventory Scan Review And Confirmation UI`
- `PHONG-04 - Safety Guardrails Engine`
- `PHONG-05 - Experiment Matching Engine`
- `PHONG-06 - Lesson Generation Pipeline`

## THU-06 - Lesson Library, Export, Share, And Feedback UI

Type: AFK

Parent:

- `features/07-lesson-library-prd.md`
- `features/08-export-sharing-prd.md`
- `features/12-analytics-feedback-prd.md`

What to build:

Build web screens for lesson reuse: searchable library, version view, export/copy/share controls, and feedback capture.

Acceptance criteria:

- [ ] Library supports search/filter basics and clear empty state.
- [ ] Lesson detail shows current version, generated timestamp, and safety notes.
- [ ] Duplicate, favorite, archive, and delete actions are represented, with confirmation before destructive delete.
- [ ] Export PDF and copy Markdown/plain text actions have success/error states.
- [ ] Share link UI respects organization policy and read-only constraints.
- [ ] Feedback form captures rating, issue type, optional comment, qualitative preparation-time feedback, and unsafe/inappropriate content reports.
- [ ] UI event names align with the analytics event taxonomy where frontend emits events.
- [ ] School admin aggregate metrics can be viewed when role allows.

Blocked by:

- `THU-05 - Experiment Matching And Lesson Generation UI`
- `THINH-05 - Lesson Library, Versioning, Export, And Share APIs`
- `THINH-06 - Leads, Feedback, Analytics, And School Metrics APIs`

## THU-07 - Admin Portal And Content Review UI

Type: AFK

Parent:

- `features/10-content-admin-prd.md`
- `features/04-property-mapping-prd.md`
- `features/09-safety-quality-guardrails-prd.md`

What to build:

Build role-gated admin screens for content curation, review queues, filters, status transitions, safety rule review, lead review, feedback review, and audit visibility.

Acceptance criteria:

- [ ] Admin lists support pagination, filters, sort, and loading/empty/error states.
- [ ] Experiments, materials, curriculum mappings, safety rules, leads, and feedback can be reviewed.
- [ ] Status transitions collect reviewer note where required.
- [ ] Risky experiments can be disabled quickly.
- [ ] Audit log view shows actor, action, entity, before/after summary, and timestamp.
- [ ] Non-admin users cannot access admin UI.

Blocked by:

- `THU-01 - Design System Baseline And Shared UI Inventory`
- `THINH-03 - Material, Property, Experiment, And Curriculum CRUD APIs`
- `THINH-07 - Content Admin Audit, Review Queues, And Status Transitions`
- `PHONG-01 - AI Run Logging, Prompt Versions, And Model Client`
