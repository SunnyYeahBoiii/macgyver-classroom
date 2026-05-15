import { Test } from '@nestjs/testing';
import { MaterialsModule } from './materials.module';
import { MaterialsService } from './materials.service';
import { PropertyMappingService } from './property-mapping.service';

describe('MaterialsModule', () => {
  it('compiles with scaffold providers', async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [MaterialsModule],
    }).compile();

    expect(moduleRef.get(MaterialsService)).toBeInstanceOf(MaterialsService);
    expect(moduleRef.get(PropertyMappingService)).toBeInstanceOf(
      PropertyMappingService,
    );

    await moduleRef.close();
  });
});
