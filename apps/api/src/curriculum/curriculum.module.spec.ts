import { Test } from '@nestjs/testing';
import { CurriculumModule } from './curriculum.module';
import { CurriculumService } from './curriculum.service';

describe('CurriculumModule', () => {
  it('compiles with scaffold providers', async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [CurriculumModule],
    }).compile();

    expect(moduleRef.get(CurriculumService)).toBeInstanceOf(CurriculumService);

    await moduleRef.close();
  });
});
