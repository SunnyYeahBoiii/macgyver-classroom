# Chia sẻ Service Account cho Team

## Tình huống

Bạn muốn:
1. Sử dụng Google Cloud account của mình để trả phí Gemini API
2. Cho phép team members khác deploy và chạy ứng dụng
3. Không chia sẻ password hoặc personal credentials

## Giải pháp: Service Account

Service Account là "robot account" - một tài khoản đặc biệt không phải của con người, được tạo để ứng dụng sử dụng.

### Ưu điểm

✅ **Bảo mật:** Không cần chia sẻ personal Google account  
✅ **Kiểm soát:** Bạn quản lý quyền truy cập tập trung  
✅ **Billing:** Chi phí vẫn tính vào GCP project của bạn  
✅ **Revoke dễ dàng:** Có thể thu hồi quyền bất cứ lúc nào  
✅ **Audit:** Theo dõi được ai đang dùng service account

## Hướng dẫn Setup

### Bước 1: Tạo GCP Project (Chủ project - Bạn)

```bash
# 1. Đăng nhập vào Google Cloud Console
# https://console.cloud.google.com

# 2. Tạo project mới
# - Click "Select a project" > "New Project"
# - Tên project: macgyver-classroom
# - Project ID: macgyver-classroom-prod (hoặc tự động)

# 3. Enable Gemini API
gcloud services enable aiplatform.googleapis.com --project=macgyver-classroom-prod

# 4. Setup billing
# - Vào Billing > Link a billing account
# - Chọn billing account của bạn
```

### Bước 2: Tạo Service Account (Chủ project - Bạn)

```bash
# Tạo service account
gcloud iam service-accounts create macgyver-api \
    --display-name="MacGyver Classroom API" \
    --description="Service account for MacGyver API to access Gemini" \
    --project=macgyver-classroom-prod

# Grant quyền sử dụng AI Platform
gcloud projects add-iam-policy-binding macgyver-classroom-prod \
    --member="serviceAccount:macgyver-api@macgyver-classroom-prod.iam.gserviceaccount.com" \
    --role="roles/aiplatform.user"

# Verify
gcloud iam service-accounts list --project=macgyver-classroom-prod
```

### Bước 3: Tạo Service Account Key (Chủ project - Bạn)

```bash
# Tạo key file
gcloud iam service-accounts keys create macgyver-sa-key.json \
    --iam-account=macgyver-api@macgyver-classroom-prod.iam.gserviceaccount.com \
    --project=macgyver-classroom-prod

# File macgyver-sa-key.json được tạo
# ⚠️ QUAN TRỌNG: File này chứa credentials, cần bảo mật!
```

**Nội dung file key:**
```json
{
  "type": "service_account",
  "project_id": "macgyver-classroom-prod",
  "private_key_id": "abc123...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...",
  "client_email": "macgyver-api@macgyver-classroom-prod.iam.gserviceaccount.com",
  "client_id": "123456789",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs"
}
```

### Bước 4: Chia sẻ Key với Team (Chủ project - Bạn)

**Option 1: Secret Manager (Khuyến nghị cho production)**

```bash
# 1. Enable Secret Manager API
gcloud services enable secretmanager.googleapis.com --project=macgyver-classroom-prod

# 2. Tạo secret
gcloud secrets create macgyver-sa-key \
    --data-file=macgyver-sa-key.json \
    --project=macgyver-classroom-prod

# 3. Grant quyền cho team members
gcloud secrets add-iam-policy-binding macgyver-sa-key \
    --member="user:teammate@example.com" \
    --role="roles/secretmanager.secretAccessor" \
    --project=macgyver-classroom-prod

# Team member có thể access:
gcloud secrets versions access latest \
    --secret=macgyver-sa-key \
    --project=macgyver-classroom-prod > macgyver-sa-key.json
```

**Option 2: Secure File Sharing (Cho development)**

```bash
# Chia sẻ file qua:
# - 1Password / LastPass (shared vault)
# - Encrypted email
# - Secure file transfer service

# ❌ KHÔNG BAO GIỜ:
# - Commit vào Git
# - Gửi qua Slack/Discord không mã hóa
# - Upload lên public cloud storage
```

**Option 3: Environment Variables (CI/CD)**

```bash
# GitHub Actions Secrets
# Repository Settings > Secrets > New repository secret
# Name: GCP_SA_KEY
# Value: <paste nội dung file JSON>

# GitLab CI/CD Variables
# Settings > CI/CD > Variables > Add Variable
# Key: GCP_SA_KEY
# Value: <paste nội dung file JSON>
# Protected: Yes
# Masked: Yes
```

