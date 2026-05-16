# Google Application Default Credentials (ADC) Setup

## Overview

Application Default Credentials (ADC) là phương thức xác thực tự động của Google Cloud cho phép ứng dụng sử dụng credentials mà không cần hardcode API keys. Đây là best practice cho production environments.

> **💡 Chia sẻ Service Account cho Team?**
> Nếu bạn muốn dùng GCP account của mình để trả phí nhưng cho phép team deploy, xem hướng dẫn chi tiết tại [Service Account Sharing Guide](./SERVICE_ACCOUNT_SHARING.md)

## So sánh API Key vs ADC

| Aspect | API Key | Application Default Credentials |
|--------|---------|--------------------------------|
| **Use Case** | Development, testing | Production, staging |
| **Security** | Lower (key in code/env) | Higher (managed by GCP) |
| **Rotation** | Manual | Automatic |
| **Cost Tracking** | Limited | Full GCP billing integration |
| **Setup Complexity** | Simple | Moderate |
| **Best For** | Quick start, demos | Production deployments |

## Khi nào dùng ADC?

**Nên dùng ADC khi:**
- Deploy trên Google Cloud (Cloud Run, GKE, Compute Engine)
- Cần quản lý credentials tập trung
- Yêu cầu bảo mật cao
- Cần audit logs chi tiết
- Muốn tích hợp với IAM policies

**Nên dùng API Key khi:**
- Development local
- Prototype nhanh
- Deploy trên non-GCP platforms (AWS, Azure, on-premise)
- Cần setup đơn giản

## Setup ADC

### Method 1: Local Development với gcloud CLI

**Bước 1: Cài đặt gcloud CLI**

```bash
# Windows
# Download từ: https://cloud.google.com/sdk/docs/install

# macOS
brew install --cask google-cloud-sdk

# Linux
curl https://sdk.cloud.google.com | bash
```

**Bước 2: Authenticate**

```bash
# Login với Google account
gcloud auth login

# Set default project
gcloud config set project YOUR_PROJECT_ID

# Create application default credentials
gcloud auth application-default login
```

**Bước 3: Verify credentials**

```bash
# Check current credentials
gcloud auth list

# Test API access
gcloud ai models list --region=us-central1
```

**Bước 4: Configure .env**

```bash
# Enable ADC
USE_GOOGLE_ADC=true
GOOGLE_CLOUD_PROJECT=your-project-id

# Remove or comment out API key
# GEMINI_API_KEY=...
```

### Method 2: Service Account (Production)

**Bước 1: Tạo Service Account**

```bash
# Create service account
gcloud iam service-accounts create macgyver-api \
    --display-name="MacGyver Classroom API"

# Grant necessary permissions
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:macgyver-api@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/aiplatform.user"
```

**Bước 2: Tạo và download key**

```bash
# Create key file
gcloud iam service-accounts keys create ~/macgyver-sa-key.json \
    --iam-account=macgyver-api@YOUR_PROJECT_ID.iam.gserviceaccount.com

# IMPORTANT: Keep this file secure!
chmod 600 ~/macgyver-sa-key.json
```

**Bước 3: Set environment variable**

```bash
# Linux/macOS
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/macgyver-sa-key.json"

# Windows PowerShell
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\macgyver-sa-key.json"

# Or add to .env
GOOGLE_APPLICATION_CREDENTIALS=/path/to/macgyver-sa-key.json
```

**Bước 4: Configure application**

```bash
USE_GOOGLE_ADC=true
GOOGLE_CLOUD_PROJECT=your-project-id
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json
```

### Method 3: Cloud Run / GKE (Automatic)

Khi deploy trên Google Cloud, ADC tự động hoạt động:

**Cloud Run:**
```bash
# Deploy với default service account
gcloud run deploy macgyver-api \
    --image gcr.io/YOUR_PROJECT/macgyver-api \
    --platform managed \
    --region us-central1

# Service account tự động có credentials
```

**GKE:**
```yaml
# kubernetes deployment
apiVersion: v1
kind: Pod
metadata:
  name: macgyver-api
spec:
  serviceAccountName: macgyver-api-sa
  containers:
  - name: api
    image: gcr.io/YOUR_PROJECT/macgyver-api
    env:
    - name: USE_GOOGLE_ADC
      value: "true"
    - name: GOOGLE_CLOUD_PROJECT
      value: "your-project-id"
```

## Code Implementation

Service đã được update để support cả API Key và ADC:

