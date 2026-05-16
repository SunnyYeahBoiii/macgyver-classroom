export enum AiPipeline {
  VISION_CATALOG = 'VISION_CATALOG',
  PROPERTY_MAPPING = 'PROPERTY_MAPPING',
  EXPERIMENT_MATCHING = 'EXPERIMENT_MATCHING',
  LESSON_GENERATION = 'LESSON_GENERATION',
  SAFETY_CHECK = 'SAFETY_CHECK',
}

export enum ContentStatus {
  DRAFT = 'DRAFT',
  IN_REVIEW = 'IN_REVIEW',
  PUBLISHED = 'PUBLISHED',
  DISABLED = 'DISABLED',
  ARCHIVED = 'ARCHIVED',
}

export class AiPromptVersion {
  id: string;
  pipeline: AiPipeline;
  version: string;
  status: ContentStatus;
  promptHash: string;
  schemaJson?: Record<string, any>;
  notes?: string;
  publishedAt?: Date;
  createdAt: Date;
  updatedAt: Date;

  constructor(partial: Partial<AiPromptVersion>) {
    Object.assign(this, partial);
  }
}

// Made with Bob
