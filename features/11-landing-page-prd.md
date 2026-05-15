# PRD - FRS-11 Landing Page

## Status

Draft for MVP planning.

## Source Docs

- `docs/macgyver-classroom-frs.md` - FRS-11
- `docs/macgyver-classroom-prd.md` - Landing page MVP
- `docs/macgyver-classroom-brd.md` - Pilot lead and business goals
- `docs/macgyver-classroom-design-system.md` - Landing design direction

## Problem

The business needs pilot schools and early teacher feedback. The landing page must explain the product quickly, show the photo-to-lesson workflow, address safety/data concerns, and capture qualified pilot leads.

## Goals

- Present a clear one-liner and pilot CTA.
- Explain the 4-step pipeline: photos, vision catalog, experiment match, lesson plan.
- Show a concrete demo case from materials to experiment to lesson.
- Capture lead information.
- Store leads and notify internally if configured.
- Answer FAQ about safety, image data, and GDPT 2018 alignment.

## Non-Goals

- Public self-service purchase in MVP.
- Full marketing CMS.
- Blog, resource center, or SEO content library.
- Public account creation from landing unless product auth flow is ready.

## Primary Users

- School leader: evaluates pilot fit.
- STEM/Vat ly/Cong nghe teacher: understands classroom value.
- Internal operator: follows up with qualified leads.

## User Stories

- As a school leader, I can quickly understand what MacGyver Classroom does.
- As a teacher, I can see how classroom objects become experiment ideas and lesson plans.
- As a pilot prospect, I can submit my contact information.
- As an internal operator, I can receive and track pilot leads.
- As a cautious school stakeholder, I can read safety and data handling answers.

## MVP Scope

- One-liner and primary CTA.
- 4-step product pipeline section.
- Demo case section: materials -> experiment -> lesson plan.
- Pilot lead form with name, school, role, email or phone, and notes.
- Lead persistence in database.
- Optional internal notification if configured.
- FAQ for safety, image data, and GDPT 2018.
- Basic analytics events.

## Functional Requirements

| ID         | Requirement                                                          |
| ---------- | -------------------------------------------------------------------- |
| LANDING-01 | Landing page displays one-liner and pilot signup CTA above the fold. |
| LANDING-02 | Landing page explains the 4-step product pipeline.                   |
| LANDING-03 | Landing page shows demo case from materials to experiment to lesson. |
| LANDING-04 | Lead form captures name, school, role, email or phone, and notes.    |
| LANDING-05 | Lead submission is saved to database.                                |
| LANDING-06 | Lead submission sends internal notification when configured.         |
| LANDING-07 | Landing page includes FAQ about safety, image data, and GDPT 2018.   |
| LANDING-08 | Lead form validates required fields and rate limits submission.      |
| LANDING-09 | Page supports accessible responsive layout.                          |

## Core Flow

1. Visitor opens landing page.
2. Visitor reads one-liner and product promise.
3. Visitor inspects pipeline and demo case.
4. Visitor opens pilot CTA.
5. Visitor submits lead form.
6. API validates and stores lead.
7. Page shows success state.
8. Internal notification is sent if configured.
9. Lead appears in Content Admin lead queue.

## Content Requirements

Landing content must cover:

- Product name: MacGyver Classroom.
- Audience: STEM/Vat ly/Cong nghe teachers and pilot schools.
- Core promise: turn available classroom objects/photos into safe experiment ideas and 45-minute lesson plans.
- Workflow: photo -> detected inventory -> curated experiment match -> editable lesson plan.
- Safety posture: teacher remains reviewer, safety notes included, risky content blocked.
- Data posture: classroom photos are private and used for analysis.
- Curriculum posture: lesson plans can align to GDPT 2018 metadata.

## Data Model

Primary entities:

- `Lead`: submitted pilot lead.
- `LeadEvent`: follow-up and status changes.
- `AnalyticsEvent`: page and form events.

Key fields:

- `Lead.name`
- `Lead.school`
- `Lead.role`
- `Lead.email`
- `Lead.phone`
- `Lead.notes`
- `Lead.source`
- `Lead.status`
- `Lead.createdAt`

## API Contract

Candidate endpoints:

- `POST /leads`
- `GET /admin/leads`
- `PATCH /admin/leads/:id`

Lead request:

- `name`: required.
- `school`: required.
- `role`: required.
- `email` or `phone`: at least one required.
- `notes`: optional.

Response requirements:

- Return success without exposing internal notification status details.
- Use validation errors for missing fields.
- Rate limit submissions.

## UX Requirements

- Build the actual landing experience, not a placeholder.
- Hero must make product/category clear in first viewport.
- Demo should show actual product state or realistic material-to-lesson content.
- Lead form must be short and scannable.
- FAQ must answer safety and privacy concerns directly.
- Use design system direction: white + ocean blue, calm classroom surface, evidence over magic.

## Safety And Privacy

- Do not request student personal data.
- Lead form should disclose how contact information is used for pilot follow-up.
- Apply spam/rate limiting.
- Do not leak lead details in client logs.

## Analytics

Track:

- `landing_viewed`
- `landing_cta_clicked`
- `landing_demo_viewed`
- `lead_form_started`
- `lead_submitted`
- `lead_submit_failed`

## Acceptance Criteria

- Visitor can understand product value without signing in.
- Page explains the 4-step pipeline and shows a demo case.
- Lead form saves valid submissions.
- Invalid form submission shows field-level errors.
- Lead appears in admin lead queue.
- FAQ covers safety, image data, and GDPT 2018.
- Submission is rate limited.

## Open Questions

- Which internal notification channel should MVP use: email, Slack, or no notification?
- What exact demo case should be used for first pilot landing page?
- Should landing page be deployed from `apps/landing` or `apps/web`?
