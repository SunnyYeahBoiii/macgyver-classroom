import { Test, TestingModule } from '@nestjs/testing';
import { AiRunService } from './ai-run.service';
import { PrismaService } from '../database/prisma.service';
import { AiRunStatus } from './entities/ai-run.entity';
import { AiPipeline } from './entities/ai-prompt-version.entity';

describe('AiRunService', () => {
  let service: AiRunService;
  let prisma: jest.Mocked<PrismaService>;

  const mockAiRun = {
    id: 'test-id',
    pipeline: AiPipeline.VISION_CATALOG,
    status: AiRunStatus.QUEUED,
    queuedAt: new Date(),
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  beforeEach(async () => {
    const mockPrismaService = {
      aiRun: {
        create: jest.fn(),
        findUnique: jest.fn(),
        findMany: jest.fn(),
        update: jest.fn(),
        count: jest.fn(),
        aggregate: jest.fn(),
        deleteMany: jest.fn(),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AiRunService,
        {
          provide: PrismaService,
          useValue: mockPrismaService,
        },
      ],
    }).compile();

    service = module.get<AiRunService>(AiRunService);
    prisma = module.get(PrismaService) as jest.Mocked<PrismaService>;
  });

  describe('create', () => {
    it('should create a new AI run', async () => {
      const dto = {
        pipeline: AiPipeline.VISION_CATALOG,
        userId: 'user-id',
      };

      (prisma.aiRun.create as jest.Mock).mockResolvedValue(mockAiRun);

      const result = await service.create(dto);

      expect(result.pipeline).toBe(AiPipeline.VISION_CATALOG);
      expect(prisma.aiRun.create).toHaveBeenCalledWith({
        data: expect.objectContaining({
          pipeline: dto.pipeline,
          userId: dto.userId,
          status: AiRunStatus.QUEUED,
        }),
      });
    });
  });

  describe('findById', () => {
    it('should find AI run by ID', async () => {
      (prisma.aiRun.findUnique as jest.Mock).mockResolvedValue(mockAiRun);

      const result = await service.findById('test-id');

      expect(result.id).toBe('test-id');
      expect(prisma.aiRun.findUnique).toHaveBeenCalledWith({
        where: { id: 'test-id' },
        include: expect.any(Object),
      });
    });

    it('should throw NotFoundException when not found', async () => {
      (prisma.aiRun.findUnique as jest.Mock).mockResolvedValue(null);

      await expect(service.findById('non-existent')).rejects.toThrow(
        'AI run not found',
      );
    });
  });

  describe('markStarted', () => {
    it('should mark AI run as started', async () => {
      const updatedRun = {
        ...mockAiRun,
        status: AiRunStatus.RUNNING,
        provider: 'gemini',
        model: 'gemini-pro',
        startedAt: new Date(),
      };

      (prisma.aiRun.update as jest.Mock).mockResolvedValue(updatedRun);

      const result = await service.markStarted('test-id', 'gemini', 'gemini-pro');

      expect(result.status).toBe(AiRunStatus.RUNNING);
      expect(result.provider).toBe('gemini');
      expect(result.model).toBe('gemini-pro');
    });
  });

  describe('markSucceeded', () => {
    it('should mark AI run as succeeded', async () => {
      const outputJson = { items: [] };
      const updatedRun = {
        ...mockAiRun,
        status: AiRunStatus.SUCCEEDED,
        outputJson,
        completedAt: new Date(),
        durationMs: 1000,
      };

      (prisma.aiRun.update as jest.Mock).mockResolvedValue(updatedRun);

      const result = await service.markSucceeded('test-id', outputJson, {
        durationMs: 1000,
      });

      expect(result.status).toBe(AiRunStatus.SUCCEEDED);
      expect(result.outputJson).toEqual(outputJson);
    });
  });

  describe('markFailed', () => {
    it('should mark AI run as failed', async () => {
      const updatedRun = {
        ...mockAiRun,
        status: AiRunStatus.FAILED,
        errorCode: 'TIMEOUT',
        errorMessage: 'Request timed out',
        completedAt: new Date(),
      };

      (prisma.aiRun.update as jest.Mock).mockResolvedValue(updatedRun);

      const result = await service.markFailed(
        'test-id',
        'TIMEOUT',
        'Request timed out',
      );

      expect(result.status).toBe(AiRunStatus.FAILED);
      expect(result.errorCode).toBe('TIMEOUT');
    });
  });

  describe('list', () => {
    it('should list AI runs with filters', async () => {
      const runs = [mockAiRun];
      (prisma.aiRun.findMany as jest.Mock).mockResolvedValue(runs);
      (prisma.aiRun.count as jest.Mock).mockResolvedValue(1);

      const result = await service.list({
        pipeline: AiPipeline.VISION_CATALOG,
        status: AiRunStatus.SUCCEEDED,
      });

      expect(result.runs).toHaveLength(1);
      expect(result.total).toBe(1);
    });

    it('should apply date filters', async () => {
      const fromDate = new Date('2024-01-01');
      const toDate = new Date('2024-12-31');

      (prisma.aiRun.findMany as jest.Mock).mockResolvedValue([]);
      (prisma.aiRun.count as jest.Mock).mockResolvedValue(0);

      await service.list({ fromDate, toDate });

      expect(prisma.aiRun.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            createdAt: {
              gte: fromDate,
              lte: toDate,
            },
          }),
        }),
      );
    });
  });

  describe('getStats', () => {
    it('should return AI run statistics', async () => {
      (prisma.aiRun.count as jest.Mock)
        .mockResolvedValueOnce(100) // total
        .mockResolvedValueOnce(80) // succeeded
        .mockResolvedValueOnce(15) // failed
        .mockResolvedValueOnce(3) // running
        .mockResolvedValueOnce(2); // queued

      (prisma.aiRun.aggregate as jest.Mock).mockResolvedValue({
        _avg: { durationMs: 1500 },
      });

      const stats = await service.getStats({
        pipeline: AiPipeline.VISION_CATALOG,
      });

      expect(stats.total).toBe(100);
      expect(stats.succeeded).toBe(80);
      expect(stats.failed).toBe(15);
      expect(stats.running).toBe(3);
      expect(stats.queued).toBe(2);
      expect(stats.avgDurationMs).toBe(1500);
    });
  });

  describe('getRecentFailures', () => {
    it('should get recent failures', async () => {
      const failedRuns = [
        { ...mockAiRun, status: AiRunStatus.FAILED, errorCode: 'TIMEOUT' },
      ];

      (prisma.aiRun.findMany as jest.Mock).mockResolvedValue(failedRuns);

      const result = await service.getRecentFailures(
        AiPipeline.VISION_CATALOG,
        10,
      );

      expect(result).toHaveLength(1);
      expect(result[0].status).toBe(AiRunStatus.FAILED);
    });
  });

  describe('cleanupOldRuns', () => {
    it('should cleanup old AI runs', async () => {
      (prisma.aiRun.deleteMany as jest.Mock).mockResolvedValue({ count: 50 });

      const count = await service.cleanupOldRuns(90);

      expect(count).toBe(50);
      expect(prisma.aiRun.deleteMany).toHaveBeenCalledWith({
        where: expect.objectContaining({
          createdAt: expect.any(Object),
          status: { in: [AiRunStatus.SUCCEEDED, AiRunStatus.FAILED] },
        }),
      });
    });
  });

  describe('findByInventoryScan', () => {
    it('should find AI runs by inventory scan ID', async () => {
      (prisma.aiRun.findMany as jest.Mock).mockResolvedValue([mockAiRun]);

      const result = await service.findByInventoryScan('scan-id');

      expect(result).toHaveLength(1);
      expect(prisma.aiRun.findMany).toHaveBeenCalledWith({
        where: { inventoryScanId: 'scan-id' },
        orderBy: { createdAt: 'desc' },
      });
    });
  });
});

// Made with Bob
