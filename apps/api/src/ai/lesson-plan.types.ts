import type { ExperimentTemplate } from '../experiments/entities/experiment-template.entity';
import type { ConfirmedItem } from '../inventory/entities/confirmed-item.entity';

export const LESSON_PLAN_PROVIDER = Symbol('LESSON_PLAN_PROVIDER');

export type LessonTeacherContext = {
  gradeBand?: string;
  subject?: string;
  topic?: string;
  classLabel?: string;
  lessonTopic?: string;
  durationMinutes?: number;
  teacherNotes?: string;
};

export type GenerateLessonPlanInput = {
  experiment: ExperimentTemplate;
  confirmedItems: ConfirmedItem[];
  teacherContext: LessonTeacherContext;
};

export type LessonPlanResult = {
  title: string;
  gradeBand: string;
  subject: string;
  topic: string;
  durationMinutes: number;
  objectives: string[];
  materials: string[];
  lessonFlow: string[];
  guidingQuestions: string[];
  assessment: string;
  safetyNotes: string[];
  teacherChecksRequired: string[];
};

export interface LessonPlanProvider {
  readonly modelName: string;
  readonly providerName: string;

  generateLessonPlan(input: GenerateLessonPlanInput): Promise<LessonPlanResult>;
}
