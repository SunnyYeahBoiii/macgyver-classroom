import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import type { CreateInventoryScanDto } from './dto/create-inventory-scan.dto';
import type { DetectedItem } from './entities/detected-item.entity';
import type { InventoryScan } from './entities/inventory-scan.entity';
import { InventoryRepository } from './inventory.repository';

@Injectable()
export class InventoryService {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  createDraft(input: CreateInventoryScanDto): InventoryScan {
    return this.inventoryRepository.createScan(input);
  }

  getScan(scanId: string): InventoryScan {
    const scan = this.inventoryRepository.findScan(scanId);
    if (!scan) throw new NotFoundException('Inventory scan not found.');
    return scan;
  }

  updateItems(scanId: string, items: DetectedItem[]): InventoryScan {
    const scan = this.inventoryRepository.updateItems(scanId, items);
    if (!scan) throw new NotFoundException('Inventory scan not found.');
    return scan;
  }

  confirm(scanId: string): InventoryScan {
    const existingScan = this.inventoryRepository.findScan(scanId);
    if (!existingScan) throw new NotFoundException('Inventory scan not found.');
    if (existingScan.status !== 'NEEDS_CONFIRMATION') {
      throw new BadRequestException({
        code: 'inventory_scan_not_reviewed',
        message: 'Inventory scan must be reviewed before confirmation.',
      });
    }
    if (!existingScan.detectedItems.some((item) => !item.removed)) {
      throw new BadRequestException({
        code: 'inventory_scan_empty',
        message:
          'Inventory scan must include at least one item before confirmation.',
      });
    }

    const scan = this.inventoryRepository.confirmScan(scanId);
    if (!scan) throw new NotFoundException('Inventory scan not found.');
    return scan;
  }
}
