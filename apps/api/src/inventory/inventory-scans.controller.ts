import {
  Controller,
  Post,
  Body,
  Get,
  Param,
  HttpCode,
  HttpStatus,
  Logger,
  BadRequestException,
} from '@nestjs/common';
import { ScanAnalysisService } from './scan-analysis.service';
import { AnalyzeScanDto, AnalyzeScanResponseDto } from './dto/analyze-scan.dto';

@Controller('inventory/scans')
export class InventoryScansController {
  private readonly logger = new Logger(InventoryScansController.name);

  constructor(private readonly scanAnalysisService: ScanAnalysisService) {}

  /**
   * POST /inventory/scans/:id/analyze
   * Analyze scan images and detect classroom objects using Gemini Vision API
   */
  @Post(':id/analyze')
  @HttpCode(HttpStatus.OK)
  async analyzeScan(
    @Param('id') scanId: string,
    @Body() analyzeScanDto: AnalyzeScanDto,
  ): Promise<AnalyzeScanResponseDto> {
    this.logger.log(`Analyzing scan ${scanId} with ${analyzeScanDto.images.length} images`);

    // Validate scan ID matches
    if (analyzeScanDto.scanId !== scanId) {
      throw new BadRequestException('Scan ID mismatch');
    }

    // Validate images
    if (!analyzeScanDto.images || analyzeScanDto.images.length === 0) {
      throw new BadRequestException('At least one image is required');
    }

    if (analyzeScanDto.images.length > 10) {
      throw new BadRequestException('Maximum 10 images per scan');
    }

    try {
      // Perform analysis
      const result = await this.scanAnalysisService.analyzeScan(
        scanId,
        analyzeScanDto.images,
        {
          grade: analyzeScanDto.grade,
          subject: analyzeScanDto.subject,
          topic: analyzeScanDto.topic,
        },
      );

      // Validate detected items
      const validation = this.scanAnalysisService.validateDetectedItems(
        result.detectedItems,
      );

      return {
        scanId: result.scanId,
        detectedItems: validation.valid,
        aiRunId: result.aiRunId,
        status: result.status,
        error: result.error,
        warnings: validation.warnings.length > 0 ? validation.warnings : undefined,
      };
    } catch (error) {
      this.logger.error(`Failed to analyze scan ${scanId}`, error);
      throw new BadRequestException(`Analysis failed: ${error.message}`);
    }
  }

  /**
   * GET /inventory/scans/:id/status
   * Get the status of a scan analysis
   */
  @Get(':id/status')
  async getScanStatus(@Param('id') scanId: string) {
    this.logger.log(`Getting status for scan ${scanId}`);
    
    // This would integrate with InventoryService to get actual scan status
    // For now, return a placeholder
    return {
      scanId,
      status: 'pending',
      message: 'Scan status endpoint - to be implemented with database integration',
    };
  }

  /**
   * POST /inventory/scans
   * Create a new inventory scan session
   */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async createScan(@Body() createScanDto: any) {
    this.logger.log('Creating new inventory scan');
    
    // This would integrate with InventoryService to create scan in database
    // For now, return a placeholder
    return {
      scanId: `scan_${Date.now()}`,
      status: 'created',
      message: 'Create scan endpoint - to be implemented with database integration',
    };
  }
}
