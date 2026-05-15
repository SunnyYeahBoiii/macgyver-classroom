# Phong - Backend AI Tasks

## Scope

Owner: Phong

Role: Backend AI modules, model integration, scan analysis, matching logic, safety guardrails, lesson generation, AI observability.

Primary source docs:

- `features/03-vision-catalog-prd.md`
- `features/04-property-mapping-prd.md`
- `features/05-experiment-matching-prd.md`
- `features/06-lesson-plan-generation-prd.md`
- `features/09-safety-quality-guardrails-prd.md`
- `features/10-content-admin-prd.md`
- `features/12-analytics-feedback-prd.md`

Do not edit `CITYFARM-2.0/` unless the task explicitly changes legacy/reference material.

## AI Backend Responsibilities

- Keep AI output structured, validated, explainable, and safety-gated.
- Log AI runs, prompt versions, model/provider metadata, latency, and failures.
- Expose deterministic fallback behavior for demos and tests.
- Coordinate storage contracts with Thinh instead of duplicating CRUD ownership.

## PHONG-01 - AI Run Logging, Prompt Versions, And Model Client

Type: AFK

Parent:

- `features/06-lesson-plan-generation-prd.md`
- `features/10-content-admin-prd.md`

What to build:

Stabilize the AI module foundation: model API client, prompt version registry, AI run logging, retry/error handling, and admin-readable metadata.

Acceptance criteria:

- [ ] Model client has clear provider boundary and typed request/response contracts.
- [ ] Prompt versions can be created/read/listed and referenced by AI runs.
- [ ] AI run logs include purpose, prompt version, provider/model, status, latency, token/cost metadata where available, and error summary.
- [ ] Failure responses are safe for UI display and do not leak secrets.
- [ ] Tests cover success, provider error, schema error, timeout, and logged metadata.

Blocked by:

- `THINH-01 - API Foundation, Auth Guards, And Validation`

## PHONG-02 - Vision Scan Analysis Pipeline

Type: AFK

Parent:

- `features/03-vision-catalog-prd.md`

What to build:

Build the AI pipeline that turns uploaded classroom images into detected inventory candidates with confidence, evidence, and review-ready output.

Acceptance criteria:

- [ ] Pipeline accepts scan/image references from the inventory API.
- [ ] Output includes detected label, normalized label when possible, confidence, evidence, and uncertainty notes.
- [ ] Low-confidence results are clearly marked for teacher review.
- [ ] Pipeline updates scan status through pending, analyzing, completed, and failed states.
- [ ] Failures are logged as AI runs and exposed to UI as retryable/non-retryable where possible.
- [ ] Fixture-based tests cover realistic classroom objects, empty images, low confidence, and provider failure.
- [ ] Scan-analysis events align with the analytics event taxonomy for started, failed, completed, and safety-flagged runs.

Blocked by:

- `PHONG-01 - AI Run Logging, Prompt Versions, And Model Client`
- `THINH-04 - Inventory Scan, Confirmed Item, And Asset APIs` for scan/image storage contract.

## PHONG-03 - Canonical Material Mapping And Reasoning Helper

Type: AFK

Parent:

- `features/04-property-mapping-prd.md`

What to build:

Build mapping logic that connects teacher-confirmed items to canonical materials, STEM properties, alternatives, and teacher-facing reasoning.

Acceptance criteria:

- [ ] Confirmed item can map to one canonical material where possible.
- [ ] Mapping result includes material properties and teacher-facing reasoning.
- [ ] Alias matching supports raw detected labels and teacher-corrected labels.
- [ ] Safe alternatives are returned for simple missing materials.
- [ ] Disabled materials/mappings are excluded from teacher-facing output.
- [ ] Tests cover exact alias, fuzzy/normalized label, no match, disabled mapping, and alternative suggestion.

Blocked by:

- `THINH-03 - Material, Property, Experiment, And Curriculum CRUD APIs`
- `THINH-04 - Inventory Scan, Confirmed Item, And Asset APIs`

## PHONG-04 - Safety Guardrails Engine

Type: AFK

Parent:

- `features/09-safety-quality-guardrails-prd.md`

What to build:

Build the safety gate used by matching, lesson generation, export, and admin disable workflows.

Acceptance criteria:

