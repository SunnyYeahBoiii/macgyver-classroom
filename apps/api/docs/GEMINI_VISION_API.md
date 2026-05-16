# Gemini Vision API Integration

## Overview

This document describes the Gemini Vision API integration for MacGyver Classroom's image scanning and object detection functionality. The system uses Google's Gemini 1.5 Flash model to analyze classroom photos and detect materials that can be used for science experiments.

## Architecture

```
Client (Mobile/Web)
    ↓ POST /inventory/scans/:id/analyze
InventoryScansController
    ↓
ScanAnalysisService
    ↓
GeminiVisionService
    ↓
Google Gemini API (gemini-1.5-flash)
```

## Components

### 1. GeminiVisionService

**Location:** `apps/api/src/ai/gemini-vision.service.ts`

Core service that interfaces with Google's Gemini API for vision analysis.

**Key Methods:**
- `analyzeClassroomImages(imageData, context)` - Analyze multiple images
- `analyzeSingleImage(imageData, mimeType, context)` - Convenience method for single image
- `parseVisionResponse(text)` - Parse and validate Gemini's JSON response
- `validateAndEnrichItems(items)` - Validate and normalize detected items

**Configuration:**
- Model: `gemini-1.5-flash`
- Temperature: 0.4 (for consistent, focused responses)
- Max Output Tokens: 4096

### 2. ScanAnalysisService

**Location:** `apps/api/src/inventory/scan-analysis.service.ts`

Orchestrates the scan analysis workflow, including AI run tracking and validation.

**Key Methods:**
- `analyzeScan(scanId, images, context)` - Main analysis workflow
- `validateDetectedItems(items)` - Quality and safety validation
- `recordAiRunStart/Complete/Failure()` - AI run metadata tracking

### 3. InventoryScansController

**Location:** `apps/api/src/inventory/inventory-scans.controller.ts`

REST API endpoints for scan operations.

**Endpoints:**
- `POST /inventory/scans/:id/analyze` - Analyze scan images
- `GET /inventory/scans/:id/status` - Get scan status
- `POST /inventory/scans` - Create new scan session

## API Usage

### Analyze Scan Images

**Endpoint:** `POST /inventory/scans/:id/analyze`

**Request Body:**
```json
{
  "scanId": "scan_123",
  "images": [
    {
      "data": "base64_encoded_image_data",
      "mimeType": "image/jpeg",
      "url": "optional_storage_url"
    }
  ],
  "grade": "5",
  "subject": "Science",
  "topic": "Pressure"
}
```

**Response:**
```json
{
  "scanId": "scan_123",
  "detectedItems": [
    {
      "raw_label": "plastic bottle",
      "canonical_name": "chai nhua",
      "quantity_estimate": 3,
      "confidence": 0.95,
      "evidence": "Three clear plastic bottles visible on desk, blue caps",
      "safety_flags": []
    },
    {
      "raw_label": "rubber band",
      "canonical_name": "day thun",
      "quantity_estimate": 10,
      "confidence": 0.88,
      "evidence": "Bundle of rubber bands in container",
      "safety_flags": []
    }
  ],
  "aiRunId": "run_scan_123_1234567890",
  "status": "success",
  "warnings": [
    "Low confidence (0.45) for item: keo dan"
  ]
}
```

**Validation Rules:**
- Maximum 10 images per scan
- Each image must have `data` and `mimeType`
- Supported formats: JPEG, PNG, WebP
- Recommended image size: < 4MB per image

## Detection Output

### Detected Item Structure

Each detected item includes:

| Field | Type | Description |
|-------|------|-------------|
| `raw_label` | string | Original English label from AI |
| `canonical_name` | string | Vietnamese classroom name |
| `quantity_estimate` | number | Estimated count (≥1) |
| `confidence` | number | Confidence score (0.0-1.0) |
| `evidence` | string | Visual evidence description |
| `safety_flags` | string[] | Safety concerns (e.g., "sharp_edges", "chemical") |

### Common Safety Flags

- `sharp_edges` - Sharp or cutting objects
- `chemical` - Chemical substances
- `heat_source` - Heat-producing items
- `electrical` - Electrical components
- `toxic` - Potentially toxic materials
- `requires_supervision` - Needs adult supervision

## Prompt Engineering

The system uses a carefully crafted prompt that:

1. **Defines the role:** Classroom materials detection assistant for Vietnamese teachers
2. **Provides context:** Grade level, subject, and topic when available
3. **Specifies output format:** Structured JSON with required fields
4. **Lists common materials:** Containers, tools, science equipment, natural items
5. **Emphasizes safety:** Requires safety flag identification
6. **Ensures consistency:** Vietnamese canonical names, bounded confidence values

### Example Prompt Structure

