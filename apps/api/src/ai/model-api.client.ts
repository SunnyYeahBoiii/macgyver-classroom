import {
  BadGatewayException,
  Injectable,
  ServiceUnavailableException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { buildMaterialScanSystemPrompt } from './material-scan.prompt';
import type {
  AnalyzeMaterialImagesInput,
  MaterialVisionItem,
  MaterialVisionProvider,
  MaterialVisionResult,
} from './material-vision.types';

type GoogleGenAIClient = {
  models: {
    generateContent(input: unknown): Promise<{ text?: string }>;
  };
};

type GoogleGenAIConstructor = new (
  options: Record<string, unknown>,
) => GoogleGenAIClient;

const MATERIAL_SCAN_RESPONSE_SCHEMA = {
  description:
    'Structured classroom material detection result for teacher review.',
  propertyOrdering: ['items', 'noMaterialsDetected', 'message'],
  properties: {
    items: {
      description:
        'Useful visible classroom materials. Keep empty when no material is detected.',
      items: {
        propertyOrdering: [
          'rawLabel',
          'displayName',
          'canonicalName',
          'quantityEstimate',
          'unit',
          'confidence',
          'evidence',
          'safetyFlags',
        ],
        properties: {
          canonicalName: {
            description:
              'Canonical material id from the provided catalog, or null when unmatched.',
            nullable: true,
            type: 'STRING',
          },
          confidence: {
            description: 'Detection confidence from 0 to 1.',
            maximum: 1,
            minimum: 0,
            nullable: true,
            type: 'NUMBER',
          },
          displayName: {
            description: 'Vietnamese material name shown to the teacher.',
            type: 'STRING',
          },
          evidence: {
            description: 'Short visible evidence from the submitted photos.',
            items: { type: 'STRING' },
            type: 'ARRAY',
          },
          quantityEstimate: {
            description: 'Estimated count or amount when visible.',
            minimum: 0,
            nullable: true,
            type: 'NUMBER',
          },
          rawLabel: {
            description: 'Original object label inferred from the image.',
            type: 'STRING',
          },
          safetyFlags: {
            description: 'Teacher-facing safety notes, empty when none apply.',
            items: { type: 'STRING' },
            type: 'ARRAY',
          },
          unit: {
            description: 'Vietnamese display unit from the catalog or null.',
            nullable: true,
            type: 'STRING',
          },
        },
        required: [
          'rawLabel',
          'displayName',
          'canonicalName',
          'quantityEstimate',
          'unit',
          'confidence',
          'evidence',
          'safetyFlags',
        ],
        type: 'OBJECT',
      },
      type: 'ARRAY',
    },
    message: {
      description:
        'Vietnamese teacher-facing message, required when noMaterialsDetected is true.',
      nullable: true,
      type: 'STRING',
    },
    noMaterialsDetected: {
      description:
        'True when valid images were analyzed but no useful material was visible.',
      type: 'BOOLEAN',
    },
  },
  required: ['items', 'noMaterialsDetected', 'message'],
  type: 'OBJECT',
} as const;

@Injectable()
export class ModelApiClient implements MaterialVisionProvider {
  constructor(private readonly configService: ConfigService) {}

  async analyzeMaterials(
    input: AnalyzeMaterialImagesInput,
  ): Promise<MaterialVisionResult> {
    const model = this.modelName;
    const ai = await this.createClient();
    const response = await ai.models.generateContent({
      model,
      contents: [
        {
          role: 'user',
          parts: [
            {
              text: 'Analyze these classroom photos and return the required JSON only.',
            },
            ...input.images.map((image) => ({
              inlineData: {
                data: image.dataBase64,
                mimeType: image.mimeType,
              },
            })),
          ],
        },
      ],
      config: {
        responseMimeType: 'application/json',
        responseSchema: MATERIAL_SCAN_RESPONSE_SCHEMA,
        systemInstruction: buildMaterialScanSystemPrompt(input.catalog),
      },
    });

    return this.parseResponse(response.text ?? '');
  }

  get modelName(): string {
    return (
      this.configService.get<string>('GOOGLE_VERTEX_MODEL') ??
      'gemini-2.5-flash-image'
    );
  }

  get providerName(): string {
    return 'google-vertex-ai';
  }

  private async createClient(): Promise<GoogleGenAIClient> {
    const credentials = this.parseCredentials();
    const project =
      this.configService.get<string>('GOOGLE_VERTEX_PROJECT_ID') ??
      credentials.project_id;
    if (!project) {
      throw new ServiceUnavailableException({
        code: 'google_project_unavailable',
        message: 'Google Vertex project is unavailable.',
      });
    }

    const GoogleGenAI = await this.loadGenAI();

    return new GoogleGenAI({
      googleAuthOptions: {
        credentials,
        scopes: ['https://www.googleapis.com/auth/cloud-platform'],
      },
      location:
        this.configService.get<string>('GOOGLE_VERTEX_LOCATION') ?? 'global',
      project,
      vertexai: true,
    });
  }

  private async loadGenAI(): Promise<GoogleGenAIConstructor> {
    try {
      const module = (await import('@google/genai')) as unknown as {
        GoogleGenAI: GoogleGenAIConstructor;
      };
      return module.GoogleGenAI;
    } catch {
      throw new ServiceUnavailableException({
        code: 'google_genai_sdk_unavailable',
        message: 'Google GenAI SDK is unavailable.',
      });
    }
  }

  private parseCredentials(): Record<string, string> {
    const raw = this.configService.get<string>('GOOGLE_SERVICE_ACCOUNT_JSON');
    if (!raw) {
      throw new ServiceUnavailableException({
        code: 'google_credentials_unavailable',
        message: 'Google service account credentials are unavailable.',
      });
    }

    try {
      const credentials = JSON.parse(raw) as Record<string, string>;
      if (!credentials.client_email || !credentials.private_key) {
        throw new Error('missing service account fields');
      }
      return credentials;
    } catch {
      throw new ServiceUnavailableException({
        code: 'google_credentials_invalid',
        message: 'Google service account credentials are invalid.',
      });
    }
  }

  private parseResponse(text: string): MaterialVisionResult {
    try {
      const parsed = JSON.parse(text) as Partial<MaterialVisionResult>;
      return {
        items: Array.isArray(parsed.items)
          ? parsed.items.map((item) => this.normalizeItem(item))
          : [],
        message: typeof parsed.message === 'string' ? parsed.message : null,
        noMaterialsDetected: parsed.noMaterialsDetected === true,
      };
    } catch {
      throw new BadGatewayException({
        code: 'ai_invalid_json',
        message: 'AI provider returned invalid JSON.',
      });
    }
  }

  private normalizeItem(item: unknown): MaterialVisionItem {
    const value = item as Partial<MaterialVisionItem>;
    const rawLabel =
      typeof value.rawLabel === 'string' && value.rawLabel.trim().length > 0
        ? value.rawLabel.trim()
        : 'unknown object';
    const displayName =
      typeof value.displayName === 'string' &&
      value.displayName.trim().length > 0
        ? value.displayName.trim()
        : rawLabel;

    return {
      canonicalName:
        typeof value.canonicalName === 'string' &&
        value.canonicalName.trim().length > 0
          ? value.canonicalName.trim()
          : null,
      confidence:
        typeof value.confidence === 'number'
          ? Math.min(Math.max(value.confidence, 0), 1)
          : null,
      displayName,
      evidence: value.evidence ?? null,
      quantityEstimate:
        typeof value.quantityEstimate === 'number'
          ? value.quantityEstimate
          : null,
      rawLabel,
      safetyFlags: Array.isArray(value.safetyFlags)
        ? value.safetyFlags.filter(
            (flag): flag is string => typeof flag === 'string',
          )
        : [],
      unit: typeof value.unit === 'string' ? value.unit : null,
    };
  }
}
