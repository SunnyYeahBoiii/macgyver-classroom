# BRD - MacGyver Classroom

Phiên bản: 0.1  
Ngày: 2026-05-15  
Trạng thái: Draft

## 1. Mục đích tài liệu

BRD này mô tả nhu cầu kinh doanh, mục tiêu thị trường, stakeholder, mô hình doanh thu, ràng buộc vận hành và tiêu chí thành công cho MacGyver Classroom: một sản phẩm AI hỗ trợ giáo viên STEM biến vật dụng cũ trong trường thành thí nghiệm và giáo án.

## 2. Bối cảnh kinh doanh

Trường học Việt Nam đang triển khai chương trình GDPT 2018 với định hướng STEM và hoạt động trải nghiệm. Nhiều trường có nhu cầu tổ chức tiết học thực hành nhưng thiếu thiết bị, ngân sách mua kit thấp và giáo viên thiếu thời gian chuẩn bị.

MacGyver Classroom khai thác khoảng trống này bằng cách biến vật dụng có sẵn thành hoạt động học tập có cấu trúc. Đây là thị trường có ngân sách tổ chức từ trường/tổ chuyên môn, phù hợp mô hình B2B hơn là app hobbyist cho cá nhân.

Nguồn kỹ thuật ban đầu lấy từ yêu cầu sản phẩm và Cityfarm2.0: Flutter cho mobile app, Next.js cho landing page, NestJS cho API, Supabase Postgres/Storage cho dữ liệu và ảnh, Cloudflare cho deployment, model-api AI theo pattern Python Flask/Gemini. Pipeline giá trị gồm Vision Catalog, Property Mapping, Experiment Match và Lesson Plan Generation.

## 3. Mục tiêu kinh doanh

### Ngắn hạn

- Xây dựng MVP đủ để demo cho trường học và hội đồng/judges.
- Chạy pilot với nhóm giáo viên STEM/Vật lý/Công nghệ THCS-THPT.
- Chứng minh AI có thể giảm thời gian chuẩn bị giáo án STEM.
- Thu thập database thí nghiệm curated đầu tiên gồm 200-500 mẫu.

### Trung hạn

- Bán license theo trường/tổ chuyên môn.
- Mở rộng thư viện thí nghiệm theo lớp, môn, chủ đề GDPT 2018.
- Xây dựng admin workflow để chuyên gia giáo dục duyệt nội dung.
- Tạo case study từ các trường pilot.

### Dài hạn

- Trở thành nền tảng hỗ trợ triển khai STEM chi phí thấp cho trường phổ thông.
- Mở cộng đồng chia sẻ giáo án/thí nghiệm đã kiểm chứng.
- Mở rộng sang các chủ đề công nghệ, maker, môi trường, tái chế.

## 4. Stakeholder

| Stakeholder | Nhu cầu | Vai trò |
| --- | --- | --- |
| Giáo viên STEM/Vật lý/Công nghệ | Tạo giáo án nhanh, an toàn, bám chương trình | Người dùng chính |
| Tổ trưởng chuyên môn | Chuẩn hóa hoạt động, chia sẻ giáo án trong tổ | Người ảnh hưởng |
| Ban giám hiệu | Hiệu quả chi phí, đổi mới dạy học, báo cáo hoạt động STEM | Người ra quyết định |
| Phụ huynh/học sinh | Tiết học thực hành hấp dẫn, an toàn | Người hưởng lợi gián tiếp |
| Đội nội dung | Curate thí nghiệm, kiểm tra an toàn, bám GDPT 2018 | Vận hành nội dung |
| Đội kỹ thuật | Phát triển mobile, API, AI, database, deployment | Triển khai sản phẩm |

## 5. Phạm vi kinh doanh

Trong phạm vi:

- Mobile app cho giáo viên.
- Landing page giới thiệu và thu lead.
- Bộ thí nghiệm curated có metadata vật liệu, tính chất, lớp/môn/chủ đề.
- AI pipeline hỗ trợ nhận diện vật phẩm, matching thí nghiệm và sinh giáo án.
- Admin/content workflow tối thiểu để seed và duyệt thí nghiệm.

Ngoài phạm vi ban đầu:

- Marketplace bán vật tư.
- Hệ thống LMS đầy đủ.
- App học sinh độc lập.
- Chứng nhận chính thức thay giáo án của nhà trường.
- Tự động đảm bảo an toàn pháp lý nếu giáo viên bỏ qua hướng dẫn.

## 6. Mô hình doanh thu đề xuất

