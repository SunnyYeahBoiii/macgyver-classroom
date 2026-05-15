import { Test } from '@nestjs/testing';
import { ExperimentsModule } from './experiments.module';
import { ExperimentsService } from './experiments.service';
import { MatchingService } from './matching.service';

describe('ExperimentsModule', () => {
  it('compiles with scaffold providers', async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [ExperimentsModule],
    }).compile();

    expect(moduleRef.get(ExperimentsService)).toBeInstanceOf(
      ExperimentsService,
    );
    expect(moduleRef.get(MatchingService)).toBeInstanceOf(MatchingService);

    await moduleRef.close();
  });
});
