# SRS - MacGyver Classroom

Phiên bản: 0.1  
Ngày: 2026-05-15  
Trạng thái: Draft

## 1. Mục đích

SRS này mô tả yêu cầu hệ thống, kiến trúc, dữ liệu, API, AI pipeline, bảo mật, deployment và phi chức năng cho MacGyver Classroom.

## 2. Kiến trúc tổng quan

```text
Flutter Mobile App
        |
        | HTTPS JSON + multipart upload
        v
NestJS API (REST, Auth, Business Logic)
        |
        | Prisma ORM
        v
Supabase Postgres
        |
        | Supabase Storage SDK
        v
Supabase Storage (scan images, export files)
        |
        | Internal service call
        v
Python Flask model-api (Vision + LLM orchestration)
        |
        | Gemini / vision-capable model
        v
AI Provider

Landing Page (Next.js) -> Cloudflare Pages -> Lead API
Admin/Content App (Next.js, optional MVP+) -> NestJS API
Cloudflare -> DNS/CDN/WAF/Pages/Workers/Containers or tunnel routing
```

## 3. Tech stack

### Bắt buộc theo yêu cầu

| Layer | Công nghệ |
| --- | --- |
| Mobile | Flutter |
| API | NestJS |
| Database | Supabase Postgres |
| Deployment | Cloudflare |

### Kế thừa từ Cityfarm2.0

| Layer | Công nghệ đề xuất |
| --- | --- |
| Monorepo | Turborepo + pnpm |
| Landing/Admin | Next.js 16, React 19, TypeScript, Tailwind CSS 4 |
| API runtime | Node.js 20+ |
| API framework | NestJS 11 |
| ORM | Prisma 7 với Supabase Postgres |
| Storage | Supabase Storage |
| Auth pattern | JWT access/refresh token, Google OAuth tùy chọn |
| AI model-api | Python Flask, google-genai, OpenCV headless, Pillow |
| Containerization | Dockerfile per service |
| CI/CD | GitHub Actions pattern |

### Ghi chú Cloudflare

- Landing page nên deploy bằng Cloudflare Pages.
- Cloudflare Workers phù hợp cho edge routing, webhook nhẹ, redirect, proxy hoặc BFF rất mỏng.
- NestJS API/model-api containerized nên triển khai bằng Cloudflare Containers nếu phù hợp, hoặc VPS/container runtime đứng sau Cloudflare Tunnel/CDN như fallback thực tế.
- Secrets và environment phải tách preview/production.

## 4. Thành phần hệ thống

### Mobile app Flutter

- Camera capture và image picker.
- Auth/session management.
- Inventory confirmation UI.
- Experiment recommendation UI.
- Lesson plan editor.
- Offline-friendly draft state tối thiểu.
- PDF/share integration.

### NestJS API

NestJS được tổ chức theo module/controller/provider:

- `auth`: register, login, refresh, OAuth callback, guards.
- `users`: teacher profile, organization membership.
- `inventory`: scan session, detected item, confirmed item.
- `experiments`: templates, material requirements, matching.
- `lessons`: lesson generation, saved plans, export.
- `assets`: Supabase Storage upload/signed URL.
- `content-admin`: curated content management.
- `leads`: landing page pilot leads.
- `analytics`: event tracking and reporting.

### Python model-api

- `vision_catalog`: nhận ảnh, gọi vision model, normalize vật phẩm.
- `property_mapping`: map item -> STEM property.
- `lesson_generation`: gọi LLM với template có cấu trúc.
- `safety_check`: kiểm tra denylist/rule trước khi trả output.

### Database

Supabase Postgres là source of truth. Prisma quản lý schema/migration. Runtime dùng pooled `DATABASE_URL`; migration dùng direct `DIRECT_URL`.

### Storage

Supabase Storage lưu:

- Ảnh scan gốc.
- Ảnh đã resize/processed nếu cần.
- File export PDF nếu chọn lưu server-side.

## 5. Data model đề xuất

