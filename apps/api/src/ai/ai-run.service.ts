import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { AiRun, AiRunStatus } from './entities/ai-run.entity';
import { AiPipeline } from './entities/ai-prompt-version.entity';

export interface CreateAiRunDto {
  pipeline: AiPipeline;
  userId?: string;
  organizationId?: string;
  promptVersionId?: string;
  inventoryScanId?: string;
  experimentMatchId?: string;
  lessonPlanId?: string;
  inputJson?: Record<string, any>;
}

export interface UpdateAiRunDto {
  status?: AiRunStatus;
  provider?: string;
  model?: string;
  modelVersion?: string;
  outputJson?: Record<string, any>;
  errorCode?: string;
  errorMessage?: string;
  startedAt?: Date;
  completedAt?: Date;
  durationMs?: number;
}

export interface AiRunFilters {
  pipeline?: AiPipeline;
  status?: AiRunStatus;
  userId?: string;
  organizationId?: string;
  inventoryScanId?: string;
  experimentMatchId?: string;
  lessonPlanId?: string;
  fromDate?: Date;
  toDate?: Date;
}

/**
 * Service for managing AI run logs
 * Handles creation, updates, and querying of AI execution records
 */
@Injectable()
export class AiRunService {
  private readonly logger = new Logger(AiRunService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Create a new AI run log
   */
  async create(dto: CreateAiRunDto): Promise<AiRun> {
    this.logger.log(`Creating AI run for pipeline: ${dto.pipeline}`);

    const aiRun = await this.prisma.aiRun.create({
      data: {
        ...dto,
        status: AiRunStatus.QUEUED,
        queuedAt: new Date(),
      },
    });

    return new AiRun(aiRun);
  }

  /**
   * Find AI run by ID
   */
  async findById(id: string): Promise<AiRun> {
    const aiRun = await this.prisma.aiRun.findUnique({
      where: { id },
      include: {
        promptVersion: true,
        user: true,
        organization: true,
      },
    });

    if (!aiRun) {
      throw new NotFoundException(`AI run not found: ${id}`);
    }

    return new AiRun(aiRun);
  }

  /**
   * Update AI run
   */
  async update(id: string, dto: UpdateAiRunDto): Promise<AiRun> {
    const aiRun = await this.prisma.aiRun.update({
      where: { id },
      data: dto,
    });

    this.logger.log(`Updated AI run: ${id} - status: ${aiRun.status}`);

    return new AiRun(aiRun);
  }

  /**
   * Mark AI run as started
   */
  async markStarted(id: string, provider: string, model: string): Promise<AiRun> {
    return this.update(id, {
      status: AiRunStatus.RUNNING,
      provider,
      model,
      startedAt: new Date(),
    });
  }

  /**
   * Mark AI run as succeeded
   */
  async markSucceeded(
    id: string,
    outputJson: Record<string, any>,
    metadata?: {
      modelVersion?: string;
      durationMs?: number;
    },
  ): Promise<AiRun> {
    const completedAt = new Date();
    
    return this.update(id, {
      status: AiRunStatus.SUCCEEDED,
      outputJson,
      modelVersion: metadata?.modelVersion,
      durationMs: metadata?.durationMs,
      completedAt,
    });
  }

  /**
   * Mark AI run as failed
   */
  async markFailed(
    id: string,
    errorCode: string,
    errorMessage: string,
    durationMs?: number,
  ): Promise<AiRun> {
    const completedAt = new Date();
    
    return this.update(id, {
      status: AiRunStatus.FAILED,
      errorCode,
      errorMessage,
      durationMs,
      completedAt,
    });
  }

  /**
   * List AI runs with filters
   */
  async list(
    filters: AiRunFilters,
    limit: number = 50,
    offset: number = 0,
  ): Promise<{ runs: AiRun[]; total: number }> {
    const where: any = {};

    if (filters.pipeline) where.pipeline = filters.pipeline;
    if (filters.status) where.status = filters.status;
    if (filters.userId) where.userId = filters.userId;
    if (filters.organizationId) where.organizationId = filters.organizationId;
    if (filters.inventoryScanId) where.inventoryScanId = filters.inventoryScanId;
    if (filters.experimentMatchId) where.experimentMatchId = filters.experimentMatchId;
    if (filters.lessonPlanId) where.lessonPlanId = filters.lessonPlanId;

    if (filters.fromDate || filters.toDate) {
      where.createdAt = {};
      if (filters.fromDate) where.createdAt.gte = filters.fromDate;
      if (filters.toDate) where.createdAt.lte = filters.toDate;
    }

    const [runs, total] = await Promise.all([
      this.prisma.aiRun.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        take: limit,
        skip: offset,
        include: {
          promptVersion: true,
        },
      }),
      this.prisma.aiRun.count({ where }),
    ]);

