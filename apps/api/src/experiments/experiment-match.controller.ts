import { Body, Controller, Post } from '@nestjs/common';
import { MatchExperimentsDto } from './dto/match-experiments.dto';
import type { MatchExperimentsResult } from './entities/experiment-match.entity';
import { MatchingService } from './matching.service';

@Controller('experiments/match')
export class ExperimentMatchController {
  constructor(private readonly matchingService: MatchingService) {}

  @Post()
  match(@Body() dto: MatchExperimentsDto): MatchExperimentsResult {
    return this.matchingService.match(dto);
  }
}
