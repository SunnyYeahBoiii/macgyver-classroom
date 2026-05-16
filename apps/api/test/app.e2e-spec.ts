import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { NestExpressApplication } from '@nestjs/platform-express';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { configureApp, SCAN_ANALYZE_JSON_BODY_LIMIT_ENV } from './../src/main';

describe('AppController (e2e)', () => {
  let app: INestApplication<App>;

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication({ logger: false });
    await app.init();
  });

  it('/ (GET)', () => {
    return request(app.getHttpServer())
      .get('/')
      .expect(200)
      .expect('Hello World!');
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
