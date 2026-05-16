import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { DatabaseModule } from '../database/database.module';
import { AiRepository } from './ai.repository';
import { AiRunService } from './ai-run.service';
import { ModelApiClient } from './model-api.client';
import { PromptVersionService } from './prompt-version.service';
import { GeminiVisionService } from './gemini-vision.service';

/**
 * AI Module
 *
 * Provides AI services for:
 * - Vision catalog (image analysis)
 * - Property mapping
 * - Experiment matching
 * - Lesson generation
 * - Safety checks
 *
 * Core services:
 * - ModelApiClient: Provider abstraction for AI models
 * - AiRunService: AI execution logging and observability
 * - PromptVersionService: Prompt version management
 * - GeminiVisionService: Vision analysis implementation
 */
@Module({
  imports: [ConfigModule, DatabaseModule],
  providers: [
    AiRepository,
    AiRunService,
    ModelApiClient,
    PromptVersionService,
    GeminiVisionService,
  ],
  exports: [
    AiRunService,
    ModelApiClient,
    PromptVersionService,
    GeminiVisionService,
  ],
})
export class AiModule {}
