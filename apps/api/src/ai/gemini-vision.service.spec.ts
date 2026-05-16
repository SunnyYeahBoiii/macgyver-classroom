import { Test, TestingModule } from '@nestjs/testing';
import { GeminiVisionService } from './gemini-vision.service';
import { ApiConfigService } from '../config/api-config.service';

describe('GeminiVisionService', () => {
  let service: GeminiVisionService;
  let configService: ApiConfigService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        GeminiVisionService,
        {
          provide: ApiConfigService,
          useValue: {
            get: jest.fn().mockReturnValue('test-api-key'),
          },
        },
      ],
    }).compile();

    service = module.get<GeminiVisionService>(GeminiVisionService);
    configService = module.get<ApiConfigService>(ApiConfigService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('parseVisionResponse', () => {
    it('should parse valid JSON response', () => {
      const jsonText = JSON.stringify({
        items: [
          {
            raw_label: 'plastic bottle',
            canonical_name: 'chai nhua',
            quantity_estimate: 2,
            confidence: 0.95,
            evidence: 'Two bottles visible',
            safety_flags: [],
          },
        ],
      });

      const result = service['parseVisionResponse'](jsonText);
      expect(result.items).toHaveLength(1);
      expect(result.items[0].canonical_name).toBe('chai nhua');
    });

    it('should parse JSON with markdown code blocks', () => {
      const jsonText = '```json\n{"items": []}\n```';
      const result = service['parseVisionResponse'](jsonText);
      expect(result.items).toEqual([]);
    });

    it('should throw error for invalid JSON', () => {
      expect(() => {
        service['parseVisionResponse']('invalid json');
      }).toThrow();
    });

    it('should throw error for missing items array', () => {
      expect(() => {
        service['parseVisionResponse']('{"data": []}');
      }).toThrow('Invalid response format: missing items array');
    });
  });

  describe('validateAndEnrichItems', () => {
    it('should validate and enrich valid items', () => {
      const items = [
        {
          raw_label: 'bottle',
          canonical_name: 'chai nhua',
          quantity_estimate: 3,
          confidence: 0.9,
          evidence: 'visible',
          safety_flags: [],
        },
      ];

      const result = service['validateAndEnrichItems'](items);
      expect(result).toHaveLength(1);
      expect(result[0].confidence).toBe(0.9);
    });

    it('should bound confidence values', () => {
      const items = [
        {
          raw_label: 'bottle',
          canonical_name: 'chai nhua',
          quantity_estimate: 1,
          confidence: 1.5, // Invalid: > 1
          evidence: 'visible',
          safety_flags: [],
        },
      ];

      const result = service['validateAndEnrichItems'](items);
      expect(result[0].confidence).toBe(1);
    });

    it('should ensure minimum quantity', () => {
      const items = [
        {
          raw_label: 'bottle',
          canonical_name: 'chai nhua',
          quantity_estimate: 0, // Invalid: < 1
          confidence: 0.9,
          evidence: 'visible',
          safety_flags: [],
        },
      ];

      const result = service['validateAndEnrichItems'](items);
      expect(result[0].quantity_estimate).toBe(1);
    });

    it('should filter items with missing labels', () => {
      const items = [
        {
          raw_label: '',
          canonical_name: '',
          quantity_estimate: 1,
          confidence: 0.9,
          evidence: 'visible',
          safety_flags: [],
        },
      ];

      const result = service['validateAndEnrichItems'](items);
      expect(result).toHaveLength(0);
    });

    it('should ensure safety_flags is an array', () => {
      const items = [
        {
          raw_label: 'knife',
          canonical_name: 'dao',
          quantity_estimate: 1,
          confidence: 0.9,
          evidence: 'visible',
          safety_flags: null as any,
        },
      ];

      const result = service['validateAndEnrichItems'](items);
      expect(Array.isArray(result[0].safety_flags)).toBe(true);
    });
  });

  describe('buildDetectionPrompt', () => {
    it('should build prompt without context', () => {
      const prompt = service['buildDetectionPrompt']();
      expect(prompt).toContain('classroom materials detection');
      expect(prompt).toContain('Vietnamese');
    });

    it('should build prompt with context', () => {
      const prompt = service['buildDetectionPrompt']({
        grade: '5',
        subject: 'Physics',
        topic: 'Pressure',
      });
      expect(prompt).toContain('Grade 5');
      expect(prompt).toContain('Physics');
      expect(prompt).toContain('Pressure');
    });
  });
});

// Made with Bob
