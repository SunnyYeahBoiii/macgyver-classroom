import 'dotenv/config';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import type { NestExpressApplication } from '@nestjs/platform-express';
import type { CorsOptions } from '@nestjs/common/interfaces/external/cors-options.interface';
import { AppModule } from './app.module';

export const SCAN_ANALYZE_JSON_BODY_LIMIT_ENV = 'SCAN_ANALYZE_JSON_BODY_LIMIT';
export const DEFAULT_SCAN_ANALYZE_JSON_BODY_LIMIT = '16mb';
export const CORS_ORIGINS_ENV = 'CORS_ORIGINS';
export const DEFAULT_CORS_ORIGINS = [
  /^http:\/\/localhost:\d+$/,
  /^http:\/\/127\.0\.0\.1:\d+$/,
];

export function resolveScanAnalyzeJsonBodyLimit(
  configService: ConfigService,
): string {
  return configService.get<string>(
    SCAN_ANALYZE_JSON_BODY_LIMIT_ENV,
    DEFAULT_SCAN_ANALYZE_JSON_BODY_LIMIT,
  );
}

export function resolveCorsOrigins(
  configService: ConfigService,
): CorsOptions['origin'] {
  const configuredOrigins = configService.get<string>(CORS_ORIGINS_ENV, '');
  if (configuredOrigins.trim().length === 0) {
    return DEFAULT_CORS_ORIGINS;
  }
  if (configuredOrigins.trim() === '*') {
    return true;
  }
  return configuredOrigins
    .split(',')
    .map((origin) => origin.trim())
    .filter((origin) => origin.length > 0);
}

export function configureApp(
  app: NestExpressApplication,
  configService: ConfigService,
): void {
  const scanAnalyzeBodyLimit = resolveScanAnalyzeJsonBodyLimit(configService);

  app.useBodyParser('json', {
    limit: scanAnalyzeBodyLimit,
  });
  app.useBodyParser('urlencoded', {
    extended: true,
    limit: scanAnalyzeBodyLimit,
  });
  app.enableCors({
    origin: resolveCorsOrigins(configService),
  });
  app.useGlobalPipes(
    new ValidationPipe({
      forbidNonWhitelisted: true,
      transform: true,
      whitelist: true,
    }),
  );
}

export function createNestApplication(): Promise<NestExpressApplication> {
  return NestFactory.create<NestExpressApplication>(AppModule, {
    bodyParser: false,
  });
}

async function bootstrap() {
  const app = await createNestApplication();
  const configService = app.get(ConfigService);
  configureApp(app, configService);
  const port = configService.get<number>('PORT', 4000);
  await app.listen(port);
}

if (process.env.NODE_ENV !== 'test') void bootstrap();
