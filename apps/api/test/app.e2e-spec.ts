import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { NestExpressApplication } from '@nestjs/platform-express';
import request from 'supertest';
import { App } from 'supertest/types';
import {
  type AnalyzeMaterialImagesInput,
  MATERIAL_VISION_PROVIDER,
  type MaterialVisionProvider,
} from './../src/ai/material-vision.types';
import { AppModule } from './../src/app.module';
import { configureApp, SCAN_ANALYZE_JSON_BODY_LIMIT_ENV } from './../src/main';

describe('AppController (e2e)', () => {
  type CreateScanResponseBody = {
    id: string;
  };

  type AnalyzeScanResponseBody = {
    id: string;
    status: string;
    detectedItems: unknown[];
  };

  let app: INestApplication<App>;
  let analyzeMaterials: jest.MockedFunction<
    MaterialVisionProvider['analyzeMaterials']
  >;
  let analyzeMaterialsInput: AnalyzeMaterialImagesInput | undefined;
  let aiVisionProvider: MaterialVisionProvider;

  beforeEach(async () => {
    analyzeMaterials = jest.fn<MaterialVisionProvider['analyzeMaterials']>();
    analyzeMaterials.mockResolvedValue({
      items: [
        {
          canonicalName: 'plastic_bottle',
          confidence: 0.91,
          displayName: 'Plastic bottle',
          evidence: 'AI test response from uploaded image.',
          quantityEstimate: 1,
          rawLabel: 'plastic bottle',
          safetyFlags: [],
          unit: 'piece',
        },
      ],
      message: null,
      noMaterialsDetected: false,
    });
    aiVisionProvider = {
      modelName: 'test-ai-vision-model',
      providerName: 'test-ai-vision',
      analyzeMaterials: (input) => {
        analyzeMaterialsInput = input;
        return analyzeMaterials(input);
      },
    };

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(MATERIAL_VISION_PROVIDER)
      .useValue(aiVisionProvider)
      .compile();

    app = moduleFixture.createNestApplication({ logger: false });
    await app.init();
  });

  it('/ (GET)', () => {
    return request(app.getHttpServer())
      .get('/')
      .expect(200)
      .expect('Hello World!');
  });

  it('serves experiment detail for the mobile experiment route', () => {
    return request(app.getHttpServer())
      .get('/experiments/bottle-fountain-air-pressure')
      .expect(200)
      .expect(({ body }) => {
        expect(body).toMatchObject({
          estimatedMinutes: 20,
          id: 'bottle-fountain-air-pressure',
          safetyCategory: 'LOW',
          title: 'Bottle Fountain Air Pressure',
        });
      });
  });

  it('analyzes scan images with the configured AI vision provider', async () => {
    const imageBase64 = Buffer.from('fake-image').toString('base64');
    const createResponse = await request(app.getHttpServer())
      .post('/inventory/scans')
      .send({
        classLabel: '8A',
        gradeBand: 'Grade 8',
        subject: 'Physics',
        topic: 'Forces',
      })
      .expect(201);
    const createBody = createResponse.body as unknown as CreateScanResponseBody;

    await request(app.getHttpServer())
      .post(`/inventory/scans/${createBody.id}/analyze`)
      .send({
        images: [
          {
            dataBase64: imageBase64,
            mimeType: 'image/jpeg',
          },
        ],
      })
      .expect(201)
      .expect((response) => {
        const body = response.body as unknown as AnalyzeScanResponseBody;
        expect(body).toMatchObject({
          id: createBody.id,
          status: 'NEEDS_CONFIRMATION',
        });
        expect(body.detectedItems).toHaveLength(1);
        expect(body.detectedItems[0]).toMatchObject({
          canonicalName: 'plastic_bottle',
          confidence: 0.91,
          displayName: 'Plastic bottle',
          evidence: ['AI test response from uploaded image.'],
          quantityEstimate: 1,
          rawLabel: 'plastic bottle',
          safetyFlags: [],
          unit: 'piece',
        });
      });

    expect(analyzeMaterials).toHaveBeenCalledTimes(1);
    expect(analyzeMaterialsInput).toBeDefined();
    const requestInput = analyzeMaterialsInput as AnalyzeMaterialImagesInput;
    expect(requestInput.images).toEqual([
      {
        dataBase64: imageBase64,
        mimeType: 'image/jpeg',
      },
    ]);
    expect(requestInput.catalog).toEqual(
      expect.arrayContaining([
        expect.objectContaining({ canonicalName: 'plastic_bottle' }),
      ]),
    );
  });

  it('rejects oversized scan analysis JSON payloads with the configured body limit', async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    const limitedApp =
      moduleFixture.createNestApplication<NestExpressApplication>({
        bodyParser: false,
        logger: false,
      });

    configureApp(
      limitedApp,
      new ConfigService({ [SCAN_ANALYZE_JSON_BODY_LIMIT_ENV]: '1kb' }),
    );
    await limitedApp.init();

    try {
      await request(limitedApp.getHttpServer())
        .post('/inventory/scans/scan-1/analyze')
        .send({
          images: [
            {
              mimeType: 'image/jpeg',
              dataBase64: 'a'.repeat(2_000),
            },
          ],
        })
        .expect(413);
    } finally {
      await limitedApp.close();
    }
  });

  afterEach(async () => {
    await app.close();
  });
});
