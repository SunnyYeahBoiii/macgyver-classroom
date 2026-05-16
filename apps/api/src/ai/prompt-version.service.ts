import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import {
  AiPromptVersion,
  AiPipeline,
  ContentStatus,
} from './entities/ai-prompt-version.entity';
import * as crypto from 'crypto';

export interface CreatePromptVersionDto {
  pipeline: AiPipeline;
  version: string;
  promptText: string;
  schemaJson?: Record<string, any>;
  notes?: string;
}

export interface UpdatePromptVersionDto {
  status?: ContentStatus;
  notes?: string;
  schemaJson?: Record<string, any>;
}

/**
 * Service for managing AI prompt versions
 * Handles CRUD operations and prompt hash generation
 */
@Injectable()
export class PromptVersionService {
  private readonly logger = new Logger(PromptVersionService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Create a new prompt version
   */
  async create(dto: CreatePromptVersionDto): Promise<AiPromptVersion> {
    const promptHash = this.generatePromptHash(dto.promptText);

    this.logger.log(
      `Creating prompt version: ${dto.pipeline}@${dto.version}`,
    );

    const promptVersion = await this.prisma.aiPromptVersion.create({
      data: {
        pipeline: dto.pipeline,
        version: dto.version,
        promptHash,
        schemaJson: dto.schemaJson,
        notes: dto.notes,
        status: ContentStatus.DRAFT,
      },
    });

    return new AiPromptVersion(promptVersion);
  }

  /**
   * Find prompt version by ID
   */
  async findById(id: string): Promise<AiPromptVersion> {
    const promptVersion = await this.prisma.aiPromptVersion.findUnique({
      where: { id },
    });

    if (!promptVersion) {
      throw new NotFoundException(`Prompt version not found: ${id}`);
    }

    return new AiPromptVersion(promptVersion);
  }

  /**
   * Find prompt version by pipeline and version
   */
  async findByPipelineAndVersion(
    pipeline: AiPipeline,
    version: string,
  ): Promise<AiPromptVersion> {
    const promptVersion = await this.prisma.aiPromptVersion.findUnique({
      where: {
        pipeline_version: {
          pipeline,
          version,
        },
      },
    });

    if (!promptVersion) {
      throw new NotFoundException(
        `Prompt version not found: ${pipeline}@${version}`,
      );
    }

    return new AiPromptVersion(promptVersion);
  }

  /**
   * Get the latest published version for a pipeline
   */
  async getLatestPublished(pipeline: AiPipeline): Promise<AiPromptVersion> {
    const promptVersion = await this.prisma.aiPromptVersion.findFirst({
      where: {
        pipeline,
        status: ContentStatus.PUBLISHED,
      },
      orderBy: {
        publishedAt: 'desc',
      },
    });

    if (!promptVersion) {
      throw new NotFoundException(
        `No published prompt version found for pipeline: ${pipeline}`,
      );
    }

    return new AiPromptVersion(promptVersion);
  }

  /**
   * List all prompt versions for a pipeline
   */
  async listByPipeline(
    pipeline: AiPipeline,
    status?: ContentStatus,
  ): Promise<AiPromptVersion[]> {
    const promptVersions = await this.prisma.aiPromptVersion.findMany({
      where: {
        pipeline,
        ...(status && { status }),
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return promptVersions.map((pv) => new AiPromptVersion(pv));
  }

  /**
   * Update prompt version
   */
  async update(
    id: string,
    dto: UpdatePromptVersionDto,
  ): Promise<AiPromptVersion> {
    // If publishing, set publishedAt timestamp
    const updateData: any = { ...dto };
    if (dto.status === ContentStatus.PUBLISHED && !updateData.publishedAt) {
      updateData.publishedAt = new Date();
    }

    const promptVersion = await this.prisma.aiPromptVersion.update({
      where: { id },
      data: updateData,
    });

    this.logger.log(`Updated prompt version: ${id}`);

    return new AiPromptVersion(promptVersion);
  }

  /**
   * Publish a prompt version
   */
  async publish(id: string): Promise<AiPromptVersion> {
    return this.update(id, {
      status: ContentStatus.PUBLISHED,
    });
  }

  /**
   * Disable a prompt version
   */
  async disable(id: string): Promise<AiPromptVersion> {
    return this.update(id, {
      status: ContentStatus.DISABLED,
    });
  }

  /**
   * Delete a prompt version (soft delete by archiving)
   */
  async archive(id: string): Promise<AiPromptVersion> {
    return this.update(id, {
      status: ContentStatus.ARCHIVED,
    });
  }

  /**
   * Generate a hash of the prompt text for tracking changes
   */
  private generatePromptHash(promptText: string): string {
    return crypto.createHash('sha256').update(promptText).digest('hex');
  }

  /**
   * Check if a prompt version exists
   */
  async exists(pipeline: AiPipeline, version: string): Promise<boolean> {
    const count = await this.prisma.aiPromptVersion.count({
      where: {
        pipeline,
        version,
      },
    });

    return count > 0;
  }

  /**
   * Get prompt version statistics
   */
  async getStats(pipeline: AiPipeline): Promise<{
    total: number;
    published: number;
    draft: number;
    disabled: number;
  }> {
    const [total, published, draft, disabled] = await Promise.all([
      this.prisma.aiPromptVersion.count({ where: { pipeline } }),
      this.prisma.aiPromptVersion.count({
        where: { pipeline, status: ContentStatus.PUBLISHED },
      }),
      this.prisma.aiPromptVersion.count({
        where: { pipeline, status: ContentStatus.DRAFT },
      }),
      this.prisma.aiPromptVersion.count({
        where: { pipeline, status: ContentStatus.DISABLED },
      }),
    ]);

    return { total, published, draft, disabled };
  }
}

// Made with Bob
