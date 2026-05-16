import { Test, TestingModule } from '@nestjs/testing';
import { ModelApiClient, ModelProvider, ModelRequest, ModelResponse } from './model-api.client';
import { AiPipeline } from './entities/ai-prompt-version.entity';

describe('ModelApiClient', () => {
  let client: ModelApiClient;
  let mockProvider: jest.Mocked<ModelProvider>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [ModelApiClient],
    }).compile();

    client = module.get<ModelApiClient>(ModelApiClient);

    // Create mock provider
    mockProvider = {
      name: 'test-provider',
      generateContent: jest.fn(),
      isAvailable: jest.fn().mockResolvedValue(true),
    };

    client.registerProvider(mockProvider);
  });

  describe('registerProvider', () => {
    it('should register a provider', () => {
      const newProvider: ModelProvider = {
        name: 'new-provider',
        generateContent: jest.fn(),
        isAvailable: jest.fn(),
      };

      client.registerProvider(newProvider);
      expect(client.getProviders()).toContain('new-provider');
    });

    it('should set first provider as default', () => {
      expect(client.getProviders()).toContain('test-provider');
    });
  });

  describe('generateContent', () => {
    it('should generate content successfully', async () => {
      const request: ModelRequest = {
        pipeline: AiPipeline.VISION_CATALOG,
        prompt: 'Test prompt',
      };

      const expectedResponse: ModelResponse = {
        content: 'Test response',
        provider: 'test-provider',
        model: 'test-model',
      };

      mockProvider.generateContent.mockResolvedValue(expectedResponse);

      const result = await client.generateContent(request);

      expect(result).toEqual(expectedResponse);
      expect(mockProvider.generateContent).toHaveBeenCalledWith(request);
    });

    it('should use specified provider', async () => {
      const secondProvider: jest.Mocked<ModelProvider> = {
        name: 'second-provider',
        generateContent: jest.fn().mockResolvedValue({
          content: 'Second response',
          provider: 'second-provider',
          model: 'test-model',
        }),
        isAvailable: jest.fn().mockResolvedValue(true),
      };

      client.registerProvider(secondProvider);

      const request: ModelRequest = {
        pipeline: AiPipeline.VISION_CATALOG,
        prompt: 'Test prompt',
      };

      await client.generateContent(request, 'second-provider');

      expect(secondProvider.generateContent).toHaveBeenCalled();
      expect(mockProvider.generateContent).not.toHaveBeenCalled();
    });

    it('should throw error for unknown provider', async () => {
      const request: ModelRequest = {
        pipeline: AiPipeline.VISION_CATALOG,
        prompt: 'Test prompt',
      };

      await expect(
        client.generateContent(request, 'unknown-provider'),
      ).rejects.toThrow('Provider not found: unknown-provider');
    });
  });

  describe('generateContentWithRetry', () => {
    it('should retry on retryable errors', async () => {
      const request: ModelRequest = {
        pipeline: AiPipeline.VISION_CATALOG,
        prompt: 'Test prompt',
      };

      // Fail twice, then succeed
      mockProvider.generateContent
        .mockRejectedValueOnce(new Error('rate limit exceeded'))
        .mockRejectedValueOnce(new Error('timeout'))
        .mockResolvedValueOnce({
          content: 'Success',
          provider: 'test-provider',
          model: 'test-model',
        });

      const result = await client.generateContentWithRetry(request, undefined, 2);

      expect(result.content).toBe('Success');
      expect(mockProvider.generateContent).toHaveBeenCalledTimes(3);
    });

    it('should not retry on non-retryable errors', async () => {
      const request: ModelRequest = {
        pipeline: AiPipeline.VISION_CATALOG,
        prompt: 'Test prompt',
      };

      mockProvider.generateContent.mockRejectedValue(
        new Error('invalid request'),
      );

      await expect(
        client.generateContentWithRetry(request, undefined, 2),
      ).rejects.toThrow();

      // Should only try once for non-retryable error
      expect(mockProvider.generateContent).toHaveBeenCalledTimes(1);
    });

    it('should give up after max retries', async () => {
      const request: ModelRequest = {
        pipeline: AiPipeline.VISION_CATALOG,
        prompt: 'Test prompt',
      };

      mockProvider.generateContent.mockRejectedValue(
        new Error('rate limit exceeded'),
      );

      await expect(
        client.generateContentWithRetry(request, undefined, 2),
      ).rejects.toThrow();

      expect(mockProvider.generateContent).toHaveBeenCalledTimes(3); // Initial + 2 retries
    });
  });

  describe('isProviderAvailable', () => {
    it('should check provider availability', async () => {
      const available = await client.isProviderAvailable('test-provider');
      expect(available).toBe(true);
      expect(mockProvider.isAvailable).toHaveBeenCalled();
    });

    it('should return false for unknown provider', async () => {
      const available = await client.isProviderAvailable('unknown');
      expect(available).toBe(false);
    });
  });

  describe('error normalization', () => {
    it('should normalize rate limit errors', async () => {
      const request: ModelRequest = {
        pipeline: AiPipeline.VISION_CATALOG,
        prompt: 'Test prompt',
      };

      mockProvider.generateContent.mockRejectedValue(
        new Error('rate limit exceeded'),
      );

      try {
        await client.generateContent(request);
      } catch (error: any) {
        expect(error.code).toBe('RATE_LIMIT_EXCEEDED');
        expect(error.retryable).toBe(true);
      }
    });

    it('should normalize timeout errors', async () => {
      const request: ModelRequest = {
        pipeline: AiPipeline.VISION_CATALOG,
        prompt: 'Test prompt',
      };

      mockProvider.generateContent.mockRejectedValue(new Error('ETIMEDOUT'));

      try {
        await client.generateContent(request);
      } catch (error: any) {
        expect(error.code).toBe('TIMEOUT');
        expect(error.retryable).toBe(true);
      }
    });

    it('should normalize auth errors', async () => {
      const request: ModelRequest = {
        pipeline: AiPipeline.VISION_CATALOG,
        prompt: 'Test prompt',
      };

      mockProvider.generateContent.mockRejectedValue(
        new Error('unauthorized 401'),
      );

      try {
        await client.generateContent(request);
      } catch (error: any) {
        expect(error.code).toBe('AUTH_ERROR');
        expect(error.retryable).toBe(false);
      }
    });

    it('should sanitize error messages', async () => {
      const request: ModelRequest = {
        pipeline: AiPipeline.VISION_CATALOG,
        prompt: 'Test prompt',
      };

      mockProvider.generateContent.mockRejectedValue(
        new Error('Failed with api_key=sk-1234567890'),
      );

      try {
        await client.generateContent(request);
      } catch (error: any) {
        expect(error.message).not.toContain('sk-1234567890');
        expect(error.message).toContain('api_key=***');
      }
    });
  });
});

// Made with Bob
