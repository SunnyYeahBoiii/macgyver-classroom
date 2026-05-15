import { Test } from '@nestjs/testing';
import { AssetsModule } from './assets.module';

describe('AssetsModule', () => {
  it('compiles', async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AssetsModule],
    }).compile();

    expect(moduleRef).toBeDefined();

    await moduleRef.close();
  });
});