```
You are a classroom materials detection assistant for Vietnamese science teachers.
Analyze the provided classroom images and identify all objects that could be used 
for science experiments.

Context: Grade 5, Subject: Science, Topic: Pressure

For each detected object, provide:
1. raw_label: The object name as you see it (in English)
2. canonical_name: The Vietnamese name commonly used in classrooms
3. quantity_estimate: Estimated number of items visible
4. confidence: Your confidence level (0.0 to 1.0)
5. evidence: Brief description of what you see
6. safety_flags: Array of safety concerns or [] if safe

[... detailed instructions ...]

Return ONLY a valid JSON object in this exact format:
{
  "items": [...]
}
```

## Configuration

### Environment Variables

Add to `.env`:

```bash
# Gemini API Configuration
GEMINI_API_KEY=your_gemini_api_key_here
```

### Getting a Gemini API Key

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Create a new API key
4. Copy the key to your `.env` file

**Note:** Gemini API has a free tier with generous limits suitable for development and pilot testing.

## Authentication Methods

### Method 1: API Key (Development)

**Best for:** Local development, prototyping, quick testing

```bash
# .env configuration
GEMINI_API_KEY=your_gemini_api_key_here
USE_GOOGLE_ADC=false
```

**Getting an API Key:**
1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Create a new API key
4. Copy the key to your `.env` file

**Pros:**
- Simple setup
- No additional tools required
- Works on any platform

**Cons:**
- Less secure (key in environment)
- Manual rotation required
- Limited cost tracking

### Method 2: Application Default Credentials (Production)

**Best for:** Production deployments, staging environments, GCP-hosted applications

```bash
# .env configuration
USE_GOOGLE_ADC=true
GOOGLE_CLOUD_PROJECT=your-gcp-project-id
# Remove GEMINI_API_KEY
```

**Benefits:**
- More secure (no hardcoded keys)
- Automatic credential rotation
- Better cost tracking and billing integration
- Integrated with GCP IAM policies
- Audit logging

**Setup:**
See the comprehensive [Google ADC Setup Guide](./GOOGLE_ADC_SETUP.md) for:
- Local development with gcloud CLI
- Service account configuration
- Cloud Run / GKE automatic setup
- Troubleshooting and best practices

## Error Handling

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `GEMINI_API_KEY not configured` | Missing API key | Set `GEMINI_API_KEY` in `.env` |
| `Vision analysis failed` | API error or invalid image | Check image format and API quota |
| `Failed to parse vision response` | Invalid JSON from AI | Retry or check prompt configuration |
| `Maximum 10 images per scan` | Too many images | Split into multiple scans |

### Error Response Format

```json
{
  "scanId": "scan_123",
  "detectedItems": [],
  "status": "failed",
  "error": "Vision analysis failed: API quota exceeded"
}
```

## Testing

### Unit Tests

Run unit tests:
```bash
npm --workspace api run test
```

Test files:
- `apps/api/src/ai/gemini-vision.service.spec.ts`
- `apps/api/src/inventory/scan-analysis.service.spec.ts`

### Manual Testing

Test the API endpoint:

```bash
curl -X POST http://localhost:3000/inventory/scans/test_scan/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "scanId": "test_scan",
    "images": [{
      "data": "base64_image_data_here",
      "mimeType": "image/jpeg"
    }],
    "grade": "5",
    "subject": "Science"
  }'
```

## Performance

### Expected Performance

- **Single image analysis:** 2-5 seconds
- **Multiple images (3-5):** 5-15 seconds
- **Maximum images (10):** 15-30 seconds

### Optimization Tips

1. **Image preprocessing:** Resize images to max 1024x1024 before upload
2. **Batch processing:** Process multiple images in one request when possible
3. **Caching:** Cache results for identical images (future enhancement)
4. **Async processing:** Use background jobs for large batches (future enhancement)

## Validation and Quality

### Confidence Thresholds

- **High confidence:** ≥ 0.8 - Auto-accept
- **Medium confidence:** 0.5-0.79 - Show to teacher for review
- **Low confidence:** < 0.5 - Flag with warning

### Safety Validation

Items with safety flags are:
1. Included in results with warnings
2. Flagged for teacher review
3. Logged for content admin review
4. May trigger additional safety checks

## Future Enhancements

1. **Multi-language support:** English canonical names option
2. **Custom material database:** Teacher-specific material aliases
3. **Batch processing:** Queue system for large scans
4. **Result caching:** Cache identical image results
5. **Feedback loop:** Use teacher corrections to improve detection
6. **Alternative models:** Support for other vision models (Claude, GPT-4V)

## References

- [Gemini API Documentation](https://ai.google.dev/docs)
- [Vision Catalog PRD](../../../features/03-vision-catalog-prd.md)
- [Property Mapping PRD](../../../features/04-property-mapping-prd.md)
- [System Requirements Spec](../../../docs/macgyver-classroom-srs.md)

## Support

For issues or questions:
1. Check the error logs in the API console
2. Verify API key configuration
3. Review test cases for expected behavior
4. Consult the PRD documents for requirements