import { Test } from '@nestjs/testing';
import { LeadsModule } from './leads.module';

describe('LeadsModule', () => {
  it('compiles', async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [LeadsModule],
    }).compile();

    await moduleRef.close();
  });
});
