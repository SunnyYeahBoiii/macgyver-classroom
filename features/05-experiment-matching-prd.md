# PRD - FRS-05 Experiment Matching

## Status

Draft for MVP planning.

## Source Docs

- `docs/macgyver-classroom-frs.md` - FRS-05
- `docs/macgyver-classroom-prd.md` - Core workflow and MVP goal of 5 suggestions
- `docs/macgyver-classroom-system-design.md` - Experiment Matching and materials architecture

## Problem

After inventory confirmation, teachers need actionable experiment ideas that fit available materials, class level, subject, time, and safety constraints. Generic AI brainstorming is not enough; suggestions must come from curated templates and explain feasibility.

## Goals

- Match confirmed inventory against curated experiment templates.
- Return up to 5 high-feasibility suggestions.
- Show available materials, missing materials, alternatives, difficulty, duration, grade, subject, and topic.
- Filter out unsafe or disabled experiments.
- Support filters for grade, subject, topic, duration, and difficulty.

## Non-Goals

- Fully open-ended AI-generated experiments outside curated templates in MVP.
- Marketplace or community-submitted experiments.
- Advanced timetable scheduling.
- Procurement recommendations for missing materials.

## Primary Users

- Teacher: chooses an experiment to turn into a lesson plan.
- Content Admin: curates templates, requirements, curriculum mapping, and safety status.

## User Stories

- As a teacher, I can see the top 5 experiments I can run with current materials.
- As a teacher, I can understand what I already have and what is missing.
- As a teacher, I can filter suggestions by class level, subject, topic, time, and difficulty.
- As a teacher, I do not see experiments that violate safety policy.
- As a teacher, I can choose one experiment and generate a 45-minute lesson plan.

## MVP Scope

- Curated `ExperimentTemplate` database.
- Material requirements per experiment.
- Matching score based on confirmed items, material properties, missing materials, safe alternatives, duration, difficulty, and teacher context.
- Up to 5 ranked suggestions.
- Filters for grade, subject, topic, duration, and difficulty.
- Safety exclusion before suggestions are shown.
- Persisted match result linked to inventory scan.

## Functional Requirements

| ID       | Requirement                                                                                                                       |
| -------- | --------------------------------------------------------------------------------------------------------------------------------- |
| MATCH-01 | System matches confirmed inventory with curated experiment templates.                                                             |
| MATCH-02 | System returns at most 5 ranked suggestions by feasibility.                                                                       |
| MATCH-03 | Each suggestion shows available materials, missing materials, safe alternatives, difficulty, duration, grade, subject, and topic. |
| MATCH-04 | System excludes experiments blocked by safety policy or disabled content status.                                                  |
| MATCH-05 | Teacher can filter by grade, subject, topic, duration, and difficulty.                                                            |
| MATCH-06 | System suggests safe alternatives when 1-2 simple materials are missing.                                                          |
| MATCH-07 | System records match result and selected experiment for lesson generation.                                                        |
| MATCH-08 | Suggestions include explanation of why the experiment matched.                                                                    |

## Core Flow

1. Teacher confirms inventory.
2. App requests experiment suggestions.
3. API resolves materials and properties.
4. Matching engine evaluates curated templates.
5. Safety guardrails remove blocked templates.
6. API returns ranked suggestions.
7. Teacher filters or inspects details.
8. Teacher selects one experiment.
9. Selected match becomes input for Lesson Plan Generation.

## Data Model

Primary entities:

- `ConfirmedItem`: teacher-approved available materials.
- `Material`: canonical materials.
- `ExperimentTemplate`: curated experiment definition.
- `ExperimentMaterialRequirement`: required and optional materials.
- `ExperimentCurriculumMapping`: grade, subject, and topic alignment.
- `ExperimentMatch`: stored match result.
- `SafetyCheckResult`: safety evaluation.

Key fields:

- `ExperimentTemplate.status`
- `ExperimentTemplate.title`
- `ExperimentTemplate.durationMinutes`
- `ExperimentTemplate.difficulty`
- `ExperimentMaterialRequirement.materialId`
- `ExperimentMaterialRequirement.requiredQuantity`
- `ExperimentMatch.score`
- `ExperimentMatch.availableMaterials`
- `ExperimentMatch.missingMaterials`
- `ExperimentMatch.alternatives`
- `ExperimentMatch.explanation`

## Matching Rules

- Required materials weigh more than optional materials.
- Teacher-confirmed quantities override AI estimates.
- Missing 1-2 simple materials may still match if safe alternatives exist.
- Disabled templates, denied materials, or unsafe combinations return no suggestion.
- Teacher profile and selected topic boost relevant curriculum mappings.
- A lower-score safe suggestion ranks above a higher-score unsafe suggestion because unsafe suggestions are excluded.

## API Contract

Candidate endpoints:

- `GET /experiments/suggestions?inventoryScanId=...`
- `POST /experiments/match`
- `GET /experiments/:id`
- `POST /experiments/:id/select`

Response requirements:

- Return stable match ID.
- Return score and human-readable explanation.
- Return available, missing, alternative, and safety note lists.
- Return filter metadata for UI.

## UX Requirements

- Suggestion cards show title, grade/subject/topic, duration, difficulty, available/missing material summary, and safety category.
- Details screen shows reasoning and safety notes before lesson generation.
- Filters must not hide all results without clear empty state.
- Teacher can go back to edit inventory if suggestions are poor.

## Safety And Quality

- Matching must call safety policy before returning results.
- Experiment templates must be curated and published.
- AI cannot invent new experiment steps in matching.
- Missing material alternatives must be reviewed as safe.

## Analytics

Track:

- `experiment_suggestions_requested`
- `experiment_suggestions_returned`
- `experiment_filter_applied`
- `experiment_selected`
- `experiment_no_match`

## Acceptance Criteria

- Confirmed inventory returns up to 5 ranked curated experiment suggestions.
- Each suggestion lists have/missing materials and explains why it matched.
- Teacher filters work for grade, subject, topic, duration, and difficulty.
- Safety-blocked experiments never appear.
- Selected experiment is persisted for lesson generation.
- No-match state gives teacher next actions: edit inventory, change filters, or try another scan.

## Open Questions

- What scoring weights should MVP use for required material coverage, alternatives, teacher context, and difficulty?
- What minimum curated experiment count is required before pilot?
- Should teachers be allowed to request "show harder experiments" when default results are too simple?
