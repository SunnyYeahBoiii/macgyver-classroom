# Feature PRDs - MacGyver Classroom

This folder breaks the product docs into one PRD per feature area.

Sources:

- `docs/macgyver-classroom-prd.md`
- `docs/macgyver-classroom-frs.md`
- `docs/macgyver-classroom-srs.md`
- `docs/macgyver-classroom-brd.md`
- `docs/macgyver-classroom-system-design.md`
- `docs/macgyver-classroom-design-system.md`

## Feature PRD Index

| Feature                                 | PRD                                                                                  |
| --------------------------------------- | ------------------------------------------------------------------------------------ |
| FRS-01 Authentication & Account         | [01-authentication-account-prd.md](01-authentication-account-prd.md)                 |
| FRS-02 Teacher Profile & School Context | [02-teacher-profile-school-context-prd.md](02-teacher-profile-school-context-prd.md) |
| FRS-03 Vision Catalog                   | [03-vision-catalog-prd.md](03-vision-catalog-prd.md)                                 |
| FRS-04 Property Mapping                 | [04-property-mapping-prd.md](04-property-mapping-prd.md)                             |
| FRS-05 Experiment Matching              | [05-experiment-matching-prd.md](05-experiment-matching-prd.md)                       |
| FRS-06 Lesson Plan Generation           | [06-lesson-plan-generation-prd.md](06-lesson-plan-generation-prd.md)                 |
| FRS-07 Lesson Library                   | [07-lesson-library-prd.md](07-lesson-library-prd.md)                                 |
| FRS-08 Export & Sharing                 | [08-export-sharing-prd.md](08-export-sharing-prd.md)                                 |
| FRS-09 Safety & Quality Guardrails      | [09-safety-quality-guardrails-prd.md](09-safety-quality-guardrails-prd.md)           |
| FRS-10 Content Admin                    | [10-content-admin-prd.md](10-content-admin-prd.md)                                   |
| FRS-11 Landing Page                     | [11-landing-page-prd.md](11-landing-page-prd.md)                                     |
| FRS-12 Analytics & Feedback             | [12-analytics-feedback-prd.md](12-analytics-feedback-prd.md)                         |

## Product Principles Applied Across Features

- Teacher-first utility: the primary flow must reduce lesson preparation time for STEM teachers.
- Evidence over magic: AI output must show detected evidence, confidence, missing assumptions, and safety notes.
- Safety-first generation: experiments and exports cannot bypass safety policy.
- Editable, not final: teachers remain the final reviewer and can correct inventory, lesson text, and metadata.
- Pilot-ready metrics: core events must support pilot school usage, lesson generation, export, and feedback reporting.

## MVP Feature Dependency Order

1. Authentication & Account
2. Teacher Profile & School Context
3. Vision Catalog
4. Property Mapping
5. Safety & Quality Guardrails
6. Experiment Matching
7. Lesson Plan Generation
8. Lesson Library
9. Export & Sharing
10. Analytics & Feedback
11. Landing Page
12. Content Admin
