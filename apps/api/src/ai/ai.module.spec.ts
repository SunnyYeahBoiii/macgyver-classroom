import { Test } from '@nestjs/testing';
import { AiModule } from './ai.module';

describe('AiModule', () => {
  it('compiles', async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AiModule],
    }).compile();

    await moduleRef.close();
  });
});
