import { Injectable } from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import type { CreateInventoryScanDto } from './dto/create-inventory-scan.dto';
import type { ConfirmedItem } from './entities/confirmed-item.entity';
import type { DetectedItem } from './entities/detected-item.entity';
import type {
  InventoryScan,
  InventoryScanStatus,
} from './entities/inventory-scan.entity';

export type ScanAnalysisUpdate = {
  status: InventoryScanStatus;
  detectedItems: DetectedItem[];
  errorCode?: string;
  errorMessage?: string;
};

@Injectable()
export class InventoryRepository {
  private readonly scans = new Map<string, InventoryScan>();

  createScan(input: CreateInventoryScanDto): InventoryScan {
    const scan: InventoryScan = {
      classLabel: input.classLabel,
      confirmedItems: [],
      detectedItems: [],
      gradeBand: input.gradeBand,
      id: randomUUID(),
      status: 'CREATED',
      subject: input.subject,
      topic: input.topic,
    };
    this.scans.set(scan.id, scan);
    return scan;
  }

  findScan(id: string): InventoryScan | undefined {
    return this.scans.get(id);
  }

  markAnalyzing(id: string): InventoryScan | undefined {
    return this.patchScan(id, { status: 'ANALYZING' });
  }

  markScanFailed(
    id: string,
    errorCode: string,
    errorMessage: string,
  ): InventoryScan | undefined {
    return this.patchScan(id, {
      errorCode,
      errorMessage,
      status: 'FAILED',
    });
  }

  updateScanAnalysis(
    id: string,
    analysis: ScanAnalysisUpdate,
  ): InventoryScan | undefined {
    return this.patchScan(id, {
      detectedItems: analysis.detectedItems,
      errorCode: analysis.errorCode,
      errorMessage: analysis.errorMessage,
      status: analysis.status,
    });
  }

  updateItems(
    id: string,
    detectedItems: DetectedItem[],
  ): InventoryScan | undefined {
    return this.patchScan(id, {
      confirmedItems: [],
      detectedItems,
      status: 'NEEDS_CONFIRMATION',
    });
  }

  confirmScan(id: string): InventoryScan | undefined {
    const scan = this.scans.get(id);
    if (!scan) return undefined;

    return this.patchScan(id, {
      confirmedItems: this.toConfirmedItems(scan),
      status: 'CONFIRMED',
    });
  }

  private patchScan(
    id: string,
    patch: Partial<InventoryScan>,
  ): InventoryScan | undefined {
    const scan = this.scans.get(id);
    if (!scan) return undefined;
    const next = { ...scan, ...patch };
    this.scans.set(id, next);
    return next;
  }

  private toConfirmedItems(scan: InventoryScan): ConfirmedItem[] {
    const confirmedAt = new Date().toISOString();

    return scan.detectedItems
      .filter((item) => !item.removed)
      .map((item) => ({
        active: true,
        canonicalName: item.canonicalName,
        confidence: item.confidence,
        confirmedAt,
        displayName: item.displayName,
        evidence: [...item.evidence],
        id: randomUUID(),
        quantityEstimate: item.quantityEstimate,
        rawLabel: item.rawLabel,
        safetyFlags: [...item.safetyFlags],
        scanId: scan.id,
        unit: item.unit,
      }));
  }
}
