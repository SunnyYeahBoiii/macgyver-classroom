import { Injectable } from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import type { LessonPlan } from './entities/lesson-plan.entity';

type CreateLessonPlanInput = Omit<
  LessonPlan,
  'createdAt' | 'id' | 'updatedAt' | 'version'
> & {
  id?: string;
  version?: number;
};

@Injectable()
export class LessonsRepository {
  private readonly lessons = new Map<string, LessonPlan>();

  createLesson(input: CreateLessonPlanInput): LessonPlan {
    const now = new Date().toISOString();
    const lesson: LessonPlan = {
      ...input,
      createdAt: now,
      id: input.id ?? randomUUID(),
      updatedAt: now,
      version: input.version ?? 1,
    };
    this.lessons.set(lesson.id, lesson);
    return lesson;
  }

  findLesson(lessonId: string): LessonPlan | undefined {
    return this.lessons.get(lessonId);
  }

  listLessons(): LessonPlan[] {
    return [...this.lessons.values()];
  }
}
