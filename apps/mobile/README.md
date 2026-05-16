# MacGyver Classroom Mobile

Flutter teacher MVP for the photo-to-lesson workflow.

## Setup

Run commands from this directory:

```sh
cd apps/mobile
flutter pub get
```

Use a simulator, emulator, or attached device that `flutter devices` can see.

## Backend Modes

Mock mode is the default. It works offline and is the expected mode for the mobile demo:

```sh
flutter run --dart-define=MCG_BACKEND=mock
```

Omitting `MCG_BACKEND` also uses mock mode.

API mode is available behind `MCG_BACKEND=api`, but it currently only swaps auth to HTTP. Profile, inventory, experiment matching, lesson generation, export, feedback, and analytics still use in-app mock repositories.

```sh
flutter run \
  --dart-define=MCG_BACKEND=api \
  --dart-define=MCG_API_BASE_URL=http://127.0.0.1:3000
```

Use `http://10.0.2.2:3000` for an Android emulator hitting a local API.

If `MCG_BACKEND=api` is set, `MCG_API_BASE_URL` is required. The mobile auth client expects these routes:

- `POST /auth/login`
- `POST /auth/register`
- `POST /auth/refresh`
- `POST /auth/logout`

## Test Commands

```sh
flutter pub get
dart format --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
flutter test integration_test/mock_mvp_flow_test.dart
```

## Demo Teacher Path

Use mock mode for the demo until the backend contract below is complete.

Credentials:

- Email: `teacher@example.com`
- Password: `password123`

Path:

1. Sign in.
2. Complete the teacher profile and lesson context.
3. Start an inventory scan with the mock camera/gallery image.
4. Analyze detected items.
5. Review, remove false positives or add missing items if needed, then confirm inventory.
6. Choose an experiment suggestion.
7. Generate the lesson.
8. Save the lesson.
9. Confirm safety before export/share.
10. Submit feedback.

## Backend Contract Status

This status supports `tasks/phuong-mobile-lead.md`, especially PHUONG-01 through PHUONG-08.

| Area | Mobile status | Backend contract status |
| --- | --- | --- |
| Auth session | API-mode client calls `/auth/login`, `/auth/register`, `/auth/refresh`, and `/auth/logout`. Mock mode is demo-ready. | API app has an auth module boundary, but no auth controller routes are documented as complete. Treat auth API as pending integration. |
| Teacher profile | Mock repository supports onboarding/profile completion. | Contract pending for profile read/update DTOs and route ownership. |
| Inventory scan | Mock repository supports draft scan, mock image attach, analysis, item review, and confirmation. | Contract pending for image upload, scan analysis, detected item edits, and confirmed item DTOs. |
| Experiment matching | Mock repository returns lesson-ready suggestions from confirmed inventory. | Contract pending for match request/response DTOs, filters, safety notes, and AI/backend ownership. |
| Lesson generation and library | Mock lesson repository supports generation, save, and library lookups. | Contract pending for lesson generation, versioning, save, and retrieval endpoints. |
| Export and sharing | Mock export/share URLs are generated locally after safety confirmation. | Contract pending for export job, share-link, and PDF/document response shapes. |
| Feedback and analytics | Mock feedback and analytics are accepted locally. | Contract pending for event names, payload schema, feedback routes, and admin visibility. |

The current NestJS API README describes most route controllers as scaffolded and method-free except `GET /health`. Keep mobile demos on mock mode until the shared API contract table has endpoint, request DTO, response DTO, auth requirement, owner, and consumer for each row above.
