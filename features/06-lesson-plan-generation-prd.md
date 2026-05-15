# PRD - FRS-06 Lesson Plan Generation

## Status

Draft for MVP planning.

## Source Docs

- `docs/macgyver-classroom-frs.md` - FRS-06
- `docs/macgyver-classroom-prd.md` - 45-minute lesson plan MVP
- `docs/macgyver-classroom-srs.md` - Lesson endpoints and AI pipeline
- `docs/macgyver-classroom-system-design.md` - Lesson Plan response contract

## Problem

Experiment suggestions only become classroom value when teachers can turn them into a structured, safe, grade-appropriate lesson plan. The product must generate editable 45-minute lesson plans based on curated experiment templates, teacher context, confirmed inventory, and safety rules.

## Goals

- Generate a structured 45-minute lesson plan from a selected experiment.
- Include title, objectives, GDPT 2018 relation, materials, preparation, flow, guiding questions, assessment, and safety notes.
- Use a structured template, not free-form prompt-only output.
- Let teachers edit and save multiple versions.
- Record the experiment template and inventory used for traceability.

## Non-Goals

- Full semester lesson planning.
- Student worksheet generation in MVP.
- Automatic slide deck generation.
- Unreviewed AI-generated experiments outside curated templates.

## Primary Users

- Teacher: generates, edits, saves, exports, and reuses lesson plans.

## User Stories

- As a teacher, I can select an experiment and generate a 45-minute plan.
- As a teacher, I can see objectives, materials, flow, questions, assessment, and safety notes in one editable structure.
- As a teacher, I can edit the plan to fit my class.
- As a teacher, I can save more than one version.
- As a teacher, I can trace which inventory and experiment created the lesson.

## MVP Scope

- Generate lesson from selected `ExperimentMatch`.
- Structured generation contract with schema validation.
- Editable lesson plan screen.
- Save current version.
- Save additional versions.
- Store source experiment template, inventory snapshot, teacher profile context, prompt/model version, and safety checks.

## Functional Requirements

| ID        | Requirement                                                                                                                                            |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| LESSON-01 | Teacher can generate a 45-minute lesson from a selected experiment.                                                                                    |
| LESSON-02 | Generated lesson includes title, objectives, GDPT 2018 relation, materials, preparation, lesson flow, guiding questions, assessment, and safety notes. |
| LESSON-03 | Generation uses a structured template and schema validation.                                                                                           |
| LESSON-04 | Teacher can edit generated lesson content.                                                                                                             |
| LESSON-05 | Teacher can save multiple lesson versions.                                                                                                             |
| LESSON-06 | System records experiment template and inventory snapshot used for generation.                                                                         |
| LESSON-07 | System records teacher profile context used for generation.                                                                                            |
| LESSON-08 | System requires safety notes and teacher checks in every generated lesson.                                                                             |

## Core Flow

1. Teacher selects an experiment suggestion.
2. App shows generation context: grade, subject, topic, materials, duration.
3. Teacher confirms or adjusts context.
4. API calls lesson generation pipeline.
5. Model-api returns structured lesson JSON.
6. API validates schema and safety requirements.
7. App displays editable lesson plan.
8. Teacher edits and saves.
9. Lesson is available in Lesson Library and Export flows.

## AI Contract

Expected Lesson Plan response:

```json
{
  "title": "Thí nghiệm áp suất không khí bằng chai nhựa",
  "duration_minutes": 45,
  "grade_band": "THCS",
  "objectives": [],
  "materials": [],
  "lesson_flow": [],
  "guiding_questions": [],
  "assessment": [],
  "safety_notes": [],
  "teacher_checks_required": []
}
```

Validation:

- Response must parse as JSON.
- Duration must default to 45 minutes for MVP.
- Safety notes cannot be empty.
- Teacher checks cannot be empty.
- Materials cannot include unsafe or unapproved additions.
- Output must reference selected experiment template and confirmed inventory.

## Data Model

Primary entities:

- `LessonPlan`: saved lesson.
- `LessonPlanVersion`: versioned editable content.
- `ExperimentTemplate`: source experiment.
- `ExperimentMatch`: selected match.
- `InventoryScan`: source inventory snapshot.
- `AiRun`: AI generation metadata.
- `SafetyCheckResult`: safety validation.

Key fields:

- `LessonPlan.userId`
- `LessonPlan.organizationId`
- `LessonPlan.experimentTemplateId`
- `LessonPlan.inventoryScanId`
- `LessonPlan.title`
- `LessonPlan.status`
- `LessonPlanVersion.contentJson`
- `LessonPlanVersion.versionNumber`
- `LessonPlanVersion.createdByUserId`

## API Contract

Candidate endpoints:

- `POST /lessons/generate`
- `GET /lessons/:id`
- `PATCH /lessons/:id`
- `POST /lessons/:id/versions`
- `GET /lessons/:id/versions`

Request requirements:

- `experimentMatchId`
- `teacherProfileContext`
- `lessonTopic` or selected curriculum topic
- Optional teacher notes

Response requirements:

- Return saved draft lesson ID.
- Return validated structured content.
- Return warnings if generation required fallback or normalization.

## UX Requirements

- Show generation progress and retry option.
- Display lesson sections in an editable, structured editor.
- Safety notes and teacher checks remain visible near export actions.
- Teacher can save without exporting.
- Teacher can duplicate via Lesson Library for another class.

## Safety And Quality

- Generation cannot bypass Experiment Matching safety filter.
- Every generated lesson must include safety notes and teacher checks.
- Teacher must review before export.
- Provider errors must be normalized and non-leaky.

## Analytics

Track:

- `lesson_generation_started`
- `lesson_generated`
- `lesson_generation_failed`
- `lesson_edited`
- `lesson_version_saved`

## Acceptance Criteria

- Teacher can generate a structured 45-minute lesson from a selected match.
- Generated lesson includes all required sections.
- Invalid AI JSON fails validation with recoverable error.
- Teacher can edit and save at least two versions.
- Lesson stores source experiment, inventory, context, and safety result.
- Every generated lesson includes safety notes and teacher checks.

## Open Questions

- What exact GDPT 2018 metadata must appear in MVP lesson output?
- Should lesson versions support side-by-side diff in MVP or only history list?
- Should AI generation happen synchronously for MVP or through a background job?
