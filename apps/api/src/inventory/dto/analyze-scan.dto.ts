import { IsString, IsArray, IsOptional, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

export class ScanImageDto {
  @IsString()
  data: string;

  @IsString()
  mimeType: string;

  @IsOptional()
  @IsString()
  url?: string;
}

export class AnalyzeScanDto {
  @IsString()
  scanId: string;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ScanImageDto)
  images: ScanImageDto[];

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

export class AnalyzeScanResponseDto {
  @IsString()
  scanId: string;

  @IsArray()
  detectedItems: Array<{
    raw_label: string;
    canonical_name: string;
    quantity_estimate: number;
    confidence: number;
    evidence: string;
    safety_flags: string[];
  }>;

  @IsOptional()
  @IsString()
  aiRunId?: string;

  @IsString()
  status: 'success' | 'failed' | 'partial';

  @IsOptional()
  @IsString()
  error?: string;

  @IsOptional()
  @IsArray()
  warnings?: string[];
}

// Made with Bob
