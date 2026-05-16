import { Injectable } from '@nestjs/common';
import { AiRepository, type AiRunRecord } from './ai.repository';

type StartVisionRunInput = {
  inventoryScanId: string;
  provider: string;
  model: string;
  inputJson: unknown;
};

@Injectable()
export class AiRunService {
  constructor(private readonly aiRepository: AiRepository) {}

  startVisionRun(input: StartVisionRunInput): Promise<AiRunRecord> {
    return Promise.resolve(
      this.aiRepository.createRun({
        inputJson: input.inputJson,
        inventoryScanId: input.inventoryScanId,
        model: input.model,
        pipeline: 'VISION_CATALOG',
        provider: input.provider,
      }),
    );
  }

  completeRun(id: string, outputJson: unknown): Promise<void> {
    this.aiRepository.completeRun(id, outputJson);
    return Promise.resolve();
  }

  failRun(id: string, errorCode: string, errorMessage: string): Promise<void> {
    this.aiRepository.failRun(id, errorCode, errorMessage);
    return Promise.resolve();
  }
}
