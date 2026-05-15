# PRD - MacGyver Classroom

Phiên bản: 0.1  
Ngày: 2026-05-15  
Trạng thái: Draft

## 1. Tóm tắt sản phẩm

MacGyver Classroom là mobile app cho giáo viên STEM/Vật lý/Công nghệ cấp THCS-THPT tại Việt Nam. Giáo viên chụp ảnh tủ đồ cũ, bàn làm việc hoặc kho vật tư trong trường; AI nhận diện vật phẩm, ánh xạ tính chất vật lý/hóa học an toàn, sau đó đề xuất các thí nghiệm STEM khả thi kèm giáo án 45 phút theo định hướng chương trình GDPT 2018.

One-liner:

> Chụp ảnh tủ đồ cũ trong trường -> AI ra 5 thí nghiệm STEM kèm giáo án 45 phút theo chuẩn chương trình GDPT 2018.

Sản phẩm gồm:

- Mobile app Flutter cho giáo viên sử dụng hằng ngày.
- Landing page giới thiệu sản phẩm, thu lead trường học và demo luồng AI.
- Backend NestJS API, Supabase Postgres, Supabase Storage, model-api AI kế thừa pattern từ Cityfarm2.0.
- Cloudflare làm lớp deployment/CDN/routing cho landing page và các service production.

## 2. Nguồn đầu vào và giả định

Nguồn tổng hợp:

- OCR ý tưởng MacGyver Classroom do người dùng cung cấp.
- Cityfarm2.0: monorepo Turborepo + pnpm, Next.js landing/web/admin, NestJS API, Python Flask model-api, Gemini, Prisma, Supabase Storage, JWT/Google OAuth, Docker/GitHub Actions/VPS deployment pattern.
- Context7 docs: NestJS module/controller/provider, validation, guards/JWT, Swagger; Supabase Postgres/Storage/RLS/service integration; Cloudflare Pages/Workers deployment, secrets, preview/production environments.

Giả định sản phẩm:

- Người dùng chính là giáo viên, không phải học sinh.
- MVP ưu tiên Việt Nam, tiếng Việt, chương trình GDPT 2018.
- Thí nghiệm chỉ dùng đồ văn phòng/gia dụng an toàn; loại trừ pin lithium, điện cao áp, lửa, hóa chất nguy hiểm.
- AI tạo đề xuất, nhưng giáo viên là người duyệt cuối trước khi dùng trong lớp.

## 3. Vấn đề

Giáo viên STEM Việt Nam thường thiếu thiết bị, ngân sách thấp và phải tự chế đồ thí nghiệm từ vật dụng có sẵn. Rào cản thật không chỉ là thiếu vật liệu, mà là thiếu thời gian để:

- Nghĩ ra thí nghiệm phù hợp với vật liệu đang có.
- Gắn thí nghiệm với mục tiêu bài học và chương trình GDPT 2018.
- Viết giáo án 45 phút có hoạt động, câu hỏi gợi mở, đánh giá và lưu ý an toàn.
- Chuẩn hóa tài liệu để chia sẻ nội bộ tổ chuyên môn.

## 4. Người dùng mục tiêu

### Persona chính

Giáo viên STEM/Vật lý/Công nghệ THCS-THPT:

- Dạy 18-24 tiết/tuần.
- Có áp lực đổi mới phương pháp dạy học và triển khai STEM.
- Có kho vật tư cũ nhưng không biết kết hợp thành thí nghiệm nào.
- Cần giáo án dùng được ngay, không phải chỉ ý tưởng rời rạc.

### Persona phụ

Tổ trưởng chuyên môn hoặc ban giám hiệu:

- Muốn có thư viện hoạt động STEM chi phí thấp.
- Cần kiểm soát an toàn, chất lượng và tính bám chương trình.
- Có thể là người ra quyết định mua gói trường học.

## 5. Giá trị cốt lõi

- Giảm thời gian chuẩn bị từ vài giờ xuống còn vài phút.
- Tận dụng vật dụng cũ trong trường thay vì mua bộ kit mới.
- Biến AI Vision thành đầu ra có cấu trúc: danh mục vật phẩm, thí nghiệm, giáo án, safety note.
- Tạo cơ sở cho mô hình B2B trường học: license theo trường/tổ chuyên môn.

## 6. Mục tiêu sản phẩm

### MVP

- Giáo viên đăng nhập, tạo hồ sơ trường/lớp/môn học.
- Chụp hoặc upload ảnh vật tư.
- AI nhận diện vật phẩm và cho phép giáo viên sửa lại danh sách.
- Hệ thống đề xuất 5 thí nghiệm khả thi dựa trên vật phẩm hiện có.
- Sinh giáo án 45 phút gồm mục tiêu, vật liệu, quy trình, câu hỏi, đánh giá, lưu ý an toàn.
- Lưu, chỉnh sửa, xuất PDF/Markdown và chia sẻ giáo án.
- Landing page có demo, value proposition, form đăng ký pilot.

### Sau MVP

