import { Test } from '@nestjs/testing';
import { AnalyticsModule } from './analytics.module';

describe('AnalyticsModule', () => {
  it('compiles', async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AnalyticsModule],
    }).compile();

    await moduleRef.close();
  });
});
