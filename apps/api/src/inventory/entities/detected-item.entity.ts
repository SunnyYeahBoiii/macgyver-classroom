export class DetectedItem {
  rawLabel!: string;
  canonicalName!: string | null;
  displayName!: string;
  quantityEstimate!: number | null;
  unit!: string | null;
  confidence!: number | null;
  evidence!: string[];
  safetyFlags!: string[];
  removed?: boolean;
}