```typescript
// apps/api/src/ai/gemini-vision.service.ts
private initializeGemini() {
  const apiKey = this.configService.get<string>('GEMINI_API_KEY');
  const useADC = this.configService.get<string>('USE_GOOGLE_ADC') === 'true';
  const projectId = this.configService.get<string>('GOOGLE_CLOUD_PROJECT');

  if (apiKey) {
    // Method 1: API Key
    this.genAI = new GoogleGenerativeAI(apiKey);
  } else if (useADC && projectId) {
    // Method 2: ADC
    const auth = new GoogleAuth({
      scopes: ['https://www.googleapis.com/auth/cloud-platform'],
    });
    this.genAI = new GoogleGenerativeAI({ auth, projectId });
  }
}
```

## Testing ADC Setup

**Test 1: Verify credentials**

```bash
# Check if ADC is configured
gcloud auth application-default print-access-token

# Should return an access token
```

**Test 2: Test API call**

```bash
# Start your API
bun run dev

# Check logs for initialization message
# Should see: "Initializing Gemini with Application Default Credentials"
```

**Test 3: Make API request**

```bash
curl -X POST http://localhost:3000/inventory/scans/test/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "scanId": "test",
    "images": [{
      "data": "base64_image_data",
      "mimeType": "image/jpeg"
    }]
  }'
```

## Troubleshooting

### Error: "Could not load the default credentials"

**Nguyên nhân:** ADC chưa được setup

**Giải pháp:**
```bash
gcloud auth application-default login
```

### Error: "Permission denied"

**Nguyên nhân:** Service account thiếu quyền

**Giải pháp:**
```bash
# Grant AI Platform User role
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:YOUR_SA@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/aiplatform.user"
```

### Error: "Project not found"

**Nguyên nhân:** GOOGLE_CLOUD_PROJECT không đúng

**Giải pháp:**
```bash
# Check current project
gcloud config get-value project

# Set correct project
gcloud config set project YOUR_PROJECT_ID
```

### ADC không hoạt động trên Windows

**Giải pháp:**
```powershell
# Set environment variable in PowerShell
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\key.json"

# Or add to system environment variables
# System Properties > Environment Variables > New
```

## Security Best Practices

### 1. Service Account Keys

```bash
# ❌ NEVER commit service account keys to git
echo "*.json" >> .gitignore
echo "service-account-*.json" >> .gitignore

# ✅ Store keys securely
# - Use secret managers (GCP Secret Manager, HashiCorp Vault)
# - Rotate keys regularly
# - Use least privilege principle
```

### 2. IAM Permissions

```bash
# ✅ Grant minimal permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="serviceAccount:SA@PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/aiplatform.user"

# ❌ Avoid overly broad permissions
# Don't use roles/owner or roles/editor
```

### 3. Key Rotation

```bash
# Create new key
gcloud iam service-accounts keys create new-key.json \
    --iam-account=SA@PROJECT_ID.iam.gserviceaccount.com

# Update application to use new key
# Test thoroughly

# Delete old key
gcloud iam service-accounts keys delete KEY_ID \
    --iam-account=SA@PROJECT_ID.iam.gserviceaccount.com
```

### 4. Audit Logging

```bash
# Enable audit logs
gcloud logging read "resource.type=service_account" \
    --limit 50 \
    --format json
```

## Cost Considerations

ADC sử dụng GCP billing:

- **Gemini API calls:** Charged per request
- **Storage:** Minimal for credentials
- **Monitoring:** Optional Cloud Monitoring costs

**Theo dõi chi phí:**
```bash
# View current month costs
gcloud billing accounts list
gcloud billing projects describe PROJECT_ID
```

## Migration từ API Key sang ADC

**Bước 1: Setup ADC song song**

```bash
# Keep API key working
GEMINI_API_KEY=existing_key

# Add ADC config
USE_GOOGLE_ADC=false  # Start with false
GOOGLE_CLOUD_PROJECT=your-project-id
```

**Bước 2: Test ADC**

```bash
# Enable ADC in staging
USE_GOOGLE_ADC=true

# Test thoroughly
# Monitor logs and errors
```

**Bước 3: Switch production**

```bash
# After successful testing
USE_GOOGLE_ADC=true
# Remove GEMINI_API_KEY from production .env
```

## References

- [Google Cloud ADC Documentation](https://cloud.google.com/docs/authentication/application-default-credentials)
- [Service Account Best Practices](https://cloud.google.com/iam/docs/best-practices-service-accounts)
- [Gemini API Authentication](https://ai.google.dev/gemini-api/docs/oauth)
- [gcloud CLI Reference](https://cloud.google.com/sdk/gcloud/reference)

## Support

Nếu gặp vấn đề với ADC setup:
1. Check gcloud CLI version: `gcloud version`
2. Verify project access: `gcloud projects list`
3. Test credentials: `gcloud auth application-default print-access-token`
4. Review IAM permissions in GCP Console
5. Check application logs for detailed error messages