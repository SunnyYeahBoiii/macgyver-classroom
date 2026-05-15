import { Test } from '@nestjs/testing';
import { StorageModule } from './storage.module';

describe('StorageModule', () => {
  it('compiles', async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [StorageModule],
    }).compile();

    expect(moduleRef).toBeDefined();

    await moduleRef.close();
  });
});
