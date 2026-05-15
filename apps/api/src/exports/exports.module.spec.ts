import { Test } from '@nestjs/testing';
import { ExportsModule } from './exports.module';

describe('ExportsModule', () => {
  it('compiles', async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [ExportsModule],
    }).compile();

    await moduleRef.close();
  });
});
