import { AiPipeline } from './ai-prompt-version.entity';

export enum AiRunStatus {
  QUEUED = 'QUEUED',
  RUNNING = 'RUNNING',
  SUCCEEDED = 'SUCCEEDED',
  FAILED = 'FAILED',
  CANCELLED = 'CANCELLED',
}

export interface AiRunMetadata {
  provider?: string;
  model?: string;
  modelVersion?: string;
  inputTokens?: number;
  outputTokens?: number;
  totalTokens?: number;
  estimatedCost?: number;
}

export class AiRun {
  id: string;
  pipeline: AiPipeline;
  status: AiRunStatus;
  userId?: string;
  organizationId?: string;
  promptVersionId?: string;
  inventoryScanId?: string;
  experimentMatchId?: string;
  lessonPlanId?: string;
  provider?: string;
  model?: string;
  modelVersion?: string;
  inputJson?: Record<string, any>;
  outputJson?: Record<string, any>;
  errorCode?: string;
  errorMessage?: string;
  queuedAt: Date;
  startedAt?: Date;
  completedAt?: Date;
  durationMs?: number;
  createdAt: Date;
  updatedAt: Date;

  constructor(partial: Partial<AiRun>) {
    Object.assign(this, partial);
  }

  /**
   * Get metadata for admin/observability display
   */
  getMetadata(): AiRunMetadata {
    return {
      provider: this.provider,
      model: this.model,
      modelVersion: this.modelVersion,
    };
  }

  /**
   * Check if run is in terminal state
   */
  isTerminal(): boolean {
    return [
      AiRunStatus.SUCCEEDED,
      AiRunStatus.FAILED,
      AiRunStatus.CANCELLED,
    ].includes(this.status);
  }

  /**
   * Check if run failed
   */
  isFailed(): boolean {
    return this.status === AiRunStatus.FAILED;
  }

  /**
   * Get safe error message for UI display (no secrets)
   */
  getSafeErrorMessage(): string | undefined {
    if (!this.errorMessage) return undefined;
    
    // Remove any potential API keys or sensitive data
    return this.errorMessage
      .replace(/api[_-]?key[s]?[:=]\s*[\w-]+/gi, 'api_key=***')
      .replace(/token[:=]\s*[\w-]+/gi, 'token=***')
      .replace(/password[:=]\s*[\w-]+/gi, 'password=***');
  }
}

// Made with Bob
