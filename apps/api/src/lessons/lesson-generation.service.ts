import {
  BadGatewayException,
  HttpException,
  Inject,
  Injectable,
  ServiceUnavailableException,
} from '@nestjs/common';
import { AiRunService } from '../ai/ai-run.service';
import {
  LESSON_PLAN_PROVIDER,
  type LessonPlanProvider,
  type LessonPlanResult,
} from '../ai/lesson-plan.types';
import { ExperimentsService } from '../experiments/experiments.service';
import { InventoryService } from '../inventory/inventory.service';
import type { GenerateLessonDto } from './dto/generate-lesson.dto';
import type { LessonPlan } from './entities/lesson-plan.entity';
import { LessonsRepository } from './lessons.repository';

@Injectable()
export class LessonGenerationService {
  constructor(
    @Inject(LESSON_PLAN_PROVIDER)
    private readonly lessonPlanProvider: LessonPlanProvider,
    private readonly inventoryService: InventoryService,
    private readonly experimentsService: ExperimentsService,
    private readonly lessonsRepository: LessonsRepository,
    private readonly aiRunService: AiRunService,
  ) {}

  async generate(dto: GenerateLessonDto): Promise<LessonPlan> {
    const scan = this.inventoryService.getScan(dto.scanId);
    const confirmedItems = this.inventoryService.getActiveConfirmedItems(
      dto.scanId,
    );
    const experiment = this.experimentsService.getTemplate(dto.experimentId);
    const teacherContext = {
      classLabel: scan.classLabel,
      durationMinutes: dto.durationMinutes,
      gradeBand: scan.gradeBand,
      lessonTopic: dto.lessonTopic,
      subject: scan.subject,
      teacherNotes: dto.teacherNotes,
      topic: dto.lessonTopic ?? scan.topic,
    };
    const aiRun = await this.aiRunService.startLessonRun({
      inputJson: {
        confirmedItemCount: confirmedItems.length,
        experimentId: experiment.id,
        teacherContext,
      },
      inventoryScanId: scan.id,
      model: this.lessonPlanProvider.modelName,
      provider: this.lessonPlanProvider.providerName,
    });

    try {
      const result = await this.lessonPlanProvider.generateLessonPlan({
        confirmedItems,
        experiment,
        teacherContext,
      });
      this.assertUsableLesson(result);
      const lesson = this.lessonsRepository.createLesson({
        aiRunId: aiRun.id,
        assessment: result.assessment,
        durationMinutes: result.durationMinutes,
        flow: result.lessonFlow,
        gradeBand: result.gradeBand,
        materials: result.materials,
        objectives: result.objectives,
        questions: result.guidingQuestions,
        safetyNotes: result.safetyNotes,
        sourceExperimentId: experiment.id,
        sourceInventoryScanId: scan.id,
        subject: result.subject,
        teacherChecksRequired: result.teacherChecksRequired,
        title: result.title,
        topic: result.topic,
      });
      await this.aiRunService.completeRun(aiRun.id, {
        lessonPlanId: lesson.id,
        materialCount: lesson.materials.length,
        teacherCheckCount: lesson.teacherChecksRequired.length,
      });
      return lesson;
    } catch (error) {
      const errorCode = this.errorCode(error);
      const errorMessage = this.errorMessage(error);
      await this.aiRunService.failRun(aiRun.id, errorCode, errorMessage);
      if (error instanceof HttpException) throw error;
      throw new ServiceUnavailableException({
        code: errorCode,
        message: errorMessage,
      });
    }
  }

  private assertUsableLesson(result: LessonPlanResult): void {
    const requiredLists = [
      result.objectives,
      result.materials,
      result.lessonFlow,
      result.guidingQuestions,
      result.safetyNotes,
      result.teacherChecksRequired,
    ];
    if (
      !result.title.trim() ||
      !result.assessment.trim() ||
      result.durationMinutes <= 0 ||
      requiredLists.some((items) => items.length === 0)
    ) {
      throw new BadGatewayException({
        code: 'ai_invalid_lesson_plan',
        message: 'AI provider returned an incomplete lesson plan.',
      });
    }
  }

  private errorCode(error: unknown): string {
    if (error instanceof HttpException) {
      const response = error.getResponse();
      if (typeof response === 'object' && response && 'code' in response) {
        return String(response.code);
      }
    }
    return 'lesson_ai_provider_failed';
  }

  private errorMessage(error: unknown): string {
    if (error instanceof HttpException) {
      const response = error.getResponse();
      if (typeof response === 'object' && response && 'message' in response) {
        return String(response.message);
      }
      if (typeof response === 'string') return response;
    }
    return 'Lesson generation failed. Please try again.';
  }
}
