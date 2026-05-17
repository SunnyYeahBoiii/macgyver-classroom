import { Module } from '@nestjs/common';
import { InventoryModule } from '../inventory/inventory.module';
import { ExperimentMatchController } from './experiment-match.controller';
import { ExperimentsController } from './experiments.controller';
import { ExperimentsRepository } from './experiments.repository';
import { ExperimentsService } from './experiments.service';
import { MatchingService } from './matching.service';

@Module({
  imports: [InventoryModule],
  controllers: [ExperimentsController, ExperimentMatchController],
  providers: [ExperimentsService, MatchingService, ExperimentsRepository],
  exports: [ExperimentsService, MatchingService],
})
export class ExperimentsModule {}
