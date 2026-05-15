# PRD - FRS-03 Vision Catalog

## Status

Draft for MVP planning.

## Source Docs

- `docs/macgyver-classroom-frs.md` - FRS-03
- `docs/macgyver-classroom-srs.md` - Inventory endpoints and AI pipeline
- `docs/macgyver-classroom-system-design.md` - Vision Catalog contract and storage model

## Problem

Teachers often have classroom objects available but do not have time to manually list and map them into experiment-ready materials. The product needs a fast, correctable photo-to-inventory workflow that turns classroom photos into a structured inventory snapshot.

## Goals

- Let teachers capture or upload multiple classroom material photos.
- Store original photos privately.
- Run AI vision to identify items, quantities, confidence, evidence, and safety flags.
- Let teachers correct AI output before using it for experiment matching.
- Save confirmed results as an inventory snapshot.

## Non-Goals

- Fully automatic inventory without teacher confirmation.
- Student-facing camera capture.
- Real-time object detection while camera is open.
- Permanent whole-school stock management in MVP.

## Primary Users

- Teacher: captures photos and confirms materials.
- Content Admin: later reviews feedback about poor detection or unsafe labels.

## User Stories

- As a teacher, I can take several photos of classroom objects.
- As a teacher, I can upload existing photos from my library.
- As a teacher, I can see what the AI detected, how confident it is, and what evidence it used.
- As a teacher, I can correct item names and quantities before continuing.
- As a teacher, I can save the confirmed inventory as the basis for experiment suggestions.

## MVP Scope

- Camera capture in app.
- Photo upload from device library.
- Upload to Supabase Storage through API-managed signed upload flow.
- AI vision request through model-api.
- Detected-item list with raw label, canonical name, quantity estimate, confidence, evidence, and safety flags.
- Inventory editor for rename, quantity edit, delete, add missing item, and confirm.
- Saved inventory snapshot linked to teacher and scan images.

## Functional Requirements

| ID        | Requirement                                                                                                             |
| --------- | ----------------------------------------------------------------------------------------------------------------------- |
| VISION-01 | Teacher can capture a photo using device camera.                                                                        |
| VISION-02 | Teacher can upload a photo from device library.                                                                         |
| VISION-03 | Teacher can attach multiple images to one scan session.                                                                 |
| VISION-04 | App sends images to API and API stores originals in Supabase Storage.                                                   |
| VISION-05 | API sends image references to model-api for detection.                                                                  |
| VISION-06 | Model-api returns detected items with label, canonical name, quantity estimate, confidence, evidence, and safety flags. |
| VISION-07 | App displays detected items in an editable list.                                                                        |
| VISION-08 | Teacher can rename, change quantity, remove, and add items.                                                             |
| VISION-09 | Teacher confirms inventory snapshot before experiment matching.                                                         |
| VISION-10 | System records AI run metadata and prompt/model version where available.                                                |

## Core Flow

1. Teacher taps Scan.
2. Teacher captures or uploads one or more images.
3. Client creates an inventory scan session.
4. Client uploads images through API/storage flow.
5. API requests AI vision catalog generation.
6. API stores detected items and returns results.
7. Teacher edits the list.
8. Teacher confirms the inventory snapshot.
9. System creates confirmed items and unlocks experiment matching.

## AI Contract

Expected Vision Catalog response:

```json
{
  "items": [
    {
      "raw_label": "plastic bottle",
      "canonical_name": "chai nhua",
      "quantity_estimate": 3,
      "confidence": 0.82,
      "evidence": "visible on shelf, blue caps",
      "safety_flags": []
    }
  ]
}
```

Validation:

- Response must parse as JSON.
- Each item must have a canonical name, quantity estimate, confidence, and evidence.
- Confidence must be numeric and bounded.
- Safety flags must be structured, not free-form only.

## Data Model

Primary entities:

- `InventoryScan`: scan session.
- `ScanImage`: image metadata and storage reference.
- `DetectedItem`: raw AI result.
- `ConfirmedItem`: teacher-approved inventory item.
- `MediaAsset` or `StorageObjectRef`: private uploaded object reference.
- `AiRun`: AI invocation metadata.

Key fields:

- `InventoryScan.userId`
- `InventoryScan.status`
- `ScanImage.storagePath`
- `DetectedItem.rawLabel`
- `DetectedItem.canonicalName`
- `DetectedItem.quantityEstimate`
- `DetectedItem.confidence`
- `DetectedItem.evidence`
- `ConfirmedItem.name`
- `ConfirmedItem.quantity`

## API Contract

Candidate endpoints:

- `POST /inventory/scans`
- `POST /inventory/scans/:id/images`
- `POST /inventory/scans/:id/analyze`
- `GET /inventory/scans/:id`
- `PATCH /inventory/scans/:id/items/:itemId`
- `POST /inventory/scans/:id/confirmed-items`
- `POST /inventory/scans/:id/confirm`

Response requirements:

- Return scan status: `draft`, `uploading`, `analyzing`, `needs_review`, `confirmed`, `failed`.
- Return item-level confidence and evidence.
- Return retry-safe errors for provider failure or invalid image.

## UX Requirements

- Show upload/analyze progress.
- Support retry for failed image or failed analysis.
- Make low-confidence items visually distinct.
- Require teacher confirmation before matching.
- Do not hide safety flags inside secondary screens.

## Safety And Privacy

- Upload requires explicit teacher action and consent.
- Images are private by default.
- Signed URLs expire.
- AI output must not be treated as final until teacher confirms.
- Error responses must not include raw provider stack traces.

## Analytics

Track:

- `scan_created`
- `scan_image_uploaded`
- `scan_analysis_started`
- `scan_analysis_failed`
- `inventory_confirmed`
- `detected_item_corrected`

## Acceptance Criteria

- Teacher can create a scan from multiple images.
- Original images are stored privately with metadata.
- AI returns a structured item list or a recoverable error.
- Teacher can edit all detected items and add missing items.
- Confirmed inventory snapshot persists and can be used by Experiment Matching.
- Invalid image and provider failure have tested error paths.

## Open Questions

- What maximum image count and image size should MVP support per scan?
- Should confirmed inventory snapshots be reusable across future lesson plans?
- Should teacher corrections feed a review queue for improving material aliases?