### Bước 5: Team Member Setup (Team members)

**Local Development:**

```bash
# 1. Nhận file macgyver-sa-key.json từ chủ project

# 2. Lưu vào thư mục an toàn
mkdir -p ~/.gcp
mv macgyver-sa-key.json ~/.gcp/
chmod 600 ~/.gcp/macgyver-sa-key.json

# 3. Set environment variable
# Linux/macOS - thêm vào ~/.bashrc hoặc ~/.zshrc
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.gcp/macgyver-sa-key.json"

# Windows PowerShell - thêm vào $PROFILE
$env:GOOGLE_APPLICATION_CREDENTIALS="$HOME\.gcp\macgyver-sa-key.json"

# 4. Configure .env
USE_GOOGLE_ADC=true
GOOGLE_CLOUD_PROJECT=macgyver-classroom-prod
GOOGLE_APPLICATION_CREDENTIALS=/path/to/macgyver-sa-key.json

# 5. Test
bun run dev
# Logs should show: "Initializing Gemini with Application Default Credentials"
```

**Docker Deployment:**

```dockerfile
# Dockerfile
FROM node:20-alpine

WORKDIR /app
COPY . .

# Copy service account key
COPY macgyver-sa-key.json /app/secrets/

ENV GOOGLE_APPLICATION_CREDENTIALS=/app/secrets/macgyver-sa-key.json
ENV USE_GOOGLE_ADC=true
ENV GOOGLE_CLOUD_PROJECT=macgyver-classroom-prod

RUN npm install
CMD ["npm", "start"]
```

```bash
# Build và run
docker build -t macgyver-api .
docker run -p 3000:3000 macgyver-api
```

**Cloud Run Deployment:**

```bash
# Deploy với service account key
gcloud run deploy macgyver-api \
    --image gcr.io/macgyver-classroom-prod/api \
    --platform managed \
    --region us-central1 \
    --set-env-vars="USE_GOOGLE_ADC=true,GOOGLE_CLOUD_PROJECT=macgyver-classroom-prod" \
    --service-account=macgyver-api@macgyver-classroom-prod.iam.gserviceaccount.com

# Không cần GOOGLE_APPLICATION_CREDENTIALS vì Cloud Run tự động inject
```

## Quản lý và Bảo mật

### Kiểm tra ai đang dùng Service Account

```bash
# Xem audit logs
gcloud logging read "protoPayload.authenticationInfo.principalEmail=macgyver-api@macgyver-classroom-prod.iam.gserviceaccount.com" \
    --limit 50 \
    --format json \
    --project=macgyver-classroom-prod
```

### Rotate Service Account Key

```bash
# 1. Tạo key mới
gcloud iam service-accounts keys create macgyver-sa-key-new.json \
    --iam-account=macgyver-api@macgyver-classroom-prod.iam.gserviceaccount.com \
    --project=macgyver-classroom-prod

# 2. Update ở tất cả environments
# - Local: Update GOOGLE_APPLICATION_CREDENTIALS
# - CI/CD: Update secrets
# - Production: Update environment variables

# 3. Test kỹ với key mới

# 4. Xóa key cũ
gcloud iam service-accounts keys list \
    --iam-account=macgyver-api@macgyver-classroom-prod.iam.gserviceaccount.com \
    --project=macgyver-classroom-prod

gcloud iam service-accounts keys delete KEY_ID \
    --iam-account=macgyver-api@macgyver-classroom-prod.iam.gserviceaccount.com \
    --project=macgyver-classroom-prod
```

### Thu hồi quyền truy cập

```bash
# Option 1: Xóa key cụ thể (nếu biết key nào bị lộ)
gcloud iam service-accounts keys delete KEY_ID \
    --iam-account=macgyver-api@macgyver-classroom-prod.iam.gserviceaccount.com \
    --project=macgyver-classroom-prod

# Option 2: Disable toàn bộ service account
gcloud iam service-accounts disable macgyver-api@macgyver-classroom-prod.iam.gserviceaccount.com \
    --project=macgyver-classroom-prod

# Option 3: Xóa service account (cẩn thận!)
gcloud iam service-accounts delete macgyver-api@macgyver-classroom-prod.iam.gserviceaccount.com \
    --project=macgyver-classroom-prod
```

### Best Practices

