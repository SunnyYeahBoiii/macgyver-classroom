import { Module } from '@nestjs/common';
import { AiRepository } from './ai.repository';
import { AiRunService } from './ai-run.service';
import { ModelApiClient } from './model-api.client';
import { PromptVersionService } from './prompt-version.service';
import { GeminiVisionService } from './gemini-vision.service';
import { ConfigModule } from '@nestjs/config';

@Module({
  imports: [ConfigModule],
  providers: [
    AiRepository,
    AiRunService,
    ModelApiClient,
    PromptVersionService,
    GeminiVisionService,
  ],
  exports: [AiRunService, PromptVersionService, GeminiVisionService],
})
export class AiModule {}