    return {
      runs: runs.map((run) => new AiRun(run)),
      total,
    };
  }

  /**
   * Get AI run statistics
   */
  async getStats(filters: AiRunFilters): Promise<{
    total: number;
    succeeded: number;
    failed: number;
    running: number;
    queued: number;
    avgDurationMs?: number;
  }> {
    const where: any = {};
    if (filters.pipeline) where.pipeline = filters.pipeline;
    if (filters.userId) where.userId = filters.userId;
    if (filters.organizationId) where.organizationId = filters.organizationId;
    if (filters.fromDate || filters.toDate) {
      where.createdAt = {};
      if (filters.fromDate) where.createdAt.gte = filters.fromDate;
      if (filters.toDate) where.createdAt.lte = filters.toDate;
    }

    const [total, succeeded, failed, running, queued, avgResult] = await Promise.all([
      this.prisma.aiRun.count({ where }),
      this.prisma.aiRun.count({ where: { ...where, status: AiRunStatus.SUCCEEDED } }),
      this.prisma.aiRun.count({ where: { ...where, status: AiRunStatus.FAILED } }),
      this.prisma.aiRun.count({ where: { ...where, status: AiRunStatus.RUNNING } }),
      this.prisma.aiRun.count({ where: { ...where, status: AiRunStatus.QUEUED } }),
      this.prisma.aiRun.aggregate({
        where: { ...where, status: AiRunStatus.SUCCEEDED, durationMs: { not: null } },
        _avg: { durationMs: true },
      }),
    ]);

    return {
      total,
      succeeded,
      failed,
      running,
      queued,
      avgDurationMs: avgResult._avg.durationMs ?? undefined,
    };
  }

  /**
   * Get recent failures for monitoring
   */
  async getRecentFailures(
    pipeline?: AiPipeline,
    limit: number = 10,
  ): Promise<AiRun[]> {
    const runs = await this.prisma.aiRun.findMany({
      where: {
        status: AiRunStatus.FAILED,
        ...(pipeline && { pipeline }),
      },
      orderBy: { completedAt: 'desc' },
      take: limit,
      include: {
        promptVersion: true,
      },
    });

    return runs.map((run) => new AiRun(run));
  }

  /**
   * Clean up old AI runs (for maintenance)
   */
  async cleanupOldRuns(olderThanDays: number = 90): Promise<number> {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - olderThanDays);

    const result = await this.prisma.aiRun.deleteMany({
      where: {
        createdAt: { lt: cutoffDate },
        status: { in: [AiRunStatus.SUCCEEDED, AiRunStatus.FAILED] },
      },
    });

    this.logger.log(`Cleaned up ${result.count} old AI runs`);

    return result.count;
  }

  /**
   * Get AI run by related entity
   */
  async findByInventoryScan(inventoryScanId: string): Promise<AiRun[]> {
    const runs = await this.prisma.aiRun.findMany({
      where: { inventoryScanId },
      orderBy: { createdAt: 'desc' },
    });

    return runs.map((run) => new AiRun(run));
  }

  async findByExperimentMatch(experimentMatchId: string): Promise<AiRun[]> {
    const runs = await this.prisma.aiRun.findMany({
      where: { experimentMatchId },
      orderBy: { createdAt: 'desc' },
    });

    return runs.map((run) => new AiRun(run));
  }

  async findByLessonPlan(lessonPlanId: string): Promise<AiRun[]> {
    const runs = await this.prisma.aiRun.findMany({
      where: { lessonPlanId },
      orderBy: { createdAt: 'desc' },
    });

    return runs.map((run) => new AiRun(run));
  }
}

// Made with Bob
