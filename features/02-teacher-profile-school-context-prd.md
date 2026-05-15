# PRD - FRS-02 Teacher Profile & School Context

## Status

Draft for MVP planning.

## Source Docs

- `docs/macgyver-classroom-frs.md` - FRS-02
- `docs/macgyver-classroom-prd.md` - Target users and MVP goals
- `docs/macgyver-classroom-srs.md` - `TeacherProfile`, `Organization`

## Problem

AI-generated lesson plans need grade, subject, class, school, and lesson intent to be useful. Without teacher context, the system can generate generic activities that do not match classroom level, GDPT 2018 alignment, available time, or the teacher's actual teaching constraints.

## Goals

- Capture a teacher's default school, subject, grade band, and classes.
- Use profile data as default context for experiment matching and lesson generation.
- Let teachers change profile data after onboarding.
- Let teachers set lesson-specific topic or objective before generation.

## Non-Goals

- Full school directory management in MVP.
- Timetable, attendance, or student roster management.
- Automated curriculum planning across a semester.
- Multi-school teacher account switching unless needed by pilot schools.

## Primary Users

- Teacher: enters profile and teaching context.
- School Admin: may inspect school-level usage later, but not required for teacher onboarding MVP.

## User Stories

- As a teacher, I can enter my school, subject, grade level, and common classes during onboarding.
- As a teacher, I can update my profile when I change classes or subjects.
- As a teacher, I can choose a lesson topic before generating a plan.
- As the system, I can use teacher profile context to produce grade-appropriate experiment suggestions and lesson plans.

## MVP Scope

- Onboarding profile form after first login.
- Fields for school, subject, grade band, class names, and teaching notes.
- Optional lesson goal/topic selector before lesson generation.
- Profile edit screen under Account or Settings.
- Default profile context injected into matching and generation requests.

## Functional Requirements

| ID         | Requirement                                                                     |
| ---------- | ------------------------------------------------------------------------------- |
| PROFILE-01 | Teacher can enter school name or select an existing pilot organization.         |
| PROFILE-02 | Teacher can enter subject, grade band, and common class labels.                 |
| PROFILE-03 | Teacher can enter optional teaching constraints or notes.                       |
| PROFILE-04 | Teacher can select lesson topic or objective before generating a lesson.        |
| PROFILE-05 | System stores teacher profile and uses it as default AI context.                |
| PROFILE-06 | Teacher can edit profile after onboarding.                                      |
| PROFILE-07 | App indicates when profile context is missing but does not block scan creation. |
| PROFILE-08 | Lesson generation requires enough context to determine grade band and subject.  |

## Core Flow

1. Teacher signs in for the first time.
2. App detects missing teacher profile.
3. Teacher completes school, subject, grade band, and class context.
4. Profile is saved to API.
5. Teacher starts a scan or lesson flow.
6. App pre-fills generation context from profile.
7. Teacher can override topic/objective for the current lesson.

## Data Model

Primary entities:

- `TeacherProfile`: subject, grade band, classes, default context.
- `Organization`: school or pilot institution.
- `OrganizationMember`: teacher membership and role.
- `CurriculumStandard`: later mapping for grade, subject, and topic.

Key fields:

- `TeacherProfile.userId`
- `TeacherProfile.organizationId`
- `TeacherProfile.subjects`
- `TeacherProfile.gradeBands`
- `TeacherProfile.defaultClassLabels`
- `TeacherProfile.teachingNotes`

## API Contract

Candidate endpoints:

- `GET /users/me/profile`
- `PUT /users/me/profile`
- `GET /organizations/search`
- `POST /organizations/request`

Request requirements:

- Validate grade band and subject against supported values where configured.
- Allow free-text school name during pilot if organization does not exist.
- Return onboarding completeness flags to clients.

## UX Requirements

- Onboarding must be short and skippable only when safe.
- Missing profile context should be visible near generation actions.
- Forms use calm, utilitarian design with direct labels and no marketing copy.
- Teacher can edit profile from Account without losing saved lessons.

## Safety And Quality

- Do not let profile data silently override explicit lesson-specific choices.
- Lesson generation must record the profile context used for each generated lesson.
- Store school and profile data as private tenant-scoped data.

## Analytics

Track:

- `profile_onboarding_started`
- `profile_completed`
- `profile_updated`
- `lesson_context_selected`

## Acceptance Criteria

- New teacher can complete onboarding and reach scan flow.
- Existing teacher can edit school, subject, grade band, and class labels.
- Lesson generation request includes profile-derived subject and grade band.
- Teacher can override topic/objective for one lesson without changing saved profile.
- Missing required profile fields trigger actionable validation errors.

## Open Questions

- Which subject taxonomy is required for MVP: free text, fixed STEM list, or GDPT 2018-aligned list?
- Should grade bands be `THCS`, `THPT`, and exact grades, or exact grades only?
- Should pilot organizations be pre-created by admin or self-created by first teacher signup?
