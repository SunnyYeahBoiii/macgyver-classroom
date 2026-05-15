import { Test } from '@nestjs/testing';
import { UsersModule } from './users.module';

describe('UsersModule', () => {
  it('compiles', async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [UsersModule],
    }).compile();

    await moduleRef.close();
  });
});
