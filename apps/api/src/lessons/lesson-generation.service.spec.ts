import { ServiceUnavailableException } from '@nestjs/common';
import { AiRunService } from '../ai/ai-run.service';
import type {
  GenerateLessonPlanInput,
  LessonPlanProvider,
} from '../ai/lesson-plan.types';
import { ExperimentsRepository } from '../experiments/experiments.repository';
import { ExperimentsService } from '../experiments/experiments.service';
import { InventoryRepository } from '../inventory/inventory.repository';
import { InventoryService } from '../inventory/inventory.service';
import { LessonGenerationService } from './lesson-generation.service';
import { LessonsRepository } from './lessons.repository';

describe('LessonGenerationService', () => {
  const createSubject = () => {
    const inventoryRepository = new InventoryRepository();
    const inventoryService = new InventoryService(inventoryRepository);
    const experimentsService = new ExperimentsService(
      new ExperimentsRepository(),
    );
    const lessonsRepository = new LessonsRepository();
    const startLessonRun = jest.fn<AiRunService['startLessonRun']>(() =>
      Promise.resolve({ id: 'ai-run-lesson-1' }),
    );
    const completeRun = jest.fn<AiRunService['completeRun']>(() =>
      Promise.resolve(undefined),
    );
    const failRun = jest.fn<AiRunService['failRun']>(() =>
      Promise.resolve(undefined),
    );
    const aiRunService = {
      startLessonRun,
      completeRun,
      failRun,
    } as unknown as AiRunService;
    const generateLessonPlan =
      jest.fn<LessonPlanProvider['generateLessonPlan']>();
    let lessonPlanRequest: GenerateLessonPlanInput | undefined;
    const provider: LessonPlanProvider = {
      generateLessonPlan: (input) => {
        lessonPlanRequest = input;
        return generateLessonPlan(input) as ReturnType<
          LessonPlanProvider['generateLessonPlan']
        >;
      },
      modelName: 'test-lesson-model',
      providerName: 'test-lesson-provider',
    };
    const service = new LessonGenerationService(
      provider,
      inventoryService,
      experimentsService,
      lessonsRepository,
      aiRunService,
    );

    return {
      aiRunService,
      completeRun,
      failRun,
      generateLessonPlan,
      getLessonPlanRequest: () => lessonPlanRequest,
      inventoryService,
      lessonsRepository,
      provider,
      service,
      startLessonRun,
    };
  };

  const confirmedPaperCupScan = (
    inventoryService: InventoryService,
  ): string => {
    const scan = inventoryService.createDraft({
      classLabel: '8A',
      gradeBand: 'Grade 8',
      subject: 'Physics',
      topic: 'Sound and vibration',
    });
    inventoryService.updateItems(scan.id, [
      {
        canonicalName: 'paper_cup',
        confidence: 0.91,
        displayName: 'Paper cup',
        evidence: ['Visible paper cup stack.'],
        quantityEstimate: 10,
        rawLabel: 'paper cup',
        safetyFlags: [],
        unit: 'pieces',
      },
      {
        canonicalName: 'paper_plate',
        confidence: 0.84,
        displayName: 'Paper plate',
        evidence: ['Round paper plates beside cup stack.'],
        quantityEstimate: 6,
        rawLabel: 'paper plate',
        safetyFlags: [],
        unit: 'pieces',
      },
      {
        canonicalName: 'wooden_fork',
        confidence: 0.81,
        displayName: 'Wooden fork',
        evidence: ['Wooden forks grouped in tray.'],
        quantityEstimate: 12,
        rawLabel: 'wooden fork',
        safetyFlags: [],
        unit: 'pieces',
      },
    ]);
    return inventoryService.confirm(scan.id).id;
  };

  it('generates and stores a structured AI lesson plan from a confirmed scan and experiment', async () => {
    const {
      completeRun,
      generateLessonPlan,
      getLessonPlanRequest,
      inventoryService,
      lessonsRepository,
      service,
      startLessonRun,
    } = createSubject();
    const scanId = confirmedPaperCupScan(inventoryService);
    generateLessonPlan.mockResolvedValue({
      assessment: 'Exit ticket: explain how the paper cup changed the sound.',
      durationMinutes: 35,
      gradeBand: 'Grade 8',
      guidingQuestions: ['What was vibrating when you heard the sound?'],
      lessonFlow: [
        'Step 1: Place the paper plate flat on the desk and set the paper cup upright at the center.',
      ],
      materials: ['Paper cup', 'Paper plate', 'Wooden fork'],
      objectives: ['Describe sound as vibration.'],
      safetyNotes: ['Use gentle tapping only.'],
      subject: 'Physics',
      teacherChecksRequired: ['Replace cracked wooden forks.'],
      title: 'Paper Cup Sound Amplifier: STEM sound tutorial',
      topic: 'Sound and vibration',
    });

    const lesson = await service.generate({
      experimentId: 'paper-cup-sound-amplifier',
      scanId,
    });

    expect(generateLessonPlan).toHaveBeenCalledTimes(1);
    const lessonRequest = getLessonPlanRequest();
    expect(lessonRequest).toBeDefined();
    const request = lessonRequest as GenerateLessonPlanInput;
    expect(request.confirmedItems).toEqual(
      expect.arrayContaining([
        expect.objectContaining({ canonicalName: 'paper_cup' }),
        expect.objectContaining({ canonicalName: 'paper_plate' }),
        expect.objectContaining({ canonicalName: 'wooden_fork' }),
      ]),
    );
    expect(request.experiment).toMatchObject({
      id: 'paper-cup-sound-amplifier',
    });
    expect(request.teacherContext).toMatchObject({
      gradeBand: 'Grade 8',
      subject: 'Physics',
      topic: 'Sound and vibration',
    });
    expect(startLessonRun).toHaveBeenCalledWith(
      expect.objectContaining({
        inventoryScanId: scanId,
        model: 'test-lesson-model',
        provider: 'test-lesson-provider',
      }),
    );
    expect(completeRun).toHaveBeenCalledWith(
      'ai-run-lesson-1',
      expect.objectContaining({
        lessonPlanId: lesson.id,
        teacherCheckCount: 1,
      }),
    );
    expect(lesson).toMatchObject({
      aiRunId: 'ai-run-lesson-1',
      durationMinutes: 35,
      flow: [
        'Step 1: Place the paper plate flat on the desk and set the paper cup upright at the center.',
      ],
      sourceExperimentId: 'paper-cup-sound-amplifier',
      sourceInventoryScanId: scanId,
      teacherChecksRequired: ['Replace cracked wooden forks.'],
      title: 'Paper Cup Sound Amplifier: STEM sound tutorial',
    });
    expect(lessonsRepository.findLesson(lesson.id)).toMatchObject({
      id: lesson.id,
      title: lesson.title,
    });
  });

  it('fails safely when the lesson AI provider fails', async () => {
    const { failRun, generateLessonPlan, inventoryService, service } =
      createSubject();
    const scanId = confirmedPaperCupScan(inventoryService);
    generateLessonPlan.mockRejectedValue(
      new Error('raw provider stack with credentials'),
    );

    await expect(
      service.generate({
        experimentId: 'paper-cup-sound-amplifier',
        scanId,
      }),
    ).rejects.toThrow(ServiceUnavailableException);

    expect(failRun).toHaveBeenCalledWith(
      'ai-run-lesson-1',
      'lesson_ai_provider_failed',
      'Lesson generation failed. Please try again.',
    );
  });
});
