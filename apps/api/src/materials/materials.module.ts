import { Module } from '@nestjs/common';
import { MaterialsController } from './materials.controller';
import { MaterialsRepository } from './materials.repository';
import { MaterialsService } from './materials.service';
import { PropertyMappingService } from './property-mapping.service';

@Module({
  controllers: [MaterialsController],
  providers: [MaterialsService, PropertyMappingService, MaterialsRepository],
  exports: [MaterialsService, PropertyMappingService],
})
export class MaterialsModule {}
