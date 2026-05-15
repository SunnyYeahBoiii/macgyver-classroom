import { Module } from '@nestjs/common';
import { ConfirmedItemsController } from './confirmed-items.controller';
import { InventoryScansController } from './inventory-scans.controller';
import { InventoryRepository } from './inventory.repository';
import { InventoryService } from './inventory.service';
import { ScanAnalysisService } from './scan-analysis.service';

@Module({
  controllers: [InventoryScansController, ConfirmedItemsController],
  providers: [InventoryService, ScanAnalysisService, InventoryRepository],
  exports: [InventoryService, ScanAnalysisService],
})
export class InventoryModule {}
