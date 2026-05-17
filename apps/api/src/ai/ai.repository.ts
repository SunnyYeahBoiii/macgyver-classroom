import { Injectable } from '@nestjs/common';
import { randomUUID } from 'node:crypto';

export type AiRunRecord = {
  id: string;
  pipeline: string;
  status: 'RUNNING' | 'SUCCEEDED' | 'FAILED';
  provider?: string;
  model?: string;
  inventoryScanId?: string;
  lessonPlanId?: string;
  inputJson?: unknown;
  outputJson?: unknown;
  errorCode?: string;
  errorMessage?: string;
  startedAt: Date;
  completedAt?: Date;
  durationMs?: number;
};

@Injectable()
export class AiRepository {
  private readonly runs = new Map<string, AiRunRecord>();

  createRun(
    input: Omit<AiRunRecord, 'id' | 'startedAt' | 'status'>,
  ): AiRunRecord {
    const run: AiRunRecord = {
      ...input,
      id: randomUUID(),
      startedAt: new Date(),
      status: 'RUNNING',
    };
    this.runs.set(run.id, run);
    return run;
  }

  completeRun(id: string, outputJson: unknown): AiRunRecord | undefined {
    const run = this.runs.get(id);
    if (!run) return undefined;
    const completedAt = new Date();
    const next: AiRunRecord = {
      ...run,
      completedAt,
      durationMs: completedAt.getTime() - run.startedAt.getTime(),
      outputJson,
      status: 'SUCCEEDED',
    };
    this.runs.set(id, next);
    return next;
  }

  failRun(
    id: string,
    errorCode: string,
    errorMessage: string,
  ): AiRunRecord | undefined {
    const run = this.runs.get(id);
    if (!run) return undefined;
    const completedAt = new Date();
    const next: AiRunRecord = {
      ...run,
      completedAt,
      durationMs: completedAt.getTime() - run.startedAt.getTime(),
      errorCode,
      errorMessage,
      status: 'FAILED',
    };
    this.runs.set(id, next);
    return next;
  }

  findRun(id: string): AiRunRecord | undefined {
    return this.runs.get(id);
  }
}
