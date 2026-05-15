import { Test } from '@nestjs/testing';
import { OrganizationsModule } from './organizations.module';

describe('OrganizationsModule', () => {
  it('compiles', async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [OrganizationsModule],
    }).compile();

    await moduleRef.close();
  });
});
