# Base64 Scan Images for Vision Catalog v1

For Vision Catalog v1, mobile sends captured classroom photos to the API as base64 image payloads during scan analysis, and the API does not persist `ScanImage` records or private image assets. This deliberately narrows MVP scope so Google Vertex AI material detection, teacher review, and manual correction can ship before the full Supabase signed-upload/private-storage flow is implemented.

**Consequences**

- Scan analysis is auditable through `AiRun` and `DetectedItem`, but original images are not retained.
- The public PRD storage requirement remains a later hardening step, not part of this v1 implementation.
