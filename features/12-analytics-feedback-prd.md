# PRD - FRS-12 Analytics & Feedback

## Status

Draft for MVP planning.

## Source Docs

- `docs/macgyver-classroom-frs.md` - FRS-12
- `docs/macgyver-classroom-prd.md` - Product and business success metrics
- `docs/macgyver-classroom-brd.md` - Pilot KPIs
- `docs/macgyver-classroom-system-design.md` - Observability and analytics module

## Problem

Pilot success depends on evidence: scans created, inventories confirmed, experiments selected, lessons generated, lessons exported, teacher feedback, and school-level usage. Without analytics and feedback, the team cannot validate product value, improve templates, or prove pilot adoption.

## Goals

- Record core product events across the teacher workflow.
- Let teachers rate AI/lesson results after generation.
- Store feedback for content improvement.
- Let School Admin view aggregate lesson creation counts over time.
- Support pilot metrics: schools, teachers, generated lessons, exported lessons, and qualitative feedback.

## Non-Goals

- Advanced BI dashboard in MVP.
- Individual teacher performance scoring.
- Student outcome analytics.
- Third-party analytics dependency as the only source of truth.

## Primary Users

- Teacher: rates generated lesson quality and reports issues.
- School Admin: views aggregate usage.
- Content Admin: reviews feedback to improve templates.
- Product team/internal operator: evaluates pilot KPIs.

## User Stories

- As a teacher, I can rate a generated lesson so the team can improve future results.
- As a teacher, I can report incorrect, unsafe, or low-quality content.
- As a school admin, I can see how many lessons teachers created over a period.
- As a content admin, I can review feedback tied to templates and AI runs.
- As the product team, I can measure scan-to-export funnel performance.

## MVP Scope

- Event tracking for core workflow events.
- Teacher rating after lesson generation.
- Feedback text and report type capture.
- Feedback storage linked to lesson, experiment, inventory, and AI run where relevant.
- School Admin aggregate lesson count by date range.
- Admin review queue for feedback.

## Functional Requirements

| ID           | Requirement                                                                   |
| ------------ | ----------------------------------------------------------------------------- |
| ANALYTICS-01 | System records `scan_created`.                                                |
| ANALYTICS-02 | System records `inventory_confirmed`.                                         |
| ANALYTICS-03 | System records `experiment_selected`.                                         |
| ANALYTICS-04 | System records `lesson_generated`.                                            |
| ANALYTICS-05 | System records `lesson_exported`.                                             |
| ANALYTICS-06 | Teacher can rate AI result after each generated lesson.                       |
| ANALYTICS-07 | Teacher can submit feedback text and report type.                             |
| ANALYTICS-08 | Feedback is stored for content improvement.                                   |
| ANALYTICS-09 | School Admin can view number of lessons generated over a selected period.     |
| ANALYTICS-10 | Analytics events avoid sensitive raw image, token, and private note payloads. |

## Core Flow

1. Teacher creates scan.
2. System records scan event.
3. Teacher confirms inventory.
4. System records confirmation event.
5. Teacher selects experiment.
6. System records selection event.
7. Teacher generates lesson.
8. System records generation event and prompts for optional rating.
9. Teacher exports lesson.
10. System records export event.
11. School Admin views aggregate usage.
12. Content Admin reviews feedback queue.

## Data Model

Primary entities:

- `AnalyticsEvent`: structured product event.
- `Feedback`: rating, report, and comments.
- `LessonPlan`: feedback target.
- `ExperimentTemplate`: content target.
- `AiRun`: AI output target.
- `Organization`: school-level aggregate scope.

Key fields:

- `AnalyticsEvent.eventName`
- `AnalyticsEvent.userId`
- `AnalyticsEvent.organizationId`
- `AnalyticsEvent.entityType`
- `AnalyticsEvent.entityId`
- `AnalyticsEvent.properties`
- `AnalyticsEvent.createdAt`
- `Feedback.rating`
- `Feedback.reportType`
- `Feedback.comment`
- `Feedback.status`

## API Contract

Candidate endpoints:

- `POST /analytics/events`
- `POST /feedback`
- `GET /admin/feedback`
- `PATCH /admin/feedback/:id`
- `GET /organizations/:id/analytics/lesson-counts`

Response requirements:

- Event ingestion should be idempotent or tolerate retries.
- School Admin metrics return aggregate counts only.
- Feedback list supports filters, status, pagination, and sort.

## Event Taxonomy

Required MVP events:

- `scan_created`
- `inventory_confirmed`
- `experiment_selected`
- `lesson_generated`
- `lesson_exported`

Recommended supporting events:

- `scan_analysis_failed`
- `detected_item_corrected`
- `experiment_no_match`
- `lesson_generation_failed`
- `lesson_rating_submitted`
- `content_report_submitted`
- `lead_submitted`

## UX Requirements

- Rating prompt appears after successful lesson generation and does not block editing.
- Report action remains available from lesson and experiment surfaces.
- School Admin dashboard is aggregate and simple: date range plus lesson count.
- Content Admin feedback queue links feedback to lesson, experiment, and AI metadata where available.

## Safety And Privacy

- Do not store raw classroom image data inside analytics event properties.
- Do not store passwords, tokens, OAuth identifiers, or full exported lesson body in analytics events.
- School Admin reports are aggregate by organization and date range.
- Feedback with safety report should be visible to Content Admin review queue.

## Success Metrics

Product metrics:

- Number of scans created.
- Number of inventories confirmed.
- Number of experiments selected.
- Number of lessons generated.
- Number of lessons exported.
- Teacher rating average and feedback count.

Business pilot metrics:

- 10 pilot school registrations.
- 3 pilot schools active with at least 5 teachers each.
- At least 30 lesson plans generated and used during pilot.
- At least 5 qualitative feedback items about preparation-time savings.

## Acceptance Criteria

- Required workflow events are recorded with user, organization, entity, and timestamp.
- Teacher can rate a generated lesson.
- Teacher feedback is persisted and appears in admin feedback queue.
- School Admin can view lesson count by date range.
- Analytics payloads exclude sensitive raw data.
- Event tracking failure does not block core teacher workflow unless explicitly required.

## Open Questions

- Should MVP use first-party database analytics only, or also forward to an external analytics provider?
- How should "lesson used in class" be captured: explicit teacher checkbox, export proxy, or follow-up survey?
- What minimum School Admin dashboard is needed for pilot reporting?
