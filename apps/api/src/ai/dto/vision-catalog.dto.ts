import { IsString, IsNumber, IsArray, IsOptional, Min, Max, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

export class DetectedItemDto {
  @IsString()
  raw_label: string;

  @IsString()
  canonical_name: string;

  @IsNumber()
  @Min(1)
  quantity_estimate: number;

  @IsNumber()
  @Min(0)
  @Max(1)
  confidence: number;

  @IsString()
  evidence: string;

  @IsArray()
  @IsString({ each: true })
  safety_flags: string[];
}

export class VisionCatalogRequestDto {
  @IsArray()
  @IsString({ each: true })
  image_urls: string[];

  @IsOptional()
  @IsString()
  grade?: string;

  @IsOptional()
  @IsString()
  subject?: string;

  @IsOptional()
  @IsString()
  topic?: string;
}

export class VisionCatalogResponseDto {
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => DetectedItemDto)
  items: DetectedItemDto[];

  @IsOptional()
  metadata?: {
    model: string;
    timestamp: string;
    processing_time_ms: number;
  };
}

export class AnalyzeImagesDto {
  @IsArray()
  images: Array<{
    data: string;
    mimeType: string;
  }>;

  @IsOptional()
  @IsString()
  grade?: string;

  @IsOptional()
  @IsString()
  subject?: string;

  @IsOptional()
  @IsString()
  topic?: string;
}

// Made with Bob
