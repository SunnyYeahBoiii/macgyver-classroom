# MacGyver Classroom

MacGyver Classroom turns teacher-provided classroom objects into safe STEM experiment and lesson workflows. This context captures product language for material scanning and inventory confirmation.

## Language

**Material Catalog**:
A curated set of classroom-safe material names that the system can recognize, map, and match to experiments.
_Avoid_: object list, item dictionary

**Base64 Scan Image**:
A teacher-captured image sent directly to the API for analysis without permanent image storage.
_Avoid_: uploaded asset, stored scan image

**Detected Item**:
An AI-proposed classroom material candidate that has not yet been approved by the teacher.
_Avoid_: confirmed material, inventory item

**Unmatched Detected Item**:
A useful visible object that AI detected but could not map to a canonical material in the Material Catalog.
_Avoid_: unknown error, dropped object

**Confirmed Inventory**:
The teacher-approved set of materials that can be used for experiment matching.
_Avoid_: AI inventory, raw scan result

**Catalog Unavailable**:
A system state where the Material Catalog is missing or empty, so AI material scanning must not run.
_Avoid_: no materials, empty scan

**No Materials Detected**:
A scan outcome where the Material Catalog exists and the image is valid, but AI found no usable classroom materials.
_Avoid_: catalog unavailable, provider failure

## Relationships

- A **Base64 Scan Image** produces zero or more **Detected Items**.
- A **Detected Item** can be an **Unmatched Detected Item** until the teacher corrects it.
- A teacher converts **Detected Items** into **Confirmed Inventory**.
- **Catalog Unavailable** is a system configuration problem; **No Materials Detected** is a teacher-facing scan outcome.

## Example dialogue

> **Dev:** "If Gemini sees a clamp that is not in the **Material Catalog**, should we hide it?"
> **Domain expert:** "No. Show it as an **Unmatched Detected Item** so the teacher can correct it before building the **Confirmed Inventory**."

## Flagged ambiguities

- "No material" was used for both an empty system catalog and an empty scan result. Resolved: use **Catalog Unavailable** for the system case and **No Materials Detected** for the teacher-facing scan outcome.
