import { Injectable, Logger } from '@nestjs/common';
import { AiPipeline } from './entities/ai-prompt-version.entity';

export interface ModelRequest {
  pipeline: AiPipeline;
  prompt: string;
  images?: string[]; // base64 or URLs
  temperature?: number;
  maxTokens?: number;
  schema?: Record<string, any>;
}

export interface ModelResponse {
  content: string;
  provider: string;
  model: string;
  modelVersion?: string;
  finishReason?: string;
  usage?: {
    inputTokens?: number;
    outputTokens?: number;
    totalTokens?: number;
  };
}

export interface ModelError {
  code: string;
  message: string;
  retryable: boolean;
  provider: string;
}

export interface ModelProvider {
  name: string;
  generateContent(request: ModelRequest): Promise<ModelResponse>;
  isAvailable(): Promise<boolean>;
}

/**
 * Model API Client with provider abstraction
 * Handles provider selection, retry logic, and error handling
 */
@Injectable()
export class ModelApiClient {
  private readonly logger = new Logger(ModelApiClient.name);
  private providers: Map<string, ModelProvider> = new Map();
  private defaultProvider?: string;

  /**
   * Register a model provider
   */
  registerProvider(provider: ModelProvider): void {
    this.providers.set(provider.name, provider);
    this.logger.log(`Registered provider: ${provider.name}`);
    
    if (!this.defaultProvider) {
      this.defaultProvider = provider.name;
      this.logger.log(`Set default provider: ${provider.name}`);
    }
  }

  /**
   * Set the default provider
   */
  setDefaultProvider(providerName: string): void {
    if (!this.providers.has(providerName)) {
      throw new Error(`Provider not found: ${providerName}`);
    }
    this.defaultProvider = providerName;
    this.logger.log(`Default provider set to: ${providerName}`);
  }

  /**
   * Generate content using the specified or default provider
   */
  async generateContent(
    request: ModelRequest,
    providerName?: string,
  ): Promise<ModelResponse> {
    const provider = this.getProvider(providerName);
    
    try {
      this.logger.log(
        `Generating content with ${provider.name} for pipeline: ${request.pipeline}`,
      );
      
      const response = await provider.generateContent(request);
      
      this.logger.log(
        `Content generated successfully with ${provider.name}`,
      );
      
      return response;
    } catch (error) {
      this.logger.error(
        `Failed to generate content with ${provider.name}`,
        error,
      );
      throw this.normalizeError(error, provider.name);
    }
  }

  /**
   * Generate content with automatic retry on retryable errors
   */
  async generateContentWithRetry(
    request: ModelRequest,
    providerName?: string,
    maxRetries: number = 2,
  ): Promise<ModelResponse> {
    let lastError: ModelError | undefined;
    
    for (let attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        return await this.generateContent(request, providerName);
      } catch (error) {
        lastError = error as ModelError;
        
        if (!lastError.retryable || attempt === maxRetries) {
          throw lastError;
        }
        
        const delay = Math.min(1000 * Math.pow(2, attempt), 5000);
        this.logger.warn(
          `Retrying after ${delay}ms (attempt ${attempt + 1}/${maxRetries})`,
        );
        await this.sleep(delay);
      }
    }
    
    throw lastError;
  }

  /**
   * Check if a provider is available
   */
  async isProviderAvailable(providerName?: string): Promise<boolean> {
    try {
      const provider = this.getProvider(providerName);
      return await provider.isAvailable();
    } catch {
      return false;
    }
  }

  /**
   * Get list of registered providers
   */
  getProviders(): string[] {
    return Array.from(this.providers.keys());
  }

  /**
   * Get provider instance
   */
  private getProvider(providerName?: string): ModelProvider {
    const name = providerName || this.defaultProvider;
    
    if (!name) {
      throw new Error('No provider specified and no default provider set');
    }
    
    const provider = this.providers.get(name);
    if (!provider) {
      throw new Error(`Provider not found: ${name}`);
    }
    
    return provider;
  }

  /**
   * Normalize errors to ModelError format
   */
  private normalizeError(error: any, providerName: string): ModelError {
    // Check if already a ModelError
    if (error.code && error.message && error.retryable !== undefined) {
      return error as ModelError;
    }

    // Normalize common error patterns
    const message = error.message || String(error);
    let code = 'UNKNOWN_ERROR';
    let retryable = false;

    // Rate limit errors
    if (
      message.includes('rate limit') ||
      message.includes('quota') ||
      message.includes('429')
    ) {
      code = 'RATE_LIMIT_EXCEEDED';
      retryable = true;
    }
    // Timeout errors
    else if (
      message.includes('timeout') ||
      message.includes('ETIMEDOUT') ||
      message.includes('ECONNRESET')
    ) {
      code = 'TIMEOUT';
      retryable = true;
    }
    // Authentication errors
    else if (
      message.includes('auth') ||
      message.includes('unauthorized') ||
      message.includes('401')
    ) {
      code = 'AUTH_ERROR';
      retryable = false;
    }
    // Invalid request errors
    else if (
      message.includes('invalid') ||
      message.includes('bad request') ||
      message.includes('400')
    ) {
      code = 'INVALID_REQUEST';
      retryable = false;
    }
    // Service unavailable
    else if (
      message.includes('503') ||
      message.includes('unavailable') ||
      message.includes('overloaded')
    ) {
      code = 'SERVICE_UNAVAILABLE';
      retryable = true;
    }

    return {
      code,
      message: this.sanitizeErrorMessage(message),
      retryable,
      provider: providerName,
    };
  }

  /**
   * Remove sensitive data from error messages
   */
  private sanitizeErrorMessage(message: string): string {
    return message
      .replace(/api[_-]?key[s]?[:=]\s*[\w-]+/gi, 'api_key=***')
      .replace(/token[:=]\s*[\w-]+/gi, 'token=***')
      .replace(/password[:=]\s*[\w-]+/gi, 'password=***')
      .replace(/bearer\s+[\w-]+/gi, 'bearer ***');
  }

  /**
   * Sleep utility for retry delays
   */
  private sleep(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}

// Made with Bob
