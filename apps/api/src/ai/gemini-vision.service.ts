import { Injectable, Logger } from '@nestjs/common';
import { VertexAI } from '@google-cloud/vertexai';
import { GoogleAuth } from 'google-auth-library';
import { ApiConfigService } from '../config/api-config.service';

export interface DetectedItem {
  raw_label: string;
  canonical_name: string;
  quantity_estimate: number;
  confidence: number;
  evidence: string;
  safety_flags: string[];
}

export interface VisionCatalogResponse {
  items: DetectedItem[];
  metadata?: {
    model: string;
    timestamp: string;
    processing_time_ms: number;
  };
}

@Injectable()
export class GeminiVisionService {
  private readonly logger = new Logger(GeminiVisionService.name);
  private vertexAI: VertexAI;
  private model: any;

  constructor(private readonly configService: ApiConfigService) {
    this.initializeGemini();
  }

  /**
   * Initialize Gemini API with Vertex AI using Service Account
   */
  private async initializeGemini() {
    const useADC = this.configService.get<string>('USE_GOOGLE_ADC') === 'true';
    const projectId = this.configService.get<string>('GOOGLE_CLOUD_PROJECT');
    const credentialsPath = this.configService.get<string>('GOOGLE_APPLICATION_CREDENTIALS');

    try {
      if (!useADC || !projectId) {
        this.logger.warn(
          'Vertex AI not configured. Set USE_GOOGLE_ADC=true and GOOGLE_CLOUD_PROJECT',
        );
        return;
      }

      this.logger.log('Initializing Vertex AI with Service Account');
      this.logger.log(`Project ID: ${projectId}`);
      this.logger.log(`Credentials: ${credentialsPath}`);

      // Initialize GoogleAuth with service account
      const auth = new GoogleAuth({
        keyFilename: credentialsPath,
        scopes: ['https://www.googleapis.com/auth/cloud-platform'],
      });

      // Initialize Vertex AI
      this.vertexAI = new VertexAI({
        project: projectId,
        location: 'us-central1', // or 'asia-southeast1' for closer region
        googleAuth: auth,
      });

      this.logger.log('Vertex AI initialized successfully');
    } catch (error) {
      this.logger.error('Failed to initialize Vertex AI', error);
      throw error;
    }
  }

  /**
   * Analyze classroom images and detect objects using Gemini Vision API
   * @param imageData Array of base64 encoded images or image URLs
   * @param context Optional context about the classroom (grade, subject, etc.)
   * @returns Detected items with properties
   */
  async analyzeClassroomImages(
    imageData: Array<{ data: string; mimeType: string }>,
    context?: {
      grade?: string;
      subject?: string;
      topic?: string;
    },
  ): Promise<VisionCatalogResponse> {
    const startTime = Date.now();

    if (!this.vertexAI) {
      throw new Error('Vertex AI not configured. Please check your service account setup');
    }

    try {
      this.logger.log(`Analyzing ${imageData.length} classroom images`);

      // Build the prompt for classroom object detection
      const prompt = this.buildDetectionPrompt(context);

      // Get the generative model
      const model = this.vertexAI.getGenerativeModel({
        model: 'gemini-3.1-flash-lite',
        generationConfig: {
          temperature: 0.4,
          topK: 32,
          topP: 1,
          maxOutputTokens: 4096,
        },
      });

      // Prepare content parts for Vertex AI
      const parts = [
        { text: prompt },
        ...imageData.map((img) => ({
          inlineData: {
            data: img.data,
            mimeType: img.mimeType,
          },
        })),
      ];

      // Call Vertex AI Gemini API
      const result = await model.generateContent({
        contents: [{ role: 'user', parts }],
      });

      const response = result.response;
      
      // Safely extract text from response
      if (!response.candidates || response.candidates.length === 0) {
        throw new Error('No candidates returned from Gemini API');
      }
      
      const firstCandidate = response.candidates[0];
      if (!firstCandidate.content?.parts || firstCandidate.content.parts.length === 0) {
        throw new Error('No content parts in Gemini response');
      }
      
      const text = firstCandidate.content.parts[0].text;
      if (!text) {
        throw new Error('No text content in Gemini response');
      }

      this.logger.debug(`Gemini response: ${text}`);

      // Parse the JSON response
      const parsedResponse = this.parseVisionResponse(text);

      // Validate and enrich the response
      const validatedItems = this.validateAndEnrichItems(parsedResponse.items);

      const processingTime = Date.now() - startTime;

      return {
        items: validatedItems,
        metadata: {
          model: 'gemini-3.1-flash-lite',
          timestamp: new Date().toISOString(),
          processing_time_ms: processingTime,
        },
      };
    } catch (error) {
      this.logger.error('Error analyzing images with Gemini', error);
      throw new Error(`Vision analysis failed: ${error.message}`);
    }
  }