- Admin portal quản trị database thí nghiệm curated.
- Gợi ý mua bổ sung vật tư giá rẻ nếu thiếu 1-2 món.
- Chấm điểm độ phù hợp với chương trình theo lớp/môn/chủ đề.
- Cộng đồng giáo viên chia sẻ giáo án đã dùng.
- Tích hợp LMS hoặc Google Classroom nếu có nhu cầu từ trường.

## 7. Không thuộc phạm vi MVP

- Không bán marketplace vật tư ở giai đoạn đầu.
- Không cho học sinh tự dùng app trực tiếp.
- Không tạo thí nghiệm hóa học nguy hiểm, điện cao áp, cháy nổ.
- Không đảm bảo AI nhận diện đúng 100%; giáo viên phải xác nhận inventory.
- Không tự động nộp giáo án lên hệ thống quản lý giáo dục.

## 8. Luồng người dùng chính

### Luồng 1: Tạo giáo án từ ảnh

1. Giáo viên mở app và chọn "Tạo thí nghiệm mới".
2. Chụp ảnh tủ/kho/bàn vật tư.
3. AI trả về danh mục vật phẩm và số lượng ước tính.
4. Giáo viên sửa tên/số lượng nếu AI nhận sai.
5. App đề xuất 5 thí nghiệm phù hợp.
6. Giáo viên chọn một thí nghiệm.
7. AI sinh giáo án 45 phút theo lớp, môn, chủ đề.
8. Giáo viên chỉnh sửa, lưu và xuất tài liệu.

### Luồng 2: Tìm thí nghiệm từ inventory đã lưu

1. Giáo viên chọn một inventory đã quét trước đó.
2. Lọc theo lớp, môn, thời lượng, độ khó, chủ đề.
3. Chọn thí nghiệm và sinh giáo án.

### Luồng 3: Trường đăng ký pilot từ landing page

1. Người quản lý vào landing page.
2. Xem demo pipeline 4 bước.
3. Điền form tên trường, số giáo viên, email/SĐT.
4. Hệ thống tạo lead cho đội vận hành follow-up.

## 9. Tính năng MVP

### Mobile app

- Đăng nhập bằng email/password, Google OAuth hoặc magic link theo quyết định triển khai.
- Hồ sơ giáo viên: trường, môn, cấp học, lớp dạy.
- Chụp/upload nhiều ảnh vật tư.
- Vision Catalog: nhận diện vật phẩm, số lượng, độ tin cậy.
- Inventory Editor: chỉnh sửa vật phẩm, gom nhóm, thêm ghi chú.
- Experiment Match: đề xuất thí nghiệm dựa trên vật liệu hiện có.
- Lesson Plan Generator: sinh giáo án 45 phút.
- Lesson Library: lưu, tìm kiếm, chỉnh sửa, xuất file.
- Safety Guardrails: cảnh báo rủi ro, yêu cầu giáo viên xác nhận an toàn.

### Landing page

- Hero nêu rõ one-liner và đối tượng giáo viên/trường học.
- Section pipeline 4 bước: Vision Catalog, Property Mapping, Experiment Match, Lesson Plan Gen.
- Demo vật liệu -> thí nghiệm -> giáo án.
- Lợi ích cho giáo viên, tổ chuyên môn, nhà trường.
- Form đăng ký pilot.
- FAQ về an toàn, dữ liệu ảnh, chương trình GDPT 2018.

## 10. Thành công đo bằng gì

### Product metrics

- >= 70% scan có ít nhất 3 vật phẩm được giáo viên xác nhận là đúng.
- >= 60% scan tạo được ít nhất 1 giáo án được lưu.
- Thời gian từ chụp ảnh đến giáo án đầu tiên <= 3 phút ở P75.
- >= 40% giáo viên quay lại tạo giáo án thứ hai trong 14 ngày.

### Business metrics

- 10 trường đăng ký pilot trong giai đoạn thử nghiệm.
- 3 trường dùng thử với ít nhất 5 giáo viên/trường.
- >= 30 giáo án được tạo và dùng trong lớp trong pilot.
- Có ít nhất 5 feedback định tính về tiết kiệm thời gian chuẩn bị.

## 11. Rủi ro chính

- AI nhận diện sai vật phẩm trong ảnh lộn xộn.
- Thí nghiệm sinh ra không đủ bám chương trình hoặc không khả thi trong lớp 45 phút.
- Rủi ro an toàn nếu AI đề xuất vật liệu/hoạt động không phù hợp.
- Giáo viên không tin đầu ra AI nếu không thể chỉnh sửa hoặc xem lý do đề xuất.
- B2B sales cycle với trường học có thể dài hơn MVP timeline.

## 12. Nguyên tắc sản phẩm

- Giáo viên kiểm soát cuối cùng, AI chỉ đề xuất.
- Mọi thí nghiệm phải có safety note.
- Ưu tiên vật liệu an toàn, rẻ, phổ biến trong trường.
- Đầu ra phải dùng được trong lớp, không chỉ là ý tưởng.
- Trải nghiệm mobile phải nhanh: chụp -> xác nhận -> chọn -> giáo án.

