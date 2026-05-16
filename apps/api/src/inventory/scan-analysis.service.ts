import { Injectable, Logger } from '@nestjs/common';
import { GeminiVisionService } from '../ai/gemini-vision.service';
import { AiRunService } from '../ai/ai-run.service';

export interface ScanAnalysisResult {
  scanId: string;
  detectedItems: Array<{
    raw_label: string;
    canonical_name: string;
    quantity_estimate: number;
    confidence: number;
    evidence: string;
    safety_flags: string[];
  }>;
  aiRunId?: string;
  status: 'success' | 'failed' | 'partial';
  error?: string;
}

@Injectable()
export class ScanAnalysisService {
  private readonly logger = new Logger(ScanAnalysisService.name);

  constructor(
    private readonly geminiVisionService: GeminiVisionService,
    private readonly aiRunService: AiRunService,
  ) {}

  /**
   * Analyze scan images and detect classroom objects
   * @param scanId The inventory scan ID
   * @param images Array of image data with mime types
   * @param context Optional context (grade, subject, topic)
   * @returns Analysis result with detected items
   */
  async analyzeScan(
    scanId: string,
    images: Array<{ data: string; mimeType: string; url?: string }>,
    context?: {
      grade?: string;
      subject?: string;
      topic?: string;
      userId?: string;
    },
  ): Promise<ScanAnalysisResult> {
    this.logger.log(`Starting analysis for scan ${scanId} with ${images.length} images`);

    try {
      // Record AI run start
      const aiRunId = await this.recordAiRunStart(scanId, context);

      // Call Gemini Vision API
      const visionResult = await this.geminiVisionService.analyzeClassroomImages(
        images.map((img) => ({ data: img.data, mimeType: img.mimeType })),
        {
          grade: context?.grade,
          subject: context?.subject,
          topic: context?.topic,
        },
      );

      // Record AI run completion
      await this.recordAiRunComplete(aiRunId, visionResult);

      this.logger.log(
        `Analysis complete for scan ${scanId}: ${visionResult.items.length} items detected`,
      );

      return {
        scanId,
        detectedItems: visionResult.items,
        aiRunId,
        status: 'success',
      };
    } catch (error) {
      this.logger.error(`Analysis failed for scan ${scanId}`, error);

      // Record AI run failure
      if (context?.userId) {
        await this.recordAiRunFailure(scanId, error.message);
      }

      return {
        scanId,
        detectedItems: [],
        status: 'failed',
        error: error.message,
      };
    }
  }

  /**
   * Record the start of an AI run
   */
  private async recordAiRunStart(
    scanId: string,
    context?: { userId?: string; grade?: string; subject?: string; topic?: string },
  ): Promise<string> {
    try {
      // This would integrate with AiRunService to record metadata
      // For now, return a placeholder ID
      const runId = `run_${scanId}_${Date.now()}`;
      this.logger.debug(`AI run started: ${runId}`);
      return runId;
    } catch (error) {
      this.logger.warn('Failed to record AI run start', error);
      return `run_${scanId}_fallback`;
    }
  }

  /**
   * Record successful AI run completion
   */
  private async recordAiRunComplete(aiRunId: string, result: any): Promise<void> {
    try {
      this.logger.debug(`AI run completed: ${aiRunId}`, {
        itemCount: result.items?.length || 0,
        processingTime: result.metadata?.processing_time_ms,
      });
      // This would integrate with AiRunService to record results
    } catch (error) {
      this.logger.warn('Failed to record AI run completion', error);
    }
  }

  /**
   * Record AI run failure
   */
  private async recordAiRunFailure(scanId: string, errorMessage: string): Promise<void> {
    try {
      this.logger.debug(`AI run failed for scan ${scanId}: ${errorMessage}`);
      // This would integrate with AiRunService to record failure
    } catch (error) {
      this.logger.warn('Failed to record AI run failure', error);
    }
  }

  /**
   * Validate detected items for safety and quality
   */
  validateDetectedItems(items: any[]): {
    valid: any[];
    warnings: string[];
  } {
    const valid: any[] = [];
    const warnings: string[] = [];

    for (const item of items) {
      // Check confidence threshold
      if (item.confidence < 0.5) {
        warnings.push(
          `Low confidence (${item.confidence}) for item: ${item.canonical_name}`,
        );
      }

      // Check for safety flags
      if (item.safety_flags && item.safety_flags.length > 0) {
        warnings.push(
          `Safety concerns for ${item.canonical_name}: ${item.safety_flags.join(', ')}`,
        );
      }

      valid.push(item);
    }

    return { valid, warnings };
  }
}
