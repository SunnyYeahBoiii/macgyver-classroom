import { Test } from '@nestjs/testing';
import { LessonsModule } from './lessons.module';

describe('LessonsModule', () => {
  it('compiles', async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [LessonsModule],
    }).compile();

    await moduleRef.close();
  });
});
