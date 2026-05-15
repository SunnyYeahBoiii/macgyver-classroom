import { Test } from '@nestjs/testing';
import { FeedbackModule } from './feedback.module';

describe('FeedbackModule', () => {
  it('compiles', async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [FeedbackModule],
    }).compile();

    await moduleRef.close();
  });
});
