import { Type } from 'class-transformer';
import { IsInt, IsOptional, IsString, Max, Min } from 'class-validator';

export class GenerateLessonDto {
  @IsString()
  scanId!: string;

  @IsString()
  experimentId!: string;

  @IsOptional()
  @IsString()
  lessonTopic?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(5)
  @Max(120)
  durationMinutes?: number;

  @IsOptional()
  @IsString()
  teacherNotes?: string;
}
