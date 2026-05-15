# PRD - FRS-07 Lesson Library

## Status

Draft for MVP planning.

## Source Docs

- `docs/macgyver-classroom-frs.md` - FRS-07
- `docs/macgyver-classroom-prd.md` - Save, edit, export, and share MVP goal
- `docs/macgyver-classroom-system-design.md` - Mobile library layer and lessons data model

## Problem

Teachers need generated lesson plans to remain reusable after the creation session. Without a searchable lesson library, the product only saves time once and cannot build teacher trust, reuse, or pilot usage evidence.

## Goals

- Let teachers view saved lesson plans.
- Support search and filters by keyword, grade, subject, topic, and date.
- Let teachers duplicate a lesson for a different class.
- Let teachers mark favorite lessons.
- Let teachers archive or delete lessons.

## Non-Goals

- Public marketplace of lessons.
- Collaborative real-time editing.
- Student assignment distribution.
- Full version diffing in MVP.

## Primary Users

- Teacher: manages personal saved lesson plans.
- School Admin: may later view aggregate usage, not individual private drafts by default.

## User Stories

- As a teacher, I can reopen a lesson I generated last week.
- As a teacher, I can search for a lesson by topic, grade, subject, or date.
- As a teacher, I can duplicate a lesson and adapt it for another class.
- As a teacher, I can favorite frequently used lessons.
- As a teacher, I can archive lessons I no longer need without losing data accidentally.

## MVP Scope

- Library list screen.
- Keyword search.
- Filters for class/grade, subject, topic, and date created.
- Favorite toggle.
- Duplicate lesson action.
- Archive or delete action, with confirmation for destructive delete.
- Open lesson in editor.

## Functional Requirements

| ID         | Requirement                                                            |
| ---------- | ---------------------------------------------------------------------- |
| LIBRARY-01 | Teacher can view a list of saved lesson plans.                         |
| LIBRARY-02 | Teacher can search lessons by keyword.                                 |
| LIBRARY-03 | Teacher can filter lessons by grade, subject, topic, and created date. |
| LIBRARY-04 | Teacher can duplicate a lesson for another class or context.           |
| LIBRARY-05 | Teacher can mark and unmark a lesson as favorite.                      |
| LIBRARY-06 | Teacher can archive a lesson.                                          |
| LIBRARY-07 | Teacher can delete a lesson with confirmation if delete is enabled.    |
| LIBRARY-08 | Teacher can open a saved lesson in the editor.                         |
| LIBRARY-09 | Library respects teacher and organization access boundaries.           |

## Core Flow

1. Teacher opens Library tab.
2. App loads saved lessons sorted by recent activity.
3. Teacher searches or filters.
4. Teacher opens, duplicates, favorites, archives, or deletes a lesson.
5. App persists the action and updates the list.

## Data Model

Primary entities:

- `LessonPlan`: parent saved lesson.
- `LessonPlanVersion`: versioned content.
- `LessonExport`: generated export artifacts.
- `ExperimentTemplate`: source experiment metadata.
- `InventoryScan`: source inventory metadata.

Key fields:

- `LessonPlan.userId`
- `LessonPlan.organizationId`
- `LessonPlan.title`
- `LessonPlan.subject`
- `LessonPlan.gradeBand`
- `LessonPlan.topic`
- `LessonPlan.favorite`
- `LessonPlan.archivedAt`
- `LessonPlan.deletedAt`
- `LessonPlan.updatedAt`

## API Contract

Candidate endpoints:

- `GET /lessons`
- `GET /lessons/:id`
- `POST /lessons/:id/duplicate`
- `PATCH /lessons/:id`
- `POST /lessons/:id/archive`
- `DELETE /lessons/:id`

Query parameters:

- `q`
- `subject`
- `gradeBand`
- `topic`
- `createdFrom`
- `createdTo`
- `favorite`
- `archived`

Response requirements:

- Use pagination for lesson list.
- Return source experiment summary and latest version metadata.
- Do not return another teacher's private lessons unless organization policy explicitly allows it.

## UX Requirements

- Library is a primary bottom-nav destination.
- Recent and favorite lessons should be easy to scan.
- Empty state should lead to Scan or Generate actions.
- Archive/delete actions require clear confirmation.
- Duplicate flow should ask for new class/context where helpful.

## Safety And Quality

- Archived lessons should not disappear permanently.
- Deleted lessons should be soft-deleted unless retention policy says otherwise.
- Library must preserve safety notes and source metadata.
- Export actions remain blocked until safety confirmation requirements are met.

## Analytics

Track:

- `library_opened`
- `lesson_search_performed`
- `lesson_filter_applied`
- `lesson_opened`
- `lesson_duplicated`
- `lesson_favorited`
- `lesson_archived`
- `lesson_deleted`

## Acceptance Criteria

- Teacher sees saved lesson list after generating and saving a lesson.
- Search finds lessons by title or topic.
- Filters narrow results by grade, subject, topic, and date.
- Duplicate creates a separate lesson without mutating the original.
- Favorite state persists.
- Archive removes lesson from default list but keeps it recoverable.

## Open Questions

- Should delete be available in MVP, or should MVP only support archive?
- Should School Admin see shared organization lessons in the same library or a separate report view?
- Should offline draft edits appear in library before sync?
