# MacGyver Classroom API

NestJS API for MacGyver Classroom - A classroom science assistant for teachers.

## Overview

This API provides backend services for:
- **Vision Catalog**: AI-powered classroom object detection using Gemini Vision API
- **Inventory Management**: Scan sessions and confirmed items
- **Experiment Matching**: Match available materials to experiment templates
- **Lesson Planning**: Generate structured lesson plans
- **Authentication**: Teacher accounts and session management
- **Content Administration**: Curated materials and experiments

## Tech Stack

- **Framework**: NestJS 11
- **Runtime**: Node.js 20+
- **Database**: Supabase Postgres with Prisma ORM
- **Storage**: Supabase Storage
- **AI**: Google Gemini API (gemini-1.5-flash)
- **Authentication**: JWT with Supabase Auth

## Getting Started

### Prerequisites

- Node.js 20+
- PostgreSQL (via Supabase or local)
- Gemini API key

### Installation

```bash
# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your configuration
```

### Environment Configuration

Required environment variables:

```bash
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/macgyver_classroom
DIRECT_URL=postgresql://user:password@localhost:5432/macgyver_classroom

# Supabase
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key

# AI - Gemini API
GEMINI_API_KEY=your_gemini_api_key_here

# JWT
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRES_IN=7d

# API
API_PORT=3000
NODE_ENV=development
```

### Database Setup

```bash
# Generate Prisma client
npx prisma generate

# Run migrations
npx prisma migrate deploy

# Seed database (optional)
npx prisma db seed
```

### Running the API

```bash
# Development mode with watch
npm run dev

# Production mode
npm run build
npm run start:prod

# Debug mode
npm run start:debug
```

The API will be available at `http://localhost:3000`

## API Documentation

### Core Endpoints

#### Vision & Inventory

- `POST /inventory/scans` - Create new scan session
- `POST /inventory/scans/:id/analyze` - Analyze images with Gemini Vision
- `GET /inventory/scans/:id/status` - Get scan status
- `GET /inventory/scans` - List user's scans

#### Authentication

- `POST /auth/register` - Register new teacher account
- `POST /auth/login` - Login and get JWT tokens
- `POST /auth/refresh` - Refresh access token
- `GET /auth/profile` - Get current user profile

#### Experiments

- `POST /experiments/match` - Match inventory to experiments
- `GET /experiments` - List experiment templates
- `GET /experiments/:id` - Get experiment details

#### Lesson Plans

- `POST /lesson-plans/generate` - Generate lesson plan
- `GET /lesson-plans` - List user's lesson plans
- `GET /lesson-plans/:id` - Get lesson plan details
- `POST /lesson-plans/:id/export` - Export lesson plan

### Gemini Vision API Integration

For detailed information about the vision API integration, see:
- [Gemini Vision API Documentation](./docs/GEMINI_VISION_API.md)

**Quick Example:**

```bash
curl -X POST http://localhost:3000/inventory/scans/scan_123/analyze \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "scanId": "scan_123",
    "images": [{
      "data": "base64_encoded_image",
      "mimeType": "image/jpeg"
    }],
    "grade": "5",
    "subject": "Science"
  }'
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
      "evidence": "Three clear bottles visible",
      "safety_flags": []
    }
  ],
  "status": "success"
}
```

## Project Structure

```
apps/api/
├── src/
│   ├── ai/                      # AI services (Gemini Vision)
│   │   ├── gemini-vision.service.ts
│   │   ├── ai-run.service.ts
│   │   └── dto/
│   ├── inventory/               # Inventory & scan management
│   │   ├── inventory-scans.controller.ts
│   │   ├── scan-analysis.service.ts
│   │   └── dto/
│   ├── experiments/             # Experiment matching
│   ├── lessons/                 # Lesson plan generation
│   ├── auth/                    # Authentication
│   ├── materials/               # Material catalog & properties
│   ├── safety/                  # Safety rules & checks
│   ├── config/                  # Configuration
│   ├── common/                  # Shared utilities
│   └── main.ts
├── prisma/
│   └── schema/                  # Database schemas
├── docs/                        # API documentation
├── test/                        # E2E tests
└── package.json
```

## Testing

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Test coverage
npm run test:cov

