import { Controller, Get, Param } from '@nestjs/common';
import type { ExperimentTemplate } from './entities/experiment-template.entity';
import { ExperimentsService } from './experiments.service';

@Controller('experiments')
export class ExperimentsController {
  constructor(private readonly experimentsService: ExperimentsService) {}

  @Get(':id')
  getExperiment(@Param('id') id: string): ExperimentTemplate {
    return this.experimentsService.getTemplate(id);
  }
}
