# PRD - FRS-04 Property Mapping

## Status

Draft for MVP planning.

## Source Docs

- `docs/macgyver-classroom-frs.md` - FRS-04
- `docs/macgyver-classroom-srs.md` - Materials and property mapping
- `docs/macgyver-classroom-system-design.md` - Materials module and admin curation

## Problem

Detected classroom objects are not enough to suggest experiments. The system needs to understand each material's STEM properties, safe alternatives, curriculum relevance, and why it can support a specific experiment.

## Goals

- Map confirmed items to canonical materials.
- Map canonical materials to STEM properties.
- Explain why an item is useful for an experiment.
- Let Content Admin manage material-property mappings.
- Support safe alternatives for missing simple materials.

## Non-Goals

- Automated creation of unreviewed canonical materials in MVP.
- Full chemical safety database.
- Inventory procurement or purchasing recommendations.
- Student-facing material encyclopedia.

## Primary Users

- Teacher: sees why a detected item can support a suggested experiment.
- Content Admin: curates materials, aliases, properties, and alternatives.

## User Stories

- As a teacher, I can understand why a plastic bottle maps to pressure or buoyancy experiments.
- As a teacher, I can trust suggestions because the system shows material reasoning.
- As a content admin, I can add material aliases and property mappings without code changes.
- As a content admin, I can define safe alternatives for common missing materials.

## MVP Scope

- Canonical material catalog.
- Material aliases for detected labels and Vietnamese classroom names.
- Material property mapping.
- Admin-managed mapping table.
- Teacher-facing reasoning text in experiment suggestions.
- Safe-alternative mapping used by Experiment Matching.

## Functional Requirements

| ID         | Requirement                                                              |
| ---------- | ------------------------------------------------------------------------ |
| MAPPING-01 | System maps each confirmed item to one canonical material when possible. |
| MAPPING-02 | A canonical material can map to one or more STEM properties.             |
| MAPPING-03 | Mapping includes teacher-facing reasoning for experiment relevance.      |
| MAPPING-04 | Content Admin can create, edit, disable, and review mappings.            |
| MAPPING-05 | Content Admin can manage aliases for raw detected labels.                |
| MAPPING-06 | Content Admin can manage safe alternatives for simple missing materials. |
| MAPPING-07 | Matching flow can use material properties and alternatives.              |
| MAPPING-08 | Disabled materials or mappings are excluded from teacher suggestions.    |

## Core Flow

1. Teacher confirms inventory items.
2. API normalizes each item against material aliases.
3. API retrieves material properties and safety metadata.
4. Experiment Matching uses properties and requirements to score templates.
5. Teacher sees explanation for each matched material.
6. Content Admin updates mappings as content quality improves.

## Data Model

Primary entities:

- `Material`: canonical material.
- `MaterialAlias`: raw label or classroom synonym.
- `MaterialProperty`: STEM property attached to a material.
- `MaterialAlternative`: safe substitute mapping.
- `SafetyRule`: rule that can block or warn about materials.
- `AuditLog`: admin changes.

Key fields:

- `Material.canonicalName`
- `Material.displayName`
- `Material.status`
- `MaterialAlias.alias`
- `MaterialProperty.propertyKey`
- `MaterialProperty.reasoning`
- `MaterialAlternative.fromMaterialId`
- `MaterialAlternative.toMaterialId`
- `MaterialAlternative.constraints`

## API Contract

Candidate endpoints:

- `GET /materials/resolve?name=...`
- `GET /materials/:id/properties`
- `GET /materials/:id/alternatives`
- `GET /admin/materials`
- `POST /admin/materials`
- `PATCH /admin/materials/:id`
- `POST /admin/materials/:id/aliases`
- `POST /admin/materials/:id/properties`

Response requirements:

- Return canonical material, aliases, active properties, status, and warnings.
- Return user-safe reasoning, not internal scoring-only text.
- Admin writes must create audit logs.

## UX Requirements

- Teacher-facing mapping appears inside experiment suggestion details.
- Low-certainty or unresolved mappings should ask teacher to choose a material.
- Admin mapping screens support filter, search, status, pagination, and review notes.

## Safety And Quality

- AI cannot add unreviewed materials directly into experiment generation without rule checks.
- Unsafe or disabled materials must be excluded from safe alternatives.
- Every admin change affecting published content must be audited.

## Analytics

Track:

- `material_resolved`
- `material_unresolved`
- `material_mapping_admin_updated`
- `material_alternative_used`

## Acceptance Criteria

- Confirmed item can resolve to a canonical material by exact name or alias.
- A canonical material can show teacher-facing STEM properties.
- Experiment suggestions can display material reasoning.
- Content Admin can update mappings and changes persist.
- Disabled mappings stop appearing in new matches.
- Admin edits create audit log entries.

## Open Questions

- Should unresolved teacher-added items enter an admin review queue automatically?
- What initial canonical material set is required for pilot launch?
- Should property taxonomy be fixed in code or fully managed by admin?
