import { Test } from '@nestjs/testing';
import { AuthModule } from './auth.module';

describe('AuthModule', () => {
  it('compiles', async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AuthModule],
    }).compile();

    await moduleRef.close();
  });
});
