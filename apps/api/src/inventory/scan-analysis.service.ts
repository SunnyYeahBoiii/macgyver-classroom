import {
  BadRequestException,
  HttpException,
  Inject,
  Injectable,
  NotFoundException,
  ServiceUnavailableException,
} from '@nestjs/common';
import { AiRunService } from '../ai/ai-run.service';
import {
  MATERIAL_VISION_PROVIDER,
  type MaterialScanImage,
  type MaterialVisionItem,
  type MaterialVisionProvider,
} from '../ai/material-vision.types';
import { MaterialsService } from '../materials/materials.service';
import type { MaterialCatalogItem } from '../materials/static-material-catalog';
import type { AnalyzeInventoryScanDto } from './dto/analyze-inventory-scan.dto';
import type { DetectedItem } from './entities/detected-item.entity';
import type { InventoryScan } from './entities/inventory-scan.entity';
import { InventoryRepository } from './inventory.repository';

export const MAX_SCAN_ANALYZE_IMAGES = 3;
export const MAX_SCAN_IMAGE_BASE64_LENGTH = 5_000_000;

@Injectable()
export class ScanAnalysisService {
  constructor(
    @Inject(MATERIAL_VISION_PROVIDER)
    private readonly materialVisionProvider: MaterialVisionProvider,
    private readonly inventoryRepository: InventoryRepository,
    private readonly aiRunService: AiRunService,
    private readonly materialsService: MaterialsService,
  ) {}

  async analyzeScan(
    scanId: string,
    dto: AnalyzeInventoryScanDto,
  ): Promise<InventoryScan> {
    const images = this.validateImages(dto.images);
    const existingScan = this.inventoryRepository.findScan(scanId);
    if (!existingScan) throw new NotFoundException('Inventory scan not found.');

    const catalog = this.materialsService.listVisionCatalog();

    if (catalog.length === 0) {
      const message = 'Material catalog is unavailable.';
      this.inventoryRepository.markScanFailed(
        scanId,
        'catalog_unavailable',
        message,
      );
      throw new ServiceUnavailableException({
        code: 'catalog_unavailable',
        message,
      });
    }

    this.inventoryRepository.markAnalyzing(scanId);
    const aiRun = await this.aiRunService.startVisionRun({
      inputJson: {
        catalogSize: catalog.length,
        imageCount: images.length,
        mimeTypes: images.map((image) => image.mimeType),
      },
      inventoryScanId: scanId,
      model: this.materialVisionProvider.modelName,
      provider: this.materialVisionProvider.providerName,
    });

    try {
      const providerResult = await this.materialVisionProvider.analyzeMaterials(
        {
          catalog,
          images,
        },
      );
      const noMaterialsDetected =
        providerResult.noMaterialsDetected === true ||
        providerResult.items.length === 0;
      const detectedItems = providerResult.items.map((item) =>
        this.toDetectedItem(item, catalog),
      );
      const analysis = {
        detectedItems,
        ...(noMaterialsDetected
          ? {
              errorCode: 'no_materials_detected',
              errorMessage:
                providerResult.message ??
                'Không tìm thấy vật liệu phù hợp. Hãy chụp lại hoặc thêm thủ công.',
            }
          : {}),
        status: 'NEEDS_CONFIRMATION' as const,
      };

      const scan = this.inventoryRepository.updateScanAnalysis(
        scanId,
        analysis,
      );
      if (!scan) throw new NotFoundException('Inventory scan not found.');
      await this.aiRunService.completeRun(aiRun.id, {
        detectedItemCount: detectedItems.length,
        noMaterialsDetected,
      });
      return scan;
    } catch (error) {
      const errorCode = this.errorCode(error);
      const errorMessage = this.errorMessage(error);
      await this.aiRunService.failRun(aiRun.id, errorCode, errorMessage);
      this.inventoryRepository.markScanFailed(scanId, errorCode, errorMessage);
      if (error instanceof HttpException) throw error;
      throw new ServiceUnavailableException({
        code: errorCode,
        message: errorMessage,
      });
    }
  }

  private validateImages(
    images: MaterialScanImage[] | undefined,
  ): MaterialScanImage[] {
    if (!Array.isArray(images) || images.length === 0) {
      throw new BadRequestException({
        code: 'scan_images_required',
        message: 'At least one scan image is required.',
      });
    }
    if (images.length > MAX_SCAN_ANALYZE_IMAGES) {
      throw new BadRequestException({
        code: 'scan_images_too_many',
        message: `At most ${MAX_SCAN_ANALYZE_IMAGES} scan images are allowed.`,
      });
    }

    return images.map((image) => {
      if (!['image/jpeg', 'image/png', 'image/webp'].includes(image.mimeType)) {
        throw new BadRequestException({
          code: 'scan_image_mime_type_unsupported',
          message: 'Scan image MIME type is unsupported.',
        });
      }
      if (!image.dataBase64 || image.dataBase64.trim().length === 0) {
        throw new BadRequestException({
          code: 'scan_image_base64_required',
          message: 'Scan image base64 data is required.',
        });
      }
      if (image.dataBase64.length > MAX_SCAN_IMAGE_BASE64_LENGTH) {
        throw new BadRequestException({
          code: 'scan_image_too_large',
          message: 'Scan image base64 data is too large.',
        });
      }
      if (!this.isBase64(image.dataBase64)) {
        throw new BadRequestException({
          code: 'scan_image_base64_invalid',
          message: 'Scan image base64 data is invalid.',
        });
      }
      return image;
    });
  }

  private isBase64(value: string): boolean {
    return value.length % 4 === 0 && /^[A-Za-z0-9+/]+={0,2}$/.test(value);
  }

  private toDetectedItem(
    item: MaterialVisionItem,
    catalog: MaterialCatalogItem[],
  ): DetectedItem {
    const matchedCanonicalName = catalog.some(
      (material) => material.canonicalName === item.canonicalName,
    )
      ? item.canonicalName
      : null;

    return {
      canonicalName: matchedCanonicalName,
      confidence: item.confidence,
      displayName: item.displayName,
      evidence: Array.isArray(item.evidence)
        ? item.evidence
        : item.evidence
          ? [item.evidence]
          : [],
      quantityEstimate: item.quantityEstimate,
      rawLabel: item.rawLabel,
      safetyFlags: item.safetyFlags,
      unit: item.unit,
    };
  }

  private errorCode(error: unknown): string {
    if (error instanceof HttpException) {
      const response = error.getResponse();
      if (typeof response === 'object' && response && 'code' in response) {
        return String(response.code);
      }
    }
    return 'ai_provider_failed';
  }

  private errorMessage(error: unknown): string {
    if (error instanceof HttpException) {
      const response = error.getResponse();
      if (typeof response === 'object' && response && 'message' in response) {
        return String(response.message);
      }
      if (typeof response === 'string') return response;
    }
    if (error instanceof Error) return error.message;
    return 'AI provider failed.';
  }
}
