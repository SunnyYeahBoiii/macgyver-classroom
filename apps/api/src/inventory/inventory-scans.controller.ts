import {
  Body,
  Controller,
  Get,
  Logger,
  Param,
  Patch,
  Post,
} from '@nestjs/common';
import { AnalyzeInventoryScanDto } from './dto/analyze-inventory-scan.dto';
import { CreateInventoryScanDto } from './dto/create-inventory-scan.dto';
import type { DetectedItem } from './entities/detected-item.entity';
import type { InventoryScan } from './entities/inventory-scan.entity';
import { InventoryService } from './inventory.service';
import { ScanAnalysisService } from './scan-analysis.service';

@Controller('inventory/scans')
export class InventoryScansController {
  private readonly logger = new Logger(InventoryScansController.name);

  constructor(
    private readonly inventoryService: InventoryService,
    private readonly scanAnalysisService: ScanAnalysisService,
  ) {}

  @Post()
  create(@Body() dto: CreateInventoryScanDto): InventoryScan {
    return this.inventoryService.createDraft(dto);
  }

  @Post(':id/analyze')
  analyze(
    @Param('id') id: string,
    @Body() dto: AnalyzeInventoryScanDto,
  ): Promise<InventoryScan | undefined> {
    this.logger.log(
      `Analyze inventory scan requested scanId=${id} imageCount=${dto.images?.length ?? 0}`,
    );
    return this.scanAnalysisService.analyzeScan(id, dto);
  }

  @Get(':id')
  getScan(@Param('id') id: string): InventoryScan {
    return this.inventoryService.getScan(id);
  }

  @Patch(':id/items')
  updateItems(
    @Param('id') id: string,
    @Body('items') items: DetectedItem[],
  ): InventoryScan {
    return this.inventoryService.updateItems(id, items ?? []);
  }

  @Post(':id/confirm')
  confirm(@Param('id') id: string): InventoryScan {
    return this.inventoryService.confirm(id);
  }
}
