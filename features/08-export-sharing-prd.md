# PRD - FRS-08 Export & Sharing

## Status

Draft for MVP planning.

## Source Docs

- `docs/macgyver-classroom-frs.md` - FRS-08
- `docs/macgyver-classroom-prd.md` - Export PDF/Markdown and share MVP goal
- `docs/macgyver-classroom-system-design.md` - Lessons data model and storage model

## Problem

Teachers need generated lesson plans outside the app for classroom preparation, printing, sharing with peers, and school reporting. Exports must preserve safety notes, materials, and structure so the lesson remains usable and safe after leaving the app.

## Goals

- Export lesson plans as PDF.
- Copy lesson content as Markdown or plain text.
- Generate read-only share links when organization policy allows.
- Ensure exports always include safety notes and materials.
- Track export usage for pilot metrics.

## Non-Goals

- Editable public share pages.
- Student submission workflow.
- LMS integrations in MVP.
- DOCX export unless later prioritized.

## Primary Users

- Teacher: exports and shares lesson plans.
- School Admin: may use aggregate export counts for pilot evaluation.

## User Stories

- As a teacher, I can export a lesson to PDF for printing or sharing.
- As a teacher, I can copy Markdown/plain text into another document.
- As a teacher, I can create a read-only link if my organization permits it.
- As a teacher, I can trust that safety notes are included in any export.
- As a school admin, I can see that teachers are exporting and using generated lessons.

## MVP Scope

- PDF export from saved lesson.
- Markdown/plain-text copy from saved lesson.
- Optional read-only share link controlled by organization policy.
- Safety confirmation gate before export.
- Export artifact tracking.

## Functional Requirements

| ID        | Requirement                                                                         |
| --------- | ----------------------------------------------------------------------------------- |
| EXPORT-01 | Teacher can export a saved lesson to PDF.                                           |
| EXPORT-02 | Teacher can copy lesson content as Markdown or plain text.                          |
| EXPORT-03 | Teacher can create a read-only share link when organization policy allows sharing.  |
| EXPORT-04 | Export includes safety notes and materials required for preparation.                |
| EXPORT-05 | Export requires teacher safety confirmation before completion.                      |
| EXPORT-06 | Export records export type, user, lesson, timestamp, and artifact reference.        |
| EXPORT-07 | Share link can be revoked by lesson owner or admin policy.                          |
| EXPORT-08 | Export uses the latest saved lesson version unless teacher chooses another version. |

## Core Flow

1. Teacher opens a saved lesson.
2. Teacher taps Export or Share.
3. App checks required safety confirmation.
4. Teacher confirms safety checklist if not already completed.
5. Teacher chooses PDF, copy Markdown/plain text, or share link.
6. API generates or records export.
7. App presents downloaded file, copied content, or read-only URL.

## Data Model

Primary entities:

- `LessonPlan`: source lesson.
- `LessonPlanVersion`: exported content version.
- `LessonExport`: export artifact and metadata.
- `SafetyCheckResult`: teacher safety confirmation.
- `Organization`: share policy.

Key fields:

- `LessonExport.lessonPlanId`
- `LessonExport.lessonPlanVersionId`
- `LessonExport.exportType`
- `LessonExport.storagePath`
- `LessonExport.shareTokenHash`
- `LessonExport.revokedAt`
- `LessonExport.createdByUserId`
- `LessonExport.createdAt`

## API Contract

Candidate endpoints:

- `POST /lessons/:id/exports/pdf`
- `POST /lessons/:id/exports/markdown`
- `POST /lessons/:id/share-links`
- `DELETE /lessons/:id/share-links/:shareId`
- `GET /share/lessons/:token`

Response requirements:

- Return signed download URL for private PDF artifacts.
- Return copied text payload for Markdown/plain text.
- Return read-only URL only if sharing is allowed.
- Include safety confirmation status and blocking reason if export is blocked.

## PDF Content Requirements

Each PDF must include:

- Lesson title.
- Grade band, subject, topic, and duration.
- Learning objectives.
- Materials and preparation.
- Lesson flow.
- Guiding questions.
- Assessment.
- Safety notes.
- Teacher checks required.
- Source/generated timestamp where useful.

## UX Requirements

- Export actions live near lesson editor actions, not hidden in settings.
- Safety checklist is shown before first export.
- Read-only share link clearly indicates it cannot be edited.
- Teacher can copy link or revoke it.
- Export failures show retry action.

## Safety And Privacy

- Export cannot omit safety notes.
- Share links are read-only and tokenized.
- Share link creation respects organization policy.
- Private PDFs should use signed URLs and private storage.
- Do not expose teacher private profile fields unnecessarily in exported content.

## Analytics

Track:

- `lesson_export_started`
- `lesson_exported`
- `lesson_export_failed`
- `lesson_markdown_copied`
- `lesson_share_link_created`
- `lesson_share_link_revoked`

## Acceptance Criteria

- Teacher can export a saved lesson as PDF.
- Exported PDF includes materials and safety notes.
- Markdown/plain text copy includes all required sections.
- Export is blocked until teacher completes safety confirmation.
- Read-only share link is unavailable when organization policy disallows it.
- Export event is recorded for pilot metrics.

## Open Questions

- Should exported PDFs include MacGyver Classroom branding and school name?
- Should share links expire automatically in MVP?
- Should copy output be Markdown only, plain text only, or a user toggle?
