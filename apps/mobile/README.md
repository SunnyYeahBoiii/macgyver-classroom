# MacGyver Classroom Mobile

Flutter teacher MVP for the photo-to-lesson workflow.

## Setup

Run commands from this directory:

```sh
cd apps/mobile
flutter pub get
```

Use a simulator, emulator, or attached device that `flutter devices` can see.

## Flutter Web Port

Flutter web uses `web_dev_config.yaml`, so `flutter run -d chrome` serves the app at `http://localhost:3000` instead of a random port. This only controls the Flutter dev server; if another local service already uses port 3000, stop it or override the run with `flutter run -d chrome --web-port=<port>`.

## Backend Modes

API mode is the default for the MVP scan flow. It keeps auth/profile local for now, then sends inventory scans and experiment matching requests to the NestJS API.

Start the API first from the repository root:

```sh
PORT=4000 npm --workspace api run dev
```

The API allows dynamic local web origins by default, including Flutter web URLs such as `http://localhost:63849`. For shared pilot or production environments, set `CORS_ORIGINS` in the API environment to a comma-separated allowlist.

Run mobile against the local API from `apps/mobile`:

```sh
flutter run --dart-define-from-file=dart_defines/local.env
```

`dart_defines/local.env` is tracked because it only contains safe local defaults:

```env
MCG_BACKEND=api
MCG_API_PORT=4000
MCG_API_BASE_URL=http://127.0.0.1:4000
```

`MCG_API_PORT` controls the default local API URL when `MCG_API_BASE_URL`
is omitted. `MCG_API_BASE_URL` still wins when it is provided.

Use `http://10.0.2.2:4000` only for an Android emulator running the native Flutter app against a local API. Flutter web/Chrome, desktop, and iOS simulator on this machine should use `http://127.0.0.1:4000`; the app normalizes an accidental non-Android `10.0.2.2` setting back to localhost. Use your machine LAN IP for a physical device. For an Android emulator, override the file value at run time:

```sh
flutter run \
  --dart-define-from-file=dart_defines/local.env \
  --dart-define=MCG_API_BASE_URL=http://10.0.2.2:4000
```

Mock mode remains available for offline UI demos:

```sh
flutter run --dart-define=MCG_BACKEND=mock
```

Omitting `MCG_BACKEND` uses API mode with `MCG_API_PORT=4000`, which resolves to `MCG_API_BASE_URL=http://127.0.0.1:4000` on non-Android targets.

## Test Commands

```sh
flutter pub get
dart format --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
flutter test integration_test/mock_mvp_flow_test.dart
```

## Demo Teacher Path

Use API mode for the AI scan demo when the NestJS API is running. Use mock mode only when demonstrating offline UI behavior.

Credentials:

- Email: `teacher@example.com`
- Password: `password123`

Path:

1. Sign in.
2. Complete the teacher profile and lesson context.
3. Start an inventory scan with the camera/gallery image.
4. Analyze detected items through `POST /inventory/scans/:id/analyze`.
5. Review, remove false positives or add missing items if needed, then confirm inventory.
6. Choose an experiment suggestion.
7. Generate the lesson.
8. Save the lesson.
9. Confirm safety before export/share.
10. Submit feedback.

## Backend Contract Status

This status supports `tasks/phuong-mobile-lead.md`, especially PHUONG-01 through PHUONG-08.

| Area                          | Mobile status                                                                                                                                                                                                | Backend contract status                                                                    |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------ |
| Auth session                  | MVP uses local mock auth in both backend modes so API integration is not blocked by auth work.                                                                                                               | Auth controller routes are pending.                                                        |
| Teacher profile               | Mock repository supports onboarding/profile completion.                                                                                                                                                      | Contract pending for profile read/update DTOs and route ownership.                         |
| Inventory scan                | API mode creates scans, posts base64 camera/gallery images to `/inventory/scans/:id/analyze`, loads scans, updates review items, and confirms inventory through NestJS. Mock mode remains available offline. | NestJS inventory scan endpoints are implemented for MVP base64 image analysis.             |
| Experiment matching           | API mode posts confirmed scan IDs to `/experiments/match` and loads experiment detail from `/experiments/:id`; mock mode remains available offline.                                                          | NestJS experiment matching and template detail endpoints are implemented for MVP matching. |
| Lesson generation and library | Mock lesson repository supports generation, save, and library lookups.                                                                                                                                       | Contract pending for lesson generation, versioning, save, and retrieval endpoints.         |
| Export and sharing            | Mock export/share URLs are generated locally after safety confirmation.                                                                                                                                      | Contract pending for export job, share-link, and PDF/document response shapes.             |
| Feedback and analytics        | Mock feedback and analytics are accepted locally.                                                                                                                                                            | Contract pending for event names, payload schema, feedback routes, and admin visibility.   |

## Next.js Mobile Shell

Flutter files are preserved for reference. The Next.js mobile shell runs from the same `apps/mobile` workspace.

Set `NEXT_PUBLIC_MCG_API_BASE_URL` when the NestJS API does not run on `http://127.0.0.1:4000`. The scan flow sends selected browser images to `POST /inventory/scans/:id/analyze`, confirms the reviewed scan through `POST /inventory/scans/:id/confirm`, and requests lesson matches from `POST /experiments/match`. Lesson draft creation is client-side until the lesson generation API contract is implemented.

```sh
bun install
npm --workspace mobile run dev
npm --workspace mobile run lint
npm --workspace mobile run check-types
npm --workspace mobile run build
```