**✅ NÊN:**
- Rotate keys định kỳ (3-6 tháng)
- Sử dụng Secret Manager cho production
- Set expiration cho keys nếu có thể
- Monitor usage qua audit logs
- Sử dụng least privilege principle
- Có backup plan khi key bị lộ

**❌ KHÔNG NÊN:**
- Commit key vào Git
- Chia sẻ key qua chat không mã hóa
- Dùng chung key cho nhiều environments
- Để key trong public repositories
- Hardcode key trong source code

## Theo dõi Chi phí

### View Billing

```bash
# Xem chi phí hiện tại
gcloud billing accounts list

# Xem chi phí theo service
gcloud billing accounts describe BILLING_ACCOUNT_ID

# Export billing data
gcloud billing accounts export \
    --billing-account=BILLING_ACCOUNT_ID \
    --destination-uri=gs://my-billing-bucket/billing-export
```

### Set Budget Alerts

```bash
# Tạo budget alert
gcloud billing budgets create \
    --billing-account=BILLING_ACCOUNT_ID \
    --display-name="MacGyver API Budget" \
    --budget-amount=100USD \
    --threshold-rule=percent=50 \
    --threshold-rule=percent=90 \
    --threshold-rule=percent=100
```

### Monitor API Usage

```bash
# Xem API calls
gcloud logging read "resource.type=aiplatform.googleapis.com" \
    --limit 100 \
    --format json \
    --project=macgyver-classroom-prod

# Xem quota usage
gcloud services quota list \
    --service=aiplatform.googleapis.com \
    --project=macgyver-classroom-prod
```

## Troubleshooting

### Error: "Permission denied"

**Nguyên nhân:** Service account thiếu quyền

**Giải pháp:**
```bash
# Check current permissions
gcloud projects get-iam-policy macgyver-classroom-prod \
    --flatten="bindings[].members" \
    --filter="bindings.members:macgyver-api@macgyver-classroom-prod.iam.gserviceaccount.com"

# Grant missing permission
gcloud projects add-iam-policy-binding macgyver-classroom-prod \
    --member="serviceAccount:macgyver-api@macgyver-classroom-prod.iam.gserviceaccount.com" \
    --role="roles/aiplatform.user"
```

### Error: "Could not load credentials"

**Nguyên nhân:** File key không tồn tại hoặc path sai

**Giải pháp:**
```bash
# Check file exists
ls -la $GOOGLE_APPLICATION_CREDENTIALS

# Check file permissions
chmod 600 $GOOGLE_APPLICATION_CREDENTIALS

# Verify JSON format
cat $GOOGLE_APPLICATION_CREDENTIALS | jq .
```

### Error: "Quota exceeded"

**Nguyên nhân:** Vượt quá quota miễn phí

**Giải pháp:**
```bash
# Check quota
gcloud services quota list \
    --service=aiplatform.googleapis.com \
    --project=macgyver-classroom-prod

# Request quota increase
# https://console.cloud.google.com/iam-admin/quotas
```

## So sánh với API Key

| Aspect | API Key | Service Account |
|--------|---------|-----------------|
| **Setup** | Đơn giản | Phức tạp hơn |
| **Sharing** | Copy-paste key | Chia sẻ file JSON |
| **Security** | Thấp | Cao |
| **Revoke** | Xóa key | Disable SA hoặc xóa key |
| **Audit** | Hạn chế | Đầy đủ |
| **Cost Control** | Khó | Dễ (theo project) |
| **Best For** | Dev/prototype | Production/team |

## Kết luận

**Workflow tóm tắt:**

1. **Chủ project (Bạn):**
   - Tạo GCP project
   - Enable Gemini API
   - Tạo service account
   - Tạo và chia sẻ key file
   - Quản lý billing

2. **Team members:**
   - Nhận key file an toàn
   - Set GOOGLE_APPLICATION_CREDENTIALS
   - Deploy và chạy ứng dụng
   - Chi phí tự động tính vào project của bạn

3. **Bảo mật:**
   - Không commit key vào Git
   - Rotate keys định kỳ
   - Monitor usage
   - Revoke khi cần

## Tài liệu tham khảo

- [Service Account Best Practices](https://cloud.google.com/iam/docs/best-practices-service-accounts)
- [Managing Service Account Keys](https://cloud.google.com/iam/docs/creating-managing-service-account-keys)
- [Secret Manager Documentation](https://cloud.google.com/secret-manager/docs)
- [Gemini API Pricing](https://ai.google.dev/pricing)