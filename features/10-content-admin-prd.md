# PRD - FRS-10 Content Admin

## Status

Draft for MVP planning.

## Source Docs

- `docs/macgyver-classroom-frs.md` - FRS-10
- `docs/macgyver-classroom-system-design.md` - Admin/content architecture
- `docs/macgyver-classroom-brd.md` - Content operation process

## Problem

MacGyver Classroom depends on curated experiments, material mappings, curriculum links, and safety rules. These cannot be hard-coded or unmanaged during pilot because content will need correction, review, disabling, and improvement from teacher feedback.

## Goals

- Provide a role-gated admin portal for content curation.
- Manage experiments, materials, curriculum mappings, safety rules, leads, feedback, and audit logs.
- Support persistent review queues with pagination, filters, sort, notes, status transitions, reviewer ID, and timestamps.
- Allow immediate disable of risky experiment templates.
- Preserve audit trail for published content changes.

## Non-Goals

- Full CMS for marketing pages.
- Multi-tenant school billing administration.
- AI-assisted bulk content generation in MVP.
- Public community moderation.

## Primary Users

- Content Admin: reviews and manages curated content.
- School Admin: may view leads or reports later if authorized.
- Internal pilot operator: follows up with lead and feedback queues.

## User Stories

- As a content admin, I can create and edit curated experiments.
- As a content admin, I can manage material aliases, properties, and alternatives.
- As a content admin, I can manage curriculum and safety mappings.
- As a content admin, I can review reports and teacher feedback.
- As a content admin, I can disable risky content immediately.
- As an operator, I can review pilot leads and follow-up status.

## MVP Scope

- Admin authentication and role gate.
- Experiment template management.
- Material and property mapping management.
- Curriculum mapping management.
- Safety rule management.
- Feedback and report review queue.
- Lead review queue.
- Audit log for published content changes.

## Functional Requirements

| ID       | Requirement                                                                                           |
| -------- | ----------------------------------------------------------------------------------------------------- |
| ADMIN-01 | Only Content Admin can access content admin tools.                                                    |
| ADMIN-02 | Content Admin can create, edit, publish, unpublish, and disable experiment templates.                 |
| ADMIN-03 | Content Admin can manage material catalog, aliases, properties, and alternatives.                     |
| ADMIN-04 | Content Admin can manage curriculum mappings.                                                         |
| ADMIN-05 | Content Admin can manage safety rules and denylist entries.                                           |
| ADMIN-06 | Content Admin can review teacher feedback and reports.                                                |
| ADMIN-07 | Content Admin can review landing leads and update follow-up status.                                   |
| ADMIN-08 | Admin queues support persistent pagination, filters, sorting, notes, status, reviewer, and timestamp. |
| ADMIN-09 | Every change to published content creates an audit log.                                               |
| ADMIN-10 | Optimistic UI changes roll back when API PATCH fails.                                                 |

## Core Flow

1. Content Admin signs into admin portal.
2. Admin opens a queue: experiments, materials, curriculum, safety, leads, feedback, or audit.
3. Server loads initial data.
4. Admin filters, sorts, and opens a detail record.
5. Admin edits fields, status, notes, or reviewer assignment.
6. API validates and persists changes.
7. Audit log records published content changes.
8. UI refreshes or rolls back if the save fails.

## Admin Modules

Expected admin areas:

- `admin/experiments`
- `admin/materials`
- `admin/curriculum`
- `admin/safety-rules`
- `admin/leads`
- `admin/feedback`
- `admin/audit`

## Data Model

Primary entities:

- `ExperimentTemplate`
- `ExperimentMaterialRequirement`
- `ExperimentStep`
- `ExperimentSafetyNote`
- `Material`
- `MaterialAlias`
- `MaterialProperty`
- `MaterialAlternative`
- `CurriculumStandard`
- `ExperimentCurriculumMapping`
- `SafetyRule`
- `Lead`
- `Feedback`
- `ReviewNote`
- `ContentStatusHistory`
- `AuditLog`

## API Contract

Candidate endpoints:

- `GET /admin/experiments`
- `POST /admin/experiments`
- `PATCH /admin/experiments/:id`
- `GET /admin/materials`
- `PATCH /admin/materials/:id`
- `GET /admin/curriculum`
- `PATCH /admin/curriculum/:id`
- `GET /admin/safety-rules`
- `PATCH /admin/safety-rules/:id`
- `GET /admin/leads`
- `PATCH /admin/leads/:id`
- `GET /admin/feedback`
- `PATCH /admin/feedback/:id`
- `GET /admin/audit`

Response requirements:

- All list endpoints support real pagination, filters, and sort.
- All status transitions persist.
- Reviewer ID and timestamp persist.
- Audit log entries include actor, action, entity, before/after summary, and timestamp.

## UX Requirements

- Admin pages use dense, utilitarian tables and detail panels.
- Filters and sort are visible and persistent.
- Risky actions like disable and publish require confirmation.
- Failed optimistic updates roll back and show the save error.
- Admin UI is role-gated and tested.

## Safety And Quality

- Published experiment cannot be missing safety category.
- Disable action must take effect immediately in matching.
- Admin cannot bypass schema validation.
- Audit log cannot be edited from normal admin UI.

## Analytics

Track:

- `admin_queue_opened`
- `admin_record_updated`
- `admin_status_transitioned`
- `admin_experiment_published`
- `admin_experiment_disabled`
- `admin_lead_status_updated`
- `admin_feedback_reviewed`

## Acceptance Criteria

- Content Admin can create and update experiment templates.
- Content Admin can manage material mappings and safety rules.
- Admin lists have pagination, filters, and sort.
- Review notes, reviewer ID, timestamps, and status persist.
- Published content changes create audit logs.
- Teacher role cannot access admin endpoints.
- Optimistic UI rolls back on failed PATCH.

## Open Questions

- Should admin portal live in `apps/admin` or inside `apps/web` route group for MVP?
- What content approval statuses are required: draft, in_review, published, disabled, archived?
- Which users can be Content Admin during pilot, and how are they provisioned?