# Watch mode
npm run test:watch
```

### Test Files

- `*.spec.ts` - Unit tests
- `*.e2e-spec.ts` - End-to-end tests

Key test suites:
- [`gemini-vision.service.spec.ts`](./src/ai/gemini-vision.service.spec.ts) - Vision API tests
- [`scan-analysis.service.spec.ts`](./src/inventory/scan-analysis.service.spec.ts) - Analysis workflow tests

## Development

### Code Quality

```bash
# Linting
npm run lint

# Type checking
npm run check-types

# Format code
npm run format
```

### Module Structure

Each feature module follows NestJS best practices:

```
feature/
├── feature.module.ts           # Module definition
├── feature.controller.ts       # REST endpoints
├── feature.service.ts          # Business logic
├── feature.repository.ts       # Data access
├── dto/                        # Data transfer objects
│   ├── create-feature.dto.ts
│   └── update-feature.dto.ts
└── entities/                   # Domain entities
    └── feature.entity.ts
```

### Adding New Features

1. Generate module: `nest g module feature`
2. Generate controller: `nest g controller feature`
3. Generate service: `nest g service feature`
4. Add DTOs and validation
5. Write tests
6. Update documentation

## Deployment

### Docker

```bash
# Build image
docker build -t macgyver-api .

# Run container
docker run -p 3000:3000 --env-file .env macgyver-api
```

### Cloudflare Deployment

See [DOCKER.md](../../DOCKER.md) for deployment instructions.

## Key Features

### 1. Gemini Vision Integration

- Analyzes classroom photos to detect materials
- Returns structured data with Vietnamese names
- Includes confidence scores and safety flags
- Supports batch processing (up to 10 images)

### 2. Safety Guardrails

- Validates detected items for safety concerns
- Flags dangerous materials
- Enforces safety rules before experiment matching
- Logs all safety-related decisions

### 3. Material Property Mapping

- Maps detected items to canonical materials
- Associates materials with STEM properties
- Supports safe alternatives
- Admin-managed material database

### 4. Experiment Matching

- Scores experiments based on available materials
- Considers curriculum alignment
- Respects safety constraints
- Provides reasoning for matches

### 5. Lesson Plan Generation

- Generates structured 45-minute lesson plans
- Includes safety notes
- Aligns with Vietnamese curriculum standards
- Supports export to PDF

## Performance

### Expected Response Times

- Vision analysis (single image): 2-5 seconds
- Vision analysis (5 images): 5-15 seconds
- Experiment matching: < 1 second
- Lesson generation: 5-10 seconds

### Rate Limits

- Default: 100 requests per minute per IP
- Configurable via `RATE_LIMIT_MAX` and `RATE_LIMIT_TTL`

## Monitoring

### Health Check

```bash
curl http://localhost:3000/health
```

### Logs

Structured logging with request IDs:

```json
{
  "level": "info",
  "timestamp": "2026-05-16T14:00:00.000Z",
  "requestId": "req_abc123",
  "message": "Analyzing scan scan_123 with 3 images",
  "context": "InventoryScansController"
}
```

## Troubleshooting

### Common Issues

**1. Gemini API Key Not Configured**
```
Error: GEMINI_API_KEY not configured
Solution: Add GEMINI_API_KEY to .env file
```

**2. Database Connection Failed**
```
Error: Can't reach database server
Solution: Check DATABASE_URL and ensure PostgreSQL is running
```

**3. Vision Analysis Failed**
```
Error: Vision analysis failed: API quota exceeded
Solution: Check Gemini API quota or upgrade plan
```

### Debug Mode

Enable debug logging:

```bash
NODE_ENV=development npm run start:debug
```

## Contributing

1. Follow NestJS conventions
2. Write tests for new features
3. Update documentation
4. Run linting and type checking
5. Ensure all tests pass

## Resources

- [NestJS Documentation](https://docs.nestjs.com/)
- [Prisma Documentation](https://www.prisma.io/docs)
- [Gemini API Documentation](https://ai.google.dev/docs)
- [Supabase Documentation](https://supabase.com/docs)

## Related Documentation

- [Gemini Vision API Integration](./docs/GEMINI_VISION_API.md)
- [Vision Catalog PRD](../../features/03-vision-catalog-prd.md)
- [System Requirements](../../docs/macgyver-classroom-srs.md)
- [Project README](../../README.md)

## License

UNLICENSED - Private project
