# FRS - MacGyver Classroom

Phiên bản: 0.1  
Ngày: 2026-05-15  
Trạng thái: Draft

## 1. Mục đích

FRS này mô tả các yêu cầu chức năng cho MacGyver Classroom: mobile app Flutter, landing page, NestJS API, Supabase Postgres/Storage và model-api AI.

Nguồn techstack: yêu cầu sản phẩm dùng Flutter, NestJS, Supabase Postgres và Cloudflare; các thành phần bổ sung kế thừa từ Cityfarm2.0 gồm Next.js landing/admin, Prisma, Supabase Storage, JWT/Google OAuth, Python Flask model-api, Gemini, Docker và Turborepo/pnpm.

## 2. Actor

| Actor | Mô tả |
| --- | --- |
| Teacher | Giáo viên STEM/Vật lý/Công nghệ dùng mobile app |
| School Admin | Người quản lý trường/tổ chuyên môn xem usage, thư viện chung |
| Content Admin | Người nhập, duyệt, chỉnh sửa thí nghiệm curated |
| System | Các service API, AI, database, storage, notification |
| Visitor | Người truy cập landing page |

## 3. Module chức năng

### FRS-01. Authentication & Account

| ID | Yêu cầu |
| --- | --- |
| FRS-01.01 | Người dùng có thể đăng ký bằng email/password. |
| FRS-01.02 | Người dùng có thể đăng nhập bằng Google OAuth nếu được bật. |
| FRS-01.03 | API phát hành access token và refresh token theo pattern JWT. |
| FRS-01.04 | Người dùng có thể đăng xuất khỏi thiết bị hiện tại. |
| FRS-01.05 | Hệ thống phân quyền Teacher, School Admin, Content Admin. |
| FRS-01.06 | API bảo vệ route bằng guard/role guard. |

### FRS-02. Teacher Profile & School Context

| ID | Yêu cầu |
| --- | --- |
| FRS-02.01 | Giáo viên nhập trường, môn dạy, cấp học, lớp thường dạy. |
| FRS-02.02 | Giáo viên chọn mục tiêu bài học hoặc chủ đề trước khi sinh giáo án. |
| FRS-02.03 | Hồ sơ được dùng làm context mặc định cho lesson generation. |
| FRS-02.04 | Giáo viên có thể cập nhật hồ sơ sau onboarding. |

### FRS-03. Vision Catalog

| ID | Yêu cầu |
| --- | --- |
| FRS-03.01 | Giáo viên có thể chụp ảnh bằng camera trong app. |
| FRS-03.02 | Giáo viên có thể upload ảnh từ thư viện. |
| FRS-03.03 | App gửi ảnh tới API và lưu bản gốc vào Supabase Storage. |
| FRS-03.04 | Model-api nhận diện vật phẩm và trả về tên vật phẩm, số lượng ước tính, confidence score. |
| FRS-03.05 | Hệ thống hiển thị danh sách vật phẩm nhận diện được. |
| FRS-03.06 | Giáo viên có thể sửa tên, số lượng, xóa vật phẩm sai, thêm vật phẩm thiếu. |
| FRS-03.07 | Scan được lưu thành inventory snapshot. |

### FRS-04. Property Mapping

| ID | Yêu cầu |
| --- | --- |
| FRS-04.01 | Mỗi vật phẩm được ánh xạ sang một hoặc nhiều property STEM. |
| FRS-04.02 | Ví dụ: chai nhựa -> áp suất/lực nâng; nam châm -> từ trường; dây thun -> đàn hồi/năng lượng tích trữ. |
| FRS-04.03 | Giáo viên có thể xem lý do vật phẩm phù hợp với thí nghiệm. |
| FRS-04.04 | Content Admin có thể quản lý bảng mapping vật phẩm-property. |

### FRS-05. Experiment Matching

| ID | Yêu cầu |
| --- | --- |
| FRS-05.01 | Hệ thống match inventory với database thí nghiệm curated. |
| FRS-05.02 | Hệ thống trả về tối đa 5 đề xuất ưu tiên theo độ khả thi. |
| FRS-05.03 | Mỗi đề xuất hiển thị vật liệu đã có, vật liệu thiếu, độ khó, thời lượng, lớp/môn/chủ đề. |
| FRS-05.04 | Hệ thống loại bỏ thí nghiệm vi phạm safety policy. |
| FRS-05.05 | Giáo viên có thể lọc theo lớp, môn, chủ đề, thời lượng, độ khó. |
| FRS-05.06 | Nếu thiếu 1-2 vật liệu đơn giản, hệ thống gợi ý vật thay thế an toàn. |

### FRS-06. Lesson Plan Generation

| ID | Yêu cầu |
| --- | --- |
| FRS-06.01 | Giáo viên chọn thí nghiệm để sinh giáo án 45 phút. |
| FRS-06.02 | Giáo án gồm: tên bài, mục tiêu, liên hệ GDPT 2018, vật liệu, chuẩn bị, tiến trình, câu hỏi gợi mở, đánh giá, safety note. |
| FRS-06.03 | Hệ thống dùng template có cấu trúc, không chỉ prompt tự do. |
| FRS-06.04 | Giáo viên có thể chỉnh sửa nội dung giáo án. |
| FRS-06.05 | Giáo viên có thể lưu nhiều phiên bản giáo án. |
| FRS-06.06 | Hệ thống ghi lại experiment template và inventory đã dùng để tạo giáo án. |

