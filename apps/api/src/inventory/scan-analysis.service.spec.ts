import { Test, TestingModule } from '@nestjs/testing';
import { ScanAnalysisService } from './scan-analysis.service';
import { GeminiVisionService } from '../ai/gemini-vision.service';
import { AiRunService } from '../ai/ai-run.service';

describe('ScanAnalysisService', () => {
  let service: ScanAnalysisService;
  let geminiVisionService: GeminiVisionService;
  let aiRunService: AiRunService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ScanAnalysisService,
        {
          provide: GeminiVisionService,
          useValue: {
            analyzeClassroomImages: jest.fn(),
          },
        },
        {
          provide: AiRunService,
          useValue: {
            recordRun: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<ScanAnalysisService>(ScanAnalysisService);
    geminiVisionService = module.get<GeminiVisionService>(GeminiVisionService);
    aiRunService = module.get<AiRunService>(AiRunService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('analyzeScan', () => {
    it('should successfully analyze scan with detected items', async () => {
      const mockVisionResult = {
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
        metadata: {
          model: 'gemini-1.5-flash',
          timestamp: new Date().toISOString(),
          processing_time_ms: 1500,
        },
      };

      jest.spyOn(geminiVisionService, 'analyzeClassroomImages').mockResolvedValue(mockVisionResult);

      const result = await service.analyzeScan(
        'scan_123',
        [{ data: 'base64data', mimeType: 'image/jpeg' }],
        { grade: '5', subject: 'Science' },
      );

      expect(result.status).toBe('success');
      expect(result.detectedItems).toHaveLength(1);
      expect(result.detectedItems[0].canonical_name).toBe('chai nhua');
      expect(geminiVisionService.analyzeClassroomImages).toHaveBeenCalledWith(
        [{ data: 'base64data', mimeType: 'image/jpeg' }],
        { grade: '5', subject: 'Science', topic: undefined },
      );
    });

    it('should handle analysis failure', async () => {
      jest.spyOn(geminiVisionService, 'analyzeClassroomImages').mockRejectedValue(
        new Error('API error'),
      );

      const result = await service.analyzeScan(
        'scan_123',
        [{ data: 'base64data', mimeType: 'image/jpeg' }],
      );

      expect(result.status).toBe('failed');
      expect(result.error).toBe('API error');
      expect(result.detectedItems).toEqual([]);
    });

    it('should handle multiple images', async () => {
      const mockVisionResult = {
        items: [
          {
            raw_label: 'bottle',
            canonical_name: 'chai nhua',
            quantity_estimate: 1,
            confidence: 0.9,
            evidence: 'visible',
            safety_flags: [],
          },
          {
            raw_label: 'rubber band',
            canonical_name: 'day thun',
            quantity_estimate: 5,
            confidence: 0.85,
            evidence: 'multiple bands',
            safety_flags: [],
          },
        ],
        metadata: {
          model: 'gemini-1.5-flash',
          timestamp: new Date().toISOString(),
          processing_time_ms: 2000,
        },
      };

      jest.spyOn(geminiVisionService, 'analyzeClassroomImages').mockResolvedValue(mockVisionResult);

      const result = await service.analyzeScan('scan_123', [
        { data: 'image1', mimeType: 'image/jpeg' },
        { data: 'image2', mimeType: 'image/png' },
      ]);

      expect(result.status).toBe('success');
      expect(result.detectedItems).toHaveLength(2);
    });
  });

  describe('validateDetectedItems', () => {
    it('should validate items with good confidence', () => {
      const items = [
        {
          raw_label: 'bottle',
          canonical_name: 'chai nhua',
          quantity_estimate: 2,
          confidence: 0.95,
          evidence: 'visible',
          safety_flags: [],
        },
      ];

      const result = service.validateDetectedItems(items);
      expect(result.valid).toHaveLength(1);
      expect(result.warnings).toHaveLength(0);
    });

    it('should warn about low confidence items', () => {
      const items = [
        {
          raw_label: 'bottle',
          canonical_name: 'chai nhua',
          quantity_estimate: 2,
          confidence: 0.3, // Low confidence
          evidence: 'unclear',
          safety_flags: [],
        },
      ];

      const result = service.validateDetectedItems(items);
      expect(result.valid).toHaveLength(1);
      expect(result.warnings).toHaveLength(1);
      expect(result.warnings[0]).toContain('Low confidence');
    });

    it('should warn about safety flags', () => {
      const items = [
        {
          raw_label: 'knife',
          canonical_name: 'dao',
          quantity_estimate: 1,
          confidence: 0.95,
          evidence: 'sharp object',
          safety_flags: ['sharp_edges', 'requires_supervision'],
        },
      ];

      const result = service.validateDetectedItems(items);
      expect(result.valid).toHaveLength(1);
      expect(result.warnings).toHaveLength(1);
      expect(result.warnings[0]).toContain('Safety concerns');
      expect(result.warnings[0]).toContain('sharp_edges');
    });

    it('should handle multiple validation issues', () => {
      const items = [
        {
          raw_label: 'chemical',
          canonical_name: 'hoa chat',
          quantity_estimate: 1,
          confidence: 0.4, // Low confidence
          evidence: 'unclear bottle',
          safety_flags: ['chemical', 'toxic'], // Safety concerns
        },
      ];

      const result = service.validateDetectedItems(items);
      expect(result.valid).toHaveLength(1);
      expect(result.warnings).toHaveLength(2); // Both low confidence and safety warnings
    });

    it('should handle empty items array', () => {
      const result = service.validateDetectedItems([]);
      expect(result.valid).toEqual([]);
      expect(result.warnings).toEqual([]);
    });
  });
});

// Made with Bob
