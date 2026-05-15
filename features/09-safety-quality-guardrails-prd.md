# PRD - FRS-09 Safety & Quality Guardrails

## Status

Draft for MVP planning.

## Source Docs

- `docs/macgyver-classroom-frs.md` - FRS-09
- `docs/macgyver-classroom-srs.md` - AI guardrails and privacy requirements
- `docs/macgyver-classroom-brd.md` - Compliance and safety requirements
- `docs/macgyver-classroom-system-design.md` - Safety rules, admin, and AI contracts

## Problem

The product suggests experiments for real classrooms. Unsafe materials, unclear teacher checks, unvalidated AI output, or stale curated content could create classroom risk. Safety and quality controls must be part of matching, generation, export, reporting, and admin disable workflows.

## Goals

- Attach safety category to every experiment.
- Block suggestions using denylisted materials or unsafe combinations.
- Require teacher safety confirmation before export.
- Let users report unsuitable or unsafe content.
- Let Content Admin immediately disable an experiment template.
- Validate AI outputs before teacher display or export.

## Non-Goals

- Replacing teacher professional judgment.
- Certifying experiments as legally safe for every school.
- Full local regulatory compliance workflow in MVP.
- Student safety incident management.

## Primary Users

- Teacher: reviews safety notes and confirms readiness.
- Content Admin: manages safety rules, reports, and disabled templates.
- School Admin: may review aggregate reports later.

## User Stories

- As a teacher, I can see safety notes for every suggested experiment and lesson.
- As a teacher, I am prevented from exporting a lesson before confirming safety checks.
- As a teacher, I can report unsafe or inappropriate content.
- As a content admin, I can disable an experiment immediately if a risk appears.
- As the system, I can reject invalid AI output or unsafe material combinations.

## MVP Scope

- Safety category on each experiment template.
- Material denylist and safety rules.
- Safety check during matching.
- Safety note and teacher checks required in generated lessons.
- Export safety confirmation gate.
- Report content flow.
- Admin immediate disable action.

## Functional Requirements

| ID        | Requirement                                                                       |
| --------- | --------------------------------------------------------------------------------- |
| SAFETY-01 | Every experiment template has a safety category.                                  |
| SAFETY-02 | System blocks suggestions containing denylisted materials or unsafe combinations. |
| SAFETY-03 | Generated lesson must include safety notes and teacher checks.                    |
| SAFETY-04 | Teacher must confirm safety checks before export.                                 |
| SAFETY-05 | User can report inappropriate or unsafe content.                                  |
| SAFETY-06 | Content Admin can immediately disable an experiment template.                     |
| SAFETY-07 | Disabled templates stop appearing in new matches.                                 |
| SAFETY-08 | AI JSON output is schema-validated before use.                                    |
| SAFETY-09 | API errors do not expose raw provider stack traces.                               |

## Core Flow

1. Content Admin publishes experiment with safety category and notes.
2. Teacher confirms inventory.
3. Matching engine evaluates templates.
4. Safety policy blocks unsafe templates and materials.
5. Lesson generator adds required safety notes and teacher checks.
6. Teacher reviews and edits lesson.
7. Export requires safety confirmation.
8. Teacher can report content after viewing or using a lesson.
9. Content Admin reviews report and can disable template immediately.

## Data Model

Primary entities:

- `SafetyRule`: denylist, warning, or required check.
- `ExperimentTemplate`: safety category and status.
- `ExperimentSafetyNote`: curated notes.
- `SafetyCheckResult`: result of safety evaluation.
- `Feedback`: report or rating.
- `AuditLog`: admin disable/edit history.

Key fields:

- `SafetyRule.ruleType`
- `SafetyRule.materialId`
- `SafetyRule.severity`
- `SafetyRule.active`
- `ExperimentTemplate.safetyCategory`
- `ExperimentTemplate.status`
- `SafetyCheckResult.blocked`
- `SafetyCheckResult.reasons`
- `Feedback.type`
- `Feedback.status`

## API Contract

Candidate endpoints:

- `POST /safety/check`
- `POST /lessons/:id/safety-confirmation`
- `POST /feedback/reports`
- `GET /admin/safety-rules`
- `POST /admin/safety-rules`
- `PATCH /admin/safety-rules/:id`
- `PATCH /admin/experiments/:id/status`

Response requirements:

- Return structured block reasons and warning reasons.
- Return teacher-facing safety notes separately from admin-only metadata.
- Admin status changes must persist and create audit log entries.

## Safety Policy Rules

- Denylisted materials block matching.
- Disabled templates block matching and generation.
- Missing safety category blocks publish.
- Empty generated safety notes block lesson save/export.
- Teacher export confirmation is required before PDF/share/copy export.
- Reported content remains visible only if not disabled by admin policy.

## UX Requirements

- Safety category is visible on experiment cards and lesson plans.
- Safety checklist appears before export, not after.
- Report action is available from experiment, lesson, and shared view where appropriate.
- Admin disable action is fast and clearly confirmed.

## Analytics

Track:

- `safety_check_passed`
- `safety_check_blocked`
- `safety_confirmation_completed`
- `content_report_submitted`
- `experiment_disabled`
- `safety_rule_updated`

## Acceptance Criteria

- Published experiment cannot exist without safety category.
- Denylisted material prevents unsafe experiment from appearing.
- Generated lesson without safety notes fails validation.
- Export is blocked until teacher confirms safety.
- User can submit report and Content Admin can review it.
- Content Admin can disable an experiment and new matches exclude it immediately.

## Open Questions

- What initial denylist and safety categories are required for pilot launch?
- Should reported content auto-hide after a severity threshold?
- Who owns final safety policy approval before pilot schools use the app?
