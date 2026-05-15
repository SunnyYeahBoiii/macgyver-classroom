import { Test } from '@nestjs/testing';
import { SafetyModule } from './safety.module';

describe('SafetyModule', () => {
  it('compiles', async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [SafetyModule],
    }).compile();

    await moduleRef.close();
  });
});
