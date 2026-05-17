export class LessonPlan {
  id!: string;
  title!: string;
  gradeBand!: string;
  subject!: string;
  topic!: string;
  durationMinutes!: number;
  objectives!: string[];
  materials!: string[];
  flow!: string[];
  questions!: string[];
  assessment!: string;
  safetyNotes!: string[];
  teacherChecksRequired!: string[];
  sourceExperimentId!: string;
  sourceInventoryScanId!: string;
  aiRunId!: string;
  version!: number;
  createdAt!: string;
  updatedAt!: string;
}
