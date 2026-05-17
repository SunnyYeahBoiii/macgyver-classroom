import { Module } from '@nestjs/common';
import { AiModule } from '../ai/ai.module';
import { ExperimentsModule } from '../experiments/experiments.module';
import { InventoryModule } from '../inventory/inventory.module';
import { LessonGenerationService } from './lesson-generation.service';
import { LessonPlansController } from './lesson-plans.controller';
import { LessonPlansService } from './lesson-plans.service';
import { LessonVersionsController } from './lesson-versions.controller';
import { LessonsRepository } from './lessons.repository';

@Module({
  imports: [AiModule, ExperimentsModule, InventoryModule],
  controllers: [LessonPlansController, LessonVersionsController],
  providers: [LessonGenerationService, LessonPlansService, LessonsRepository],
  exports: [LessonGenerationService, LessonPlansService],
})
export class LessonsModule {}
