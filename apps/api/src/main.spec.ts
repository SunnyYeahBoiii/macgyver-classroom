import { ConfigService } from '@nestjs/config';
import { ValidationPipe } from '@nestjs/common';
import type { NestExpressApplication } from '@nestjs/platform-express';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import {
  configureApp,
  createNestApplication,
  DEFAULT_CORS_ORIGINS,
  DEFAULT_SCAN_ANALYZE_JSON_BODY_LIMIT,
  resolveCorsOrigins,
  resolveScanAnalyzeJsonBodyLimit,
  CORS_ORIGINS_ENV,
  SCAN_ANALYZE_JSON_BODY_LIMIT_ENV,
} from './main';

describe('main bootstrap configuration', () => {
  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('configures a bounded default JSON body limit for scan analysis payloads', () => {
    const configService = new ConfigService();

    expect(resolveScanAnalyzeJsonBodyLimit(configService)).toBe(
      DEFAULT_SCAN_ANALYZE_JSON_BODY_LIMIT,
    );
  });

  it('allows the JSON body limit to be overridden through env config', () => {
    const configService = new ConfigService({
      [SCAN_ANALYZE_JSON_BODY_LIMIT_ENV]: '20mb',
    });

    expect(resolveScanAnalyzeJsonBodyLimit(configService)).toBe('20mb');
  });

  it('defaults CORS to localhost app origins for Flutter web development', () => {
    const configService = new ConfigService();

    expect(resolveCorsOrigins(configService)).toEqual(DEFAULT_CORS_ORIGINS);
  });

  it('allows CORS origins to be overridden through env config', () => {
    const configService = new ConfigService({
      [CORS_ORIGINS_ENV]: 'https://pilot.test, http://localhost:63849 ',
    });

    expect(resolveCorsOrigins(configService)).toEqual([
      'https://pilot.test',
      'http://localhost:63849',
    ]);
  });

  it('enables DTO validation globally before requests reach controllers', () => {
    const app = {
      enableCors: jest.fn(),
      useBodyParser: jest.fn(),
      useGlobalPipes: jest.fn(),
    };
    const configService = new ConfigService();

    configureApp(app as never, configService);

    expect(app.useBodyParser).toHaveBeenCalledWith('json', {
      limit: DEFAULT_SCAN_ANALYZE_JSON_BODY_LIMIT,
    });
    expect(app.useBodyParser).toHaveBeenCalledWith('urlencoded', {
      extended: true,
      limit: DEFAULT_SCAN_ANALYZE_JSON_BODY_LIMIT,
    });
    expect(app.enableCors).toHaveBeenCalledWith({
      origin: DEFAULT_CORS_ORIGINS,
    });
    expect(app.useGlobalPipes).toHaveBeenCalledWith(expect.any(ValidationPipe));
  });

  it('disables Nest default body parser so the custom scan payload limit applies', async () => {
    const app = {} as NestExpressApplication;
    const createSpy = jest.spyOn(NestFactory, 'create').mockResolvedValue(app);

    await expect(createNestApplication()).resolves.toBe(app);

    expect(createSpy).toHaveBeenCalledWith(AppModule, { bodyParser: false });
  });
});
