import { Module } from '@nestjs/common';
import { ExportService } from './export.service';
import { ExportsRepository } from './exports.repository';
import { LessonExportsController } from './lesson-exports.controller';
import { ShareLinksController } from './share-links.controller';

@Module({
  controllers: [LessonExportsController, ShareLinksController],
  providers: [ExportService, ExportsRepository],
  exports: [ExportService],
})
export class ExportsModule {}
