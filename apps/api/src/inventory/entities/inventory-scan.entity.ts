import { ConfirmedItem } from './confirmed-item.entity';
import { DetectedItem } from './detected-item.entity';

export type InventoryScanStatus =
  | 'CREATED'
  | 'UPLOADED'
  | 'ANALYZING'
  | 'NEEDS_CONFIRMATION'
  | 'CONFIRMED'
  | 'FAILED';

export class InventoryScan {
  id!: string;
  status!: InventoryScanStatus;
  subject?: string;
  gradeBand?: string;
  classLabel?: string;
  topic?: string;
  errorCode?: string;
  errorMessage?: string;
  detectedItems!: DetectedItem[];
  confirmedItems!: ConfirmedItem[];
}
