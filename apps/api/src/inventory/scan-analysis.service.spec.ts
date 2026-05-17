import {
  BadRequestException,
  NotFoundException,
  ServiceUnavailableException,
} from '@nestjs/common';
import {
  MAX_SCAN_ANALYZE_IMAGES,
  MAX_SCAN_IMAGE_BASE64_LENGTH,
  ScanAnalysisService,
} from './scan-analysis.service';

const scanImage = {
  mimeType: 'image/jpeg',
  dataBase64: Buffer.from('fake-image').toString('base64'),
};

describe('ScanAnalysisService', () => {
  const createSubject = () => {
    const provider = {
      analyzeMaterials: jest.fn(),
      modelName: 'test-vision-model',
      providerName: 'test-vision-provider',
    };
    const repository = {
      findScan: jest.fn((): { id: string } | undefined => ({ id: 'scan-1' })),
      markScanFailed: jest.fn(() => undefined),
      markAnalyzing: jest.fn(() => undefined),
      updateScanAnalysis: jest.fn(
        (_scanId: string, analysis: unknown) => analysis,
      ),
    };
    const aiRunService = {
      startVisionRun: jest.fn(() => Promise.resolve({ id: 'ai-run-1' })),
      completeRun: jest.fn(() => Promise.resolve(undefined)),
      failRun: jest.fn(() => Promise.resolve(undefined)),
    };
    const materialsService = {
      listVisionCatalog: jest.fn(),
    };
    const service = new ScanAnalysisService(
      provider,
      repository as never,
      aiRunService as never,
      materialsService,
    );

    return { aiRunService, materialsService, provider, repository, service };
  };

  it('does not start an AI run when the scan does not exist', async () => {
    const { aiRunService, materialsService, provider, repository, service } =
      createSubject();
    repository.findScan.mockReturnValue(undefined);
    materialsService.listVisionCatalog.mockReturnValue([
      {
        canonicalName: 'plastic_bottle',
        displayName: 'Chai nhựa',
        aliases: [],
      },
    ]);

    await expect(
      service.analyzeScan('missing-scan', { images: [scanImage] }),
    ).rejects.toThrow(NotFoundException);

    expect(provider.analyzeMaterials).not.toHaveBeenCalled();
    expect(aiRunService.startVisionRun).not.toHaveBeenCalled();
    expect(repository.markScanFailed).not.toHaveBeenCalled();
  });

  it('fails with catalog_unavailable before calling the AI provider when the static catalog is empty', async () => {
    const { materialsService, provider, repository, service } = createSubject();
    materialsService.listVisionCatalog.mockReturnValue([]);

    await expect(
      service.analyzeScan('scan-1', { images: [scanImage] }),
    ).rejects.toThrow(ServiceUnavailableException);

    expect(provider.analyzeMaterials).not.toHaveBeenCalled();
    expect(repository.markScanFailed).toHaveBeenCalledWith(
      'scan-1',
      'catalog_unavailable',
      'Material catalog is unavailable.',
    );
  });

  it('stores a retry-safe message when the AI provider throws an unexpected error', async () => {
    const { aiRunService, materialsService, provider, repository, service } =
      createSubject();
    materialsService.listVisionCatalog.mockReturnValue([
      {
        aliases: [],
        canonicalName: 'plastic_bottle',
        displayName: 'Plastic bottle',
      },
    ]);
    provider.analyzeMaterials.mockRejectedValue(
      new Error('raw provider stack with credentials'),
    );

    await expect(
      service.analyzeScan('scan-1', { images: [scanImage] }),
    ).rejects.toThrow(ServiceUnavailableException);

    expect(aiRunService.failRun).toHaveBeenCalledWith(
      'ai-run-1',
      'ai_provider_failed',
      'AI provider failed. Please try again.',
    );
    expect(repository.markScanFailed).toHaveBeenCalledWith(
      'scan-1',
      'ai_provider_failed',
      'AI provider failed. Please try again.',
    );
  });

  it('rejects too many scan images before starting an AI run', async () => {
    const { aiRunService, provider, service } = createSubject();

    await expect(
      service.analyzeScan('scan-1', {
        images: Array.from({ length: MAX_SCAN_ANALYZE_IMAGES + 1 }, () => ({
          ...scanImage,
        })),
      }),
    ).rejects.toThrow(BadRequestException);

    expect(provider.analyzeMaterials).not.toHaveBeenCalled();
    expect(aiRunService.startVisionRun).not.toHaveBeenCalled();
  });

  it('rejects oversized scan images before starting an AI run', async () => {
    const { aiRunService, provider, service } = createSubject();

    await expect(
      service.analyzeScan('scan-1', {
        images: [
          {
            ...scanImage,
            dataBase64: 'a'.repeat(MAX_SCAN_IMAGE_BASE64_LENGTH + 1),
          },
        ],
      }),
    ).rejects.toThrow(BadRequestException);

    expect(provider.analyzeMaterials).not.toHaveBeenCalled();
    expect(aiRunService.startVisionRun).not.toHaveBeenCalled();
  });

  it('keeps the scan reviewable when Gemini sees no matching materials', async () => {
    const { aiRunService, materialsService, provider, repository, service } =
      createSubject();
    materialsService.listVisionCatalog.mockReturnValue([
      {
        canonicalName: 'plastic_bottle',
        displayName: 'Chai nhựa',
        aliases: [],
      },
    ]);
    provider.analyzeMaterials.mockResolvedValue({
      items: [],
      noMaterialsDetected: true,
      message:
        'Không tìm thấy vật liệu phù hợp. Hãy chụp lại hoặc thêm thủ công.',
    });

    const result = await service.analyzeScan('scan-1', { images: [scanImage] });

    expect(aiRunService.startVisionRun).toHaveBeenCalledWith(
      expect.objectContaining({
        model: 'test-vision-model',
        provider: 'test-vision-provider',
      }),
    );
    expect(repository.updateScanAnalysis).toHaveBeenCalledWith('scan-1', {
      detectedItems: [],
      errorCode: 'no_materials_detected',
      errorMessage:
        'Không tìm thấy vật liệu phù hợp. Hãy chụp lại hoặc thêm thủ công.',
      status: 'NEEDS_CONFIRMATION',
    });
    expect(result).toMatchObject({
      detectedItems: [],
      errorCode: 'no_materials_detected',
      status: 'NEEDS_CONFIRMATION',
    });
  });

  it('returns out-of-catalog objects as unmatched detected items for manual correction', async () => {
    const { materialsService, provider, service } = createSubject();
    materialsService.listVisionCatalog.mockReturnValue([
      {
        canonicalName: 'plastic_bottle',
        displayName: 'Chai nhựa',
        aliases: [],
      },
    ]);
    provider.analyzeMaterials.mockResolvedValue({
      items: [
        {
          rawLabel: 'unknown clamp',
          displayName: 'Kẹp lạ',
          canonicalName: null,
          quantityEstimate: 1,
          unit: 'cái',
          confidence: 0.42,
          evidence: 'Một kẹp kim loại nằm cạnh khay dụng cụ.',
          safetyFlags: [],
        },
      ],
      noMaterialsDetected: false,
      message: null,
    });

    const result = await service.analyzeScan('scan-1', { images: [scanImage] });

    expect(result.detectedItems).toEqual([
      {
        rawLabel: 'unknown clamp',
        canonicalName: null,
        displayName: 'Kẹp lạ',
        quantityEstimate: 1,
        unit: 'cái',
        confidence: 0.42,
        evidence: ['Một kẹp kim loại nằm cạnh khay dụng cụ.'],
        safetyFlags: [],
      },
    ]);
  });

  it('keeps hallucinated canonical material names unmatched for teacher correction', async () => {
    const { materialsService, provider, service } = createSubject();
    materialsService.listVisionCatalog.mockReturnValue([
      {
        canonicalName: 'plastic_bottle',
        displayName: 'Chai nhựa',
        aliases: [],
      },
    ]);
    provider.analyzeMaterials.mockResolvedValue({
      items: [
        {
          rawLabel: 'unknown clamp',
          displayName: 'Kẹp lạ',
          canonicalName: 'metal_clamp',
          quantityEstimate: 1,
          unit: 'cái',
          confidence: 0.42,
          evidence: 'Một kẹp kim loại nằm cạnh khay dụng cụ.',
          safetyFlags: [],
        },
      ],
      noMaterialsDetected: false,
      message: null,
    });

    const result = await service.analyzeScan('scan-1', { images: [scanImage] });

    expect(result.detectedItems[0]).toMatchObject({
      canonicalName: null,
      displayName: 'Kẹp lạ',
      rawLabel: 'unknown clamp',
    });
  });
});
