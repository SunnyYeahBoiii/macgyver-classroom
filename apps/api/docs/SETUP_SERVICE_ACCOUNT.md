# Hướng dẫn cài đặt Service Account để chạy Gemini AI

## Bước 1: Nhận file service-account.json

Liên hệ với quản trị viên để nhận file `service-account.json` cho dự án.

## Bước 2: Đặt file vào thư mục config

1. Tạo thư mục `config` ở root của project (nếu chưa có):
   ```bash
   mkdir config
   ```

2. Đặt file `service-account.json` vào thư mục `config/`:
   ```
   macgyver-classroom/
   └── config/
       └── service-account.json
   ```

## Bước 3: Cấu hình biến môi trường

Đảm bảo file `.env` có các biến sau:

```env
# AI Configuration - Google Vertex AI
USE_GOOGLE_ADC=true
GOOGLE_APPLICATION_CREDENTIALS=./config/service-account.json
GOOGLE_CLOUD_PROJECT=macgyver-classroom
```

## Bước 4: Khởi động ứng dụng

```bash
# Cài đặt dependencies
bun install

# Chạy API server
bun run dev
```

## Kiểm tra

API sẽ tự động kết nối với Gemini AI model `gemini-3.1-flash-lite` khi khởi động.

Kiểm tra logs để xác nhận:
```
[GeminiVisionService] Initializing Vertex AI with Service Account
[GeminiVisionService] Project ID: macgyver-classroom
[GeminiVisionService] Vertex AI initialized successfully
```

## Lưu ý bảo mật

⚠️ **QUAN TRỌNG**: 
- File `service-account.json` chứa thông tin nhạy cảm
- KHÔNG commit file này lên Git
- File đã được thêm vào `.gitignore`
- Chỉ chia sẻ file này qua kênh bảo mật