# AI Module

## Overview

The AI module provides the foundation for all AI-powered features in MacGyver Classroom, including vision catalog, property mapping, experiment matching, lesson generation, and safety checks.

## Architecture

### Core Components

#### 1. ModelApiClient
Provider abstraction layer for AI model APIs with:
- Multi-provider support (Gemini, OpenAI, etc.)
- Automatic retry logic with exponential backoff
- Error normalization and sanitization
- Request/response type safety

```typescript
const response = await modelApiClient.generateContentWithRetry({
  pipeline: AiPipeline.VISION_CATALOG,
  prompt: 'Analyze this classroom image',
  images: [base64Image],
});
```

#### 2. AiRunService
AI execution logging and observability:
- Track all AI operations with metadata
- Monitor success/failure rates
- Calculate average latency
- Query runs by pipeline, user, organization
- Automatic cleanup of old runs

```typescript
// Create AI run
const run = await aiRunService.create({
  pipeline: AiPipeline.VISION_CATALOG,
  userId: 'user-id',
  promptVersionId: 'prompt-v1',
});

// Mark as started
await aiRunService.markStarted(run.id, 'gemini', 'gemini-pro-vision');

// Mark as succeeded
await aiRunService.markSucceeded(run.id, outputJson, {
  durationMs: 1500,
});
```

#### 3. PromptVersionService
Prompt version management:
- Create and track prompt versions
- Publish/disable/archive versions
- Get latest published version per pipeline
- Track prompt changes via hash

```typescript
// Create new prompt version
const version = await promptVersionService.create({
  pipeline: AiPipeline.VISION_CATALOG,
  version: 'v1.2.0',
  promptText: 'Your prompt here',
  schemaJson: { /* expected output schema */ },
});

// Get latest published
const latest = await promptVersionService.getLatestPublished(
  AiPipeline.VISION_CATALOG
);
```

#### 4. GeminiVisionService
Vision analysis implementation using Vertex AI:
- Analyze classroom images
- Detect objects with confidence scores
- Extract canonical names and quantities
- Safety flag detection
- Structured JSON output

```typescript
const result = await geminiVisionService.analyzeClassroomImages(
  [base64Image],
  {
    grade: '5',
    subject: 'Physics',
    topic: 'Simple Machines',
  }
);
```

## Entities

### AiRun
Tracks individual AI execution:
- Pipeline type (vision, matching, generation, etc.)
- Status (queued, running, succeeded, failed)
- Provider and model metadata
- Input/output JSON
- Error details
- Timing information

### AiPromptVersion
Manages prompt versions:
- Pipeline association
- Version string
- Status (draft, published, disabled)
- Prompt hash for change tracking
- Schema definition
- Publish timestamp

## Pipelines

The module supports these AI pipelines:

1. **VISION_CATALOG** - Image analysis and object detection
2. **PROPERTY_MAPPING** - Material property extraction
3. **EXPERIMENT_MATCHING** - Experiment recommendation
4. **LESSON_GENERATION** - Lesson plan creation
5. **SAFETY_CHECK** - Safety validation

## Error Handling

All errors are normalized to `ModelError` format:
- `code`: Error category (RATE_LIMIT, TIMEOUT, AUTH_ERROR, etc.)
- `message`: Sanitized error message (no secrets)
- `retryable`: Whether the operation can be retried
- `provider`: Which provider failed

## Testing

Comprehensive test coverage for:
- ModelApiClient provider abstraction and retry logic
- AiRunService CRUD and statistics
- GeminiVisionService parsing and validation
- Error normalization and sanitization

Run tests:
```bash
npm test src/ai
```

## Usage Example

```typescript
import { AiRunService, ModelApiClient, AiPipeline } from './ai';

// 1. Create AI run for tracking
const run = await aiRunService.create({
  pipeline: AiPipeline.VISION_CATALOG,
  userId: user.id,
  inventoryScanId: scan.id,
});

try {
  // 2. Mark as started
  await aiRunService.markStarted(run.id, 'gemini', 'gemini-pro-vision');

  // 3. Generate content
  const response = await modelApiClient.generateContentWithRetry({
    pipeline: AiPipeline.VISION_CATALOG,
    prompt: buildPrompt(),
    images: [imageData],
  });

  // 4. Mark as succeeded
  await aiRunService.markSucceeded(run.id, response, {
    durationMs: Date.now() - startTime,
  });

  return response;
} catch (error) {
  // 5. Mark as failed
  await aiRunService.markFailed(
    run.id,
    error.code,
    error.message,
    Date.now() - startTime
  );
  throw error;
}
```

## Configuration

Required environment variables:
- `USE_GOOGLE_ADC=true` - Enable Vertex AI
- `GOOGLE_CLOUD_PROJECT` - GCP project ID
- `GOOGLE_APPLICATION_CREDENTIALS` - Path to service account JSON

## Next Steps (PHONG-02 onwards)

1. **Vision Scan Analysis Pipeline** - Complete integration with inventory scans
2. **Property Mapping** - Connect detected items to canonical materials
3. **Safety Guardrails** - Implement safety checking engine
4. **Experiment Matching** - Build recommendation engine
5. **Lesson Generation** - Implement structured lesson creation
6. **Observability** - Add fixtures, deterministic mode, and analytics integration

## Related Documentation

- [Vision Catalog PRD](../../../../features/03-vision-catalog-prd.md)
- [Lesson Generation PRD](../../../../features/06-lesson-plan-generation-prd.md)
- [Safety Guardrails PRD](../../../../features/09-safety-quality-guardrails-prd.md)
- [Analytics PRD](../../../../features/12-analytics-feedback-prd.md)