- [ ] Experiments/materials can be classified as allowed, caution, teacher-check-required, or blocked.
- [ ] Blocked experiments cannot be suggested, generated, or exported as usable lessons.
- [ ] Safety result includes reason, teacher check text, and required warnings.
- [ ] Safety result can be attached to unsafe/inappropriate content reports for admin review.
- [ ] Guardrails run before matching output and after lesson generation output validation.
- [ ] Admin-disabled content immediately affects teacher-facing suggestions.
- [ ] Tests cover blocked materials, missing teacher checks, disabled experiment, generated unsafe text, and safe path.

Blocked by:

- `PHONG-03 - Canonical Material Mapping And Reasoning Helper`
- `THINH-07 - Content Admin Audit, Review Queues, And Status Transitions` for admin disable/status contracts.

## PHONG-05 - Experiment Matching Engine

Type: AFK

Parent:

- `features/05-experiment-matching-prd.md`

What to build:

Build matching logic that recommends curated experiments using confirmed inventory, mapped material properties, teacher profile/context, missing materials, alternatives, and safety gates.

Acceptance criteria:

- [ ] Matching accepts confirmed inventory, teacher profile, grade, subject, topic, and optional filters.
- [ ] Result includes title, grade/subject/topic, duration, difficulty, available/missing materials, alternatives, safety category, and reasoning.
- [ ] Results are ranked by material fit, curriculum fit, and safety.
- [ ] Disabled or unsafe experiments are excluded.
- [ ] Empty result includes actionable reason for UI.
- [ ] Tests cover strong match, partial match with alternatives, no match, unsafe exclusion, and filter behavior.

Blocked by:

- `PHONG-03 - Canonical Material Mapping And Reasoning Helper`
- `PHONG-04 - Safety Guardrails Engine`
- `THINH-03 - Material, Property, Experiment, And Curriculum CRUD APIs`

## PHONG-06 - Lesson Generation Pipeline

Type: AFK

Parent:

- `features/06-lesson-plan-generation-prd.md`

What to build:

Build the structured lesson generation pipeline from selected experiment and teacher context to validated editable lesson JSON.

Acceptance criteria:

- [ ] Generation request includes experiment, inventory, grade, subject, topic, duration, objectives, and teacher profile context.
- [ ] Model output is validated against a structured schema before persistence.
- [ ] Lesson JSON includes title, objectives, materials/prep, lesson flow, guiding questions, assessment, safety notes, and teacher checks.
- [ ] Safety guardrails run on generated output before the lesson is returned as usable.
- [ ] Schema failure, safety failure, and provider failure return clear machine-readable statuses.
- [ ] Tests cover valid generation, malformed JSON, missing safety notes, unsafe output, and deterministic fixture mode.

Blocked by:

- `PHONG-01 - AI Run Logging, Prompt Versions, And Model Client`
- `PHONG-04 - Safety Guardrails Engine`
- `PHONG-05 - Experiment Matching Engine`
- `THINH-05 - Lesson Library, Versioning, Export, And Share APIs` for persistence contract.

## PHONG-07 - AI Observability, Evaluation Fixtures, And Fallbacks

Type: AFK

Parent:

- `features/09-safety-quality-guardrails-prd.md`
- `features/12-analytics-feedback-prd.md`

What to build:

Add eval fixtures, deterministic demo mode, observability hooks, and feedback loops for AI quality and safety review.

Acceptance criteria:

- [ ] Fixture set covers at least one complete demo path: image input, detected items, matched experiment, generated lesson.
- [ ] Deterministic mode can run without external model calls for local tests/demos.
- [ ] AI events integrate with analytics for scan analysis, matching, generation, failure, and safety block.
- [ ] Feedback records can reference lesson, experiment, prompt version, and AI run where available.
- [ ] Rating, qualitative feedback, and unsafe report events can be correlated back to prompt version and AI run where available.
- [ ] Content Admin can inspect AI run metadata needed for review without seeing secrets.
- [ ] Tests or scripts verify the fixture path end to end.

Blocked by:

- `PHONG-02 - Vision Scan Analysis Pipeline`
- `PHONG-05 - Experiment Matching Engine`
- `PHONG-06 - Lesson Generation Pipeline`
- `THINH-06 - Leads, Feedback, Analytics, And School Metrics APIs`