  /**
   * Build the detection prompt for Gemini
   */
  private buildDetectionPrompt(context?: {
    grade?: string;
    subject?: string;
    topic?: string;
  }): string {
    const contextInfo = context
      ? `\nContext: Grade ${context.grade || 'unknown'}, Subject: ${context.subject || 'Science'}, Topic: ${context.topic || 'general'}`
      : '';

    return `You are a classroom materials detection assistant for Vietnamese science teachers. Analyze the provided classroom images and identify all objects that could be used for science experiments.

${contextInfo}

For each detected object, provide:
1. raw_label: The object name as you see it (in English)
2. canonical_name: The Vietnamese name commonly used in classrooms (e.g., "chai nhua" for plastic bottle, "day thun" for rubber band)
3. quantity_estimate: Estimated number of items visible
4. confidence: Your confidence level (0.0 to 1.0)
5. evidence: Brief description of what you see that identifies this object
6. safety_flags: Array of safety concerns (e.g., ["sharp_edges"], ["chemical"], ["heat_source"], or [] if safe)

Focus on common classroom materials like:
- Containers: plastic bottles, cups, jars, beakers
- Tools: scissors, rulers, magnifying glass, thermometer
- Materials: paper, cardboard, rubber bands, string, tape
- Science equipment: magnets, batteries, wires, bulbs
- Natural items: rocks, leaves, water, soil

Return ONLY a valid JSON object in this exact format:
{
  "items": [
    {
      "raw_label": "plastic bottle",
      "canonical_name": "chai nhua",
      "quantity_estimate": 3,
      "confidence": 0.95,
      "evidence": "Three clear plastic bottles visible on the desk, blue caps",
      "safety_flags": []
    }
  ]
}

Important:
- Return ONLY the JSON object, no additional text
- Confidence must be between 0.0 and 1.0
- Use Vietnamese names for canonical_name
- Include safety_flags for any potentially dangerous items
- If you see no relevant classroom materials, return {"items": []}`;
  }

  /**
   * Parse the vision response from Gemini
   */
  private parseVisionResponse(text: string): { items: DetectedItem[] } {
    try {
      // Remove markdown code blocks if present
      let cleanText = text.trim();
      if (cleanText.startsWith('```json')) {
        cleanText = cleanText.replace(/```json\n?/g, '').replace(/```\n?/g, '');
      } else if (cleanText.startsWith('```')) {
        cleanText = cleanText.replace(/```\n?/g, '');
      }

      const parsed = JSON.parse(cleanText);

      if (!parsed.items || !Array.isArray(parsed.items)) {
        throw new Error('Invalid response format: missing items array');
      }

      return parsed;
    } catch (error) {
      this.logger.error('Failed to parse Gemini response', error);
      this.logger.debug(`Raw response: ${text}`);
      throw new Error(`Failed to parse vision response: ${error.message}`);
    }
  }

  /**
   * Validate and enrich detected items
   */
  private validateAndEnrichItems(items: DetectedItem[]): DetectedItem[] {
    return items
      .filter((item) => {
        // Basic validation
        if (!item.raw_label || !item.canonical_name) {
          this.logger.warn('Skipping item with missing labels', item);
          return false;
        }
        return true;
      })
      .map((item) => ({
        ...item,
        // Ensure confidence is bounded
        confidence: Math.max(0, Math.min(1, item.confidence || 0)),
        // Ensure quantity is positive
        quantity_estimate: Math.max(1, item.quantity_estimate || 1),
        // Ensure safety_flags is an array
        safety_flags: Array.isArray(item.safety_flags) ? item.safety_flags : [],
        // Ensure evidence exists
        evidence: item.evidence || 'Detected in image',
      }));
  }

  /**
   * Analyze a single image (convenience method)
   */
  async analyzeSingleImage(
    imageData: string,
    mimeType: string,
    context?: { grade?: string; subject?: string; topic?: string },
  ): Promise<VisionCatalogResponse> {
    return this.analyzeClassroomImages([{ data: imageData, mimeType }], context);
  }
}

// Made with Bob
