import { ServiceUnavailableException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ModelApiClient } from './model-api.client';

describe('ModelApiClient', () => {
  it('fails when Google credentials are unavailable instead of returning fallback detections', async () => {
    const client = new ModelApiClient(new ConfigService({}));

    await expect(
      client.analyzeMaterials({
        catalog: [],
        images: [
          {
            dataBase64: Buffer.from('fake-image').toString('base64'),
            mimeType: 'image/jpeg',
          },
        ],
      }),
    ).rejects.toThrow(ServiceUnavailableException);
  });

  it('fails lesson generation when Google credentials are unavailable instead of returning a mock lesson', async () => {
    const client = new ModelApiClient(new ConfigService({}));

    await expect(
      client.generateLessonPlan({
        confirmedItems: [],
        experiment: {
          estimatedMinutes: 35,
          id: 'paper-cup-sound-amplifier',
          optionalMaterials: [],
          requiredMaterials: [],
          safetyCategory: 'LOW',
          safetyNotes: [],
          summary: 'Compare vibration and loudness.',
          title: 'Paper Cup Sound Amplifier',
        },
        teacherContext: {
          gradeBand: 'Grade 8',
          subject: 'Physics',
          topic: 'Sound and vibration',
        },
      }),
    ).rejects.toThrow(ServiceUnavailableException);
  });
});
