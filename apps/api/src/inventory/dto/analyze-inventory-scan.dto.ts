import {
  ArrayNotEmpty,
  IsArray,
  IsBase64,
  IsIn,
  IsString,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

export class AnalyzeScanImageDto {
  @IsIn(['image/jpeg', 'image/png', 'image/webp'])
  mimeType!: string;

  @IsString()
  @IsBase64()
  dataBase64!: string;
}

export class AnalyzeInventoryScanDto {
  @IsArray()
  @ArrayNotEmpty()
  @ValidateNested({ each: true })
  @Type(() => AnalyzeScanImageDto)
  images!: AnalyzeScanImageDto[];
}
