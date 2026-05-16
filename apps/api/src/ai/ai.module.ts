import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AiRepository } from './ai.repository';
import { AiRunService } from './ai-run.service';
import { MATERIAL_VISION_PROVIDER } from './material-vision.types';
import { ModelApiClient } from './model-api.client';
import { PromptVersionService } from './prompt-version.service';

@Module({
  imports: [ConfigModule],
  providers: [
    AiRepository,
    AiRunService,
    ModelApiClient,
    PromptVersionService,
    { provide: MATERIAL_VISION_PROVIDER, useExisting: ModelApiClient },
  ],
  exports: [AiRunService, MATERIAL_VISION_PROVIDER, PromptVersionService],
})
export class AiModule {}