### Pilot

- Miễn phí hoặc phí thấp cho 3-10 trường đầu tiên.
- Đổi lại: feedback, case study, dữ liệu sử dụng ẩn danh, testimonial.

### B2B license

- Gói theo trường/năm.
- Giới hạn theo số giáo viên hoặc số giáo án tạo mỗi tháng.
- Có dashboard cho tổ chuyên môn/ban giám hiệu.

### Gói mở rộng

- Gói nội dung premium theo môn/chủ đề.
- Gói tập huấn giáo viên sử dụng AI để triển khai STEM.
- Gói custom nội dung theo địa phương/trường chuyên biệt.

## 7. Đề xuất gói sản phẩm

| Gói | Đối tượng | Nội dung |
| --- | --- | --- |
| Starter | Giáo viên cá nhân/pilot | Scan ảnh, tạo giáo án giới hạn, thư viện cá nhân |
| School | Trường học | Nhiều tài khoản giáo viên, thư viện chung, xuất báo cáo |
| District/Partner | Cụm trường/đối tác | Quản trị nhiều trường, content pack, analytics nâng cao |

## 8. Lợi thế cạnh tranh

- Niche rõ: giáo viên STEM cấp 2-3, không dàn trải cho mọi người dùng.
- Đầu vào tự nhiên: ảnh vật dụng sẵn có trong trường.
- Đầu ra có giá trị vận hành: giáo án 45 phút, không chỉ gợi ý.
- Bám bối cảnh Việt Nam: GDPT 2018, ngân sách thấp, thiết bị hạn chế.
- AI pipeline có cấu trúc nên dễ kiểm soát chất lượng hơn free-form chatbot.

## 9. Quy trình vận hành nội dung

1. Đội nội dung tạo hoặc nhập thí nghiệm curated.
2. Mỗi thí nghiệm có metadata: vật liệu, property, lớp/môn, mục tiêu, độ khó, thời lượng, an toàn.
3. Chuyên gia duyệt safety note và mapping GDPT 2018.
4. Hệ thống dùng database này để matching, không để LLM tự bịa thí nghiệm từ đầu.
5. Feedback từ giáo viên được ghi nhận để cải thiện template và scoring.

## 10. Yêu cầu tuân thủ và an toàn

- Không đề xuất vật liệu nguy hiểm: pin lithium, điện cao áp, hóa chất độc, lửa, vật sắc nhọn không kiểm soát.
- Mỗi giáo án phải có safety note và danh sách vật liệu cần kiểm tra.
- Ảnh upload phải được lưu có kiểm soát, không dùng công khai ngoài mục đích xử lý nếu chưa được đồng ý.
- Dữ liệu trường/giáo viên cần phân quyền theo organization.
- Landing page và app phải nêu rõ AI hỗ trợ, giáo viên chịu trách nhiệm phê duyệt cuối.

## 11. KPI kinh doanh

| Giai đoạn | KPI |
| --- | --- |
| MVP demo | 1 demo end-to-end chạy được: ảnh -> vật phẩm -> 5 thí nghiệm -> giáo án |
| Pilot | 10 trường đăng ký, 3 trường active, 30 giáo án được tạo |
| Validation | >= 70% giáo viên pilot nói sản phẩm giúp tiết kiệm thời gian |
| Sales | Ít nhất 1 trường đồng ý trả phí sau pilot |

## 12. Rủi ro kinh doanh

| Rủi ro | Tác động | Giảm thiểu |
| --- | --- | --- |
| Giáo viên không tin AI | Adoption thấp | Cho phép chỉnh sửa, giải thích lý do match |
| Nội dung không bám chương trình | Không được trường chấp nhận | Curated DB + chuyên gia duyệt |
| Chu kỳ bán cho trường dài | Chậm doanh thu | Pilot nhỏ qua giáo viên/tổ chuyên môn |
| Lo ngại an toàn | Không được dùng trong lớp | Safety policy nghiêm, loại trừ vật liệu nguy hiểm |
| Chi phí AI cao | Margin thấp | Cache kết quả, giới hạn quota, dùng matching DB trước LLM |

## 13. Quyết định business cần chốt sau

- Gói giá theo giáo viên hay theo trường.
- Có cần admin dashboard cho ban giám hiệu ngay trong MVP không.
- Quy trình kiểm duyệt nội dung cần chuyên gia giáo dục nội bộ hay đối tác bên ngoài.
- Dữ liệu ảnh có được dùng để cải thiện model sau khi ẩn danh hay không.
