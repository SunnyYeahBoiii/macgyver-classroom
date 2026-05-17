import { Injectable, NotFoundException } from '@nestjs/common';
import type { ExperimentTemplate } from './entities/experiment-template.entity';
import { ExperimentsRepository } from './experiments.repository';

@Injectable()
export class ExperimentsService {
  constructor(private readonly experimentsRepository: ExperimentsRepository) {}

  getTemplate(templateId: string): ExperimentTemplate {
    const template = this.experimentsRepository.findTemplate(templateId);
    if (!template)
      throw new NotFoundException('Experiment template not found.');
    return template;
  }
}