| Entity | Mục đích |
| --- | --- |
| `Organization` | Trường hoặc đơn vị sử dụng |
| `User` | Tài khoản giáo viên/admin |
| `TeacherProfile` | Môn, cấp học, lớp, trường |
| `InventoryScan` | Một lần scan/upload ảnh |
| `ScanImage` | Metadata ảnh trong Supabase Storage |
| `DetectedItem` | Vật phẩm AI nhận diện |
| `ConfirmedItem` | Vật phẩm sau khi giáo viên xác nhận |
| `Material` | Danh mục vật liệu chuẩn hóa |
| `MaterialProperty` | Tính chất STEM của vật liệu |
| `ExperimentTemplate` | Thí nghiệm curated |
| `ExperimentMaterialRequirement` | Vật liệu cần có cho thí nghiệm |
| `CurriculumStandard` | Mapping lớp/môn/chủ đề GDPT 2018 |
| `ExperimentCurriculumMapping` | Liên hệ thí nghiệm với chuẩn/chủ đề |
| `ExperimentMatch` | Kết quả matching từ inventory |
| `LessonPlan` | Giáo án đã sinh và lưu |
| `SafetyRule` | Rule/denylist an toàn |
| `Feedback` | Rating/report của giáo viên |
| `Lead` | Lead từ landing page |
| `AnalyticsEvent` | Event sản phẩm |

## 6. API endpoint đề xuất

