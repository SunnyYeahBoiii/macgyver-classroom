import { Test, type TestingModule } from '@nestjs/testing';
import { AiModule } from './ai.module';
import { LESSON_PLAN_PROVIDER } from './lesson-plan.types';
import { MATERIAL_VISION_PROVIDER } from './material-vision.types';

describe('AiModule', () => {
  it('compiles', async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AiModule],
    }).compile();

    await moduleRef.close();
  });

  it('uses the Google material vision provider by default', async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AiModule],
    }).compile();

    const provider = moduleRef.get<{ providerName: string }>(
      MATERIAL_VISION_PROVIDER,
    );

    expect(provider.providerName).toBe('google-vertex-ai');
    await moduleRef.close();
  });

  it('uses the Google lesson plan provider by default', async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AiModule],
    }).compile();

    const provider = moduleRef.get<{ providerName: string }>(
      LESSON_PLAN_PROVIDER,
    );

    expect(provider.providerName).toBe('google-vertex-ai');
    await moduleRef.close();
  });

  it('does not switch to a local material vision provider from env config', async () => {
    const previousProviderMode = process.env.MATERIAL_VISION_PROVIDER;
    let moduleRef: TestingModule | undefined;

    process.env.MATERIAL_VISION_PROVIDER = 'local';

    try {
      moduleRef = await Test.createTestingModule({
        imports: [AiModule],
      }).compile();

      const provider = moduleRef.get<{ providerName: string }>(
        MATERIAL_VISION_PROVIDER,
      );

      expect(provider.providerName).toBe('google-vertex-ai');
    } finally {
      if (previousProviderMode === undefined) {
        delete process.env.MATERIAL_VISION_PROVIDER;
      } else {
        process.env.MATERIAL_VISION_PROVIDER = previousProviderMode;
      }
      await moduleRef?.close();
    }
  });
});
