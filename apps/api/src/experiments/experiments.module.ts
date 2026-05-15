import { Module } from '@nestjs/common';
import { ExperimentMatchController } from './experiment-match.controller';
import { ExperimentsController } from './experiments.controller';
import { ExperimentsRepository } from './experiments.repository';
import { ExperimentsService } from './experiments.service';
import { MatchingService } from './matching.service';

@Module({
  controllers: [ExperimentsController, ExperimentMatchController],
  providers: [ExperimentsService, MatchingService, ExperimentsRepository],
  exports: [ExperimentsService, MatchingService],
})
export class ExperimentsModule {}
