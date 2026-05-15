import { Module } from '@nestjs/common';
import { AiRepository } from './ai.repository';
import { AiRunService } from './ai-run.service';
import { ModelApiClient } from './model-api.client';
import { PromptVersionService } from './prompt-version.service';

@Module({
  providers: [AiRepository, AiRunService, ModelApiClient, PromptVersionService],
  exports: [AiRunService, PromptVersionService],
})
export class AiModule {}
