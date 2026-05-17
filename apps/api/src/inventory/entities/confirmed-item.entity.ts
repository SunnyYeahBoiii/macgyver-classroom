export class ConfirmedItem {
  id!: string;
  scanId!: string;
  rawLabel!: string;
  canonicalName!: string | null;
  displayName!: string;
  quantityEstimate!: number | null;
  unit!: string | null;
  confidence!: number | null;
  evidence!: string[];
  safetyFlags!: string[];
  active!: boolean;
  confirmedAt!: string;
}