### FRS-07. Lesson Library

| ID | Yêu cầu |
| --- | --- |
| FRS-07.01 | Giáo viên xem danh sách giáo án đã lưu. |
| FRS-07.02 | Giáo viên tìm kiếm theo từ khóa, lớp, môn, chủ đề, ngày tạo. |
| FRS-07.03 | Giáo viên có thể duplicate giáo án để chỉnh cho lớp khác. |
| FRS-07.04 | Giáo viên có thể đánh dấu favorite. |
| FRS-07.05 | Giáo viên có thể xóa hoặc archive giáo án. |

### FRS-08. Export & Sharing

| ID | Yêu cầu |
| --- | --- |
| FRS-08.01 | Giáo viên xuất giáo án sang PDF. |
| FRS-08.02 | Giáo viên copy nội dung dạng Markdown/plain text. |
| FRS-08.03 | Giáo viên chia sẻ link read-only nếu organization cho phép. |
| FRS-08.04 | Export phải kèm safety note và vật liệu cần chuẩn bị. |

### FRS-09. Safety & Quality Guardrails

| ID | Yêu cầu |
| --- | --- |
| FRS-09.01 | Mọi thí nghiệm phải có safety category. |
| FRS-09.02 | Hệ thống chặn đề xuất nếu có vật liệu nguy hiểm trong denylist. |
| FRS-09.03 | Giáo viên phải xác nhận đã kiểm tra an toàn trước khi export. |
| FRS-09.04 | Người dùng có thể report nội dung không phù hợp. |
| FRS-09.05 | Content Admin có thể tắt một experiment template ngay lập tức. |

### FRS-10. Content Admin

| ID | Yêu cầu |
| --- | --- |
| FRS-10.01 | Content Admin CRUD thí nghiệm curated. |
| FRS-10.02 | Content Admin quản lý vật liệu bắt buộc, vật liệu thay thế và property mapping. |
| FRS-10.03 | Content Admin gắn lớp, môn, chủ đề, mục tiêu học tập, thời lượng. |
| FRS-10.04 | Content Admin gắn safety note và trạng thái duyệt. |
| FRS-10.05 | Chỉ thí nghiệm Published mới được dùng cho Teacher. |

### FRS-11. Landing Page

| ID | Yêu cầu |
| --- | --- |
| FRS-11.01 | Landing page hiển thị one-liner và CTA đăng ký pilot. |
| FRS-11.02 | Landing page giải thích pipeline 4 bước. |
| FRS-11.03 | Landing page có demo case vật liệu -> thí nghiệm -> giáo án. |
| FRS-11.04 | Landing page có form lead gồm tên, trường, vai trò, email/SĐT, ghi chú. |
| FRS-11.05 | Lead được lưu vào database và gửi thông báo nội bộ nếu cấu hình. |
| FRS-11.06 | Landing page có FAQ về an toàn, dữ liệu ảnh, GDPT 2018. |

### FRS-12. Analytics & Feedback

| ID | Yêu cầu |
| --- | --- |
| FRS-12.01 | Hệ thống ghi event: scan created, inventory confirmed, experiment selected, lesson generated, lesson exported. |
| FRS-12.02 | Giáo viên có thể rating kết quả AI sau mỗi giáo án. |
| FRS-12.03 | Feedback được lưu để đội nội dung cải thiện template. |
| FRS-12.04 | School Admin xem số giáo án đã tạo theo khoảng thời gian. |

## 4. Quy tắc nghiệp vụ

- BR-01: Một lesson plan phải gắn với ít nhất một experiment template.
- BR-02: Experiment template phải có safety note trước khi Published.
- BR-03: AI không được tự tạo thí nghiệm ngoài database curated trong MVP; LLM chỉ dùng để diễn giải và viết giáo án từ template đã chọn.
- BR-04: Nếu confidence nhận diện thấp, app phải yêu cầu giáo viên xác nhận rõ ràng.
- BR-05: Ảnh scan thuộc teacher hoặc organization sở hữu, không public mặc định.
- BR-06: Giáo án export phải thể hiện đây là bản gợi ý cần giáo viên kiểm tra.

## 5. Tiêu chí chấp nhận MVP

- Chụp/upload ảnh và tạo inventory snapshot thành công.
- Có thể chỉnh sửa inventory trước matching.
- Từ một inventory mẫu có chai nhựa, dây thun, ống hút, nam châm, hệ thống trả về danh sách thí nghiệm.
- Chọn một thí nghiệm và sinh giáo án 45 phút đầy đủ section.
- Lưu và xuất giáo án.
- Landing page ghi nhận lead đăng ký pilot.
- Admin có cách nhập/seed tối thiểu 200 thí nghiệm curated.
