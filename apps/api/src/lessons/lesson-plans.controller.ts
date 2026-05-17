import {
  Body,
  Controller,
  Get,
  NotFoundException,
  Param,
  Post,
} from '@nestjs/common';
import { GenerateLessonDto } from './dto/generate-lesson.dto';
import type { LessonPlan } from './entities/lesson-plan.entity';
import { LessonGenerationService } from './lesson-generation.service';
import { LessonsRepository } from './lessons.repository';

@Controller('lessons')
export class LessonPlansController {
  constructor(
    private readonly lessonGenerationService: LessonGenerationService,
    private readonly lessonsRepository: LessonsRepository,
  ) {}

  @Post('generate')
  generate(@Body() dto: GenerateLessonDto): Promise<LessonPlan> {
    return this.lessonGenerationService.generate(dto);
  }

  @Get(':id')
  getLesson(@Param('id') id: string): LessonPlan {
    const lesson = this.lessonsRepository.findLesson(id);
    if (!lesson) throw new NotFoundException('Lesson plan not found.');
    return lesson;
  }
}