### Auth

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`
- `GET /auth/profile`
- `GET /auth/google`
- `GET /auth/google/callback`

### Inventory

- `POST /inventory/scans`
- `POST /inventory/scans/:id/images`
- `POST /inventory/scans/:id/analyze`
- `GET /inventory/scans/:id`
- `PATCH /inventory/scans/:id/confirmed-items`
- `GET /inventory/scans`

### Experiments

- `POST /experiments/match`
- `GET /experiments/:id`
- `GET /experiments`
- `POST /admin/experiments`
- `PATCH /admin/experiments/:id`
- `POST /admin/experiments/:id/publish`

### Lessons

- `POST /lesson-plans/generate`
- `GET /lesson-plans`
- `GET /lesson-plans/:id`
- `PATCH /lesson-plans/:id`
- `POST /lesson-plans/:id/export`
- `POST /lesson-plans/:id/feedback`

### Landing leads

- `POST /leads`
- `GET /admin/leads`

## 7. AI pipeline

### Bước 1: Vision Catalog

Input:

- 1-n ảnh.
- Context optional: trường/lớp/môn/chủ đề.

Output:

- Danh sách vật phẩm: canonical name, raw label, quantity estimate, confidence, bounding/region optional.

Yêu cầu:

- Confidence thấp phải được đánh dấu.
- Không tự động chuyển sang matching nếu giáo viên chưa xác nhận.

### Bước 2: Property Mapping

Input:

- Confirmed items.

Output:

- Vật phẩm + property STEM: áp suất, đàn hồi, từ trường, lực nâng, ma sát, đòn bẩy, truyền nhiệt, quang học.

Yêu cầu:

- Mapping ưu tiên database curated trước, LLM chỉ gợi ý nếu chưa có mapping.

### Bước 3: Experiment Match

Input:

- Confirmed items + properties + filter lớp/môn/chủ đề.

Output:

- Top 5 experiment templates có điểm match.

Scoring gợi ý:

- Vật liệu bắt buộc đã có.
- Vật liệu thay thế hợp lệ.
- Chủ đề/lớp/môn khớp.
- Safety level phù hợp.
- Thời lượng <= 45 phút.

### Bước 4: Lesson Plan Generation

Input:

- Experiment template.
- Inventory đã xác nhận.
- Teacher profile.
- Curriculum mapping.

Output:

- Giáo án 45 phút có cấu trúc.

Guardrail:

- LLM không được thêm vật liệu nguy hiểm ngoài template.
- Safety note luôn bắt buộc.
- Nếu thiếu dữ liệu chương trình, output phải ghi rõ giả định cần giáo viên kiểm tra.

## 8. Bảo mật và quyền riêng tư

- Tất cả API dùng HTTPS.
- NestJS sử dụng validation pipe cho DTO input.
- JWT access token ngắn hạn, refresh token lưu/rotate an toàn.
- Route admin yêu cầu role guard.
- Supabase service role key chỉ nằm ở backend, không đưa vào mobile/landing.
- Storage object private mặc định; truy cập qua signed URL hoặc backend proxy.
- Organization data isolation: giáo viên chỉ xem dữ liệu của mình hoặc trường mình được cấp quyền.
- Log không chứa access token, refresh token, service key.
- RLS có thể bật cho bảng public-facing; nếu Prisma backend dùng service role/direct DB, kiểm soát tenant phải thực hiện ở API layer và test kỹ.

## 9. Yêu cầu phi chức năng

| Nhóm | Yêu cầu |
| --- | --- |
| Hiệu năng | P75 từ upload ảnh đến inventory result <= 20 giây cho 1 ảnh tiêu chuẩn |
| Lesson generation | P75 từ chọn thí nghiệm đến giáo án <= 90 giây |
| Availability | MVP target >= 99% trong thời gian pilot |
| Scalability | Hỗ trợ batch xử lý async nếu nhiều ảnh/model latency cao |
| Maintainability | Module NestJS tách rõ, DTO validation, Swagger/OpenAPI |
| Observability | Structured logs, request id, AI call timing, error tracking |
| Localization | Tiếng Việt mặc định; cấu trúc đủ mở để thêm tiếng Anh |
| Accessibility | Landing page đáp ứng WCAG cơ bản, mobile UI đọc được ở font lớn |
| Backup | Supabase backup theo plan, export seed content định kỳ |

## 10. Deployment

### Environments

- `development`
- `staging`
- `production`

### Cloudflare

- DNS và custom domain.
- Cloudflare Pages cho landing page.
- Preview deployment cho pull request.
- Environment variables/secrets tách preview/production.
- WAF/rate limiting cho API public endpoint.
- Worker route/proxy optional cho `/api/*` nếu cần edge gateway.

### Backend/API

Phương án ưu tiên:

- Build Docker image cho `api` và `model-api`.
- Deploy container trên Cloudflare Containers nếu đáp ứng runtime.
- Nếu chưa phù hợp, deploy VPS/container runtime sau Cloudflare Tunnel/CDN, giữ cùng domain/routing.

### Database/Storage

- Supabase project per environment hoặc schema tách riêng cho staging.
- `DATABASE_URL` pooled cho runtime.
- `DIRECT_URL` cho Prisma migration.
- Supabase Storage bucket private: `scan-images`, `lesson-exports`.

## 11. CI/CD

- Lint, typecheck, unit test cho API.
- Prisma validate/generate/migrate deploy.
- Build Flutter theo target Android/iOS ở pipeline riêng.
- Build landing page và deploy Cloudflare Pages.
- Build Docker image cho API/model-api.
- Smoke test endpoint health sau deploy.

## 12. Testing

### Unit test

- Experiment matching score.
- Safety rule filtering.
- DTO validation.
- Lesson prompt/template assembly.

### Integration test

- Auth + protected route.
- Upload image -> storage metadata.
- Inventory confirmation -> experiment match.
- Lesson generation with mocked model-api.
- Lead form submission.

### AI evaluation

- Bộ ảnh test gồm vật phẩm phổ biến: chai nhựa, dây thun, ống hút, nam châm, cốc giấy, kẹp giấy, bìa carton.
- Đánh giá precision/recall vật phẩm.
- Đánh giá lesson plan bằng rubric: đúng cấu trúc, bám vật liệu, an toàn, phù hợp 45 phút.

## 13. Open questions

- Chọn AI provider chính: Gemini như Cityfarm2.0 hay provider khác.
- App có dùng Supabase Auth trực tiếp hay giữ NestJS JWT như Cityfarm2.0.
- Admin/content app có cần trong MVP hay chỉ seed qua script nội bộ.
- Export PDF render ở mobile hay backend.
- Cloudflare Containers có là target bắt buộc hay chấp nhận VPS sau Cloudflare cho API/model-api.

