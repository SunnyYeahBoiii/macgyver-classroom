import { IsOptional, IsString } from 'class-validator';

export class CreateInventoryScanDto {
  @IsOptional()
  @IsString()
  subject?: string;

  @IsOptional()
  @IsString()
  gradeBand?: string;

  @IsOptional()
  @IsString()
  classLabel?: string;

  @IsOptional()
  @IsString()
  topic?: string;
}
