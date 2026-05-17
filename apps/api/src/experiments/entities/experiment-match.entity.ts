import type { SafetyCategory } from './experiment-safety-note.entity';

export class ExperimentMatchedMaterial {
  canonicalName!: string;
  displayName!: string;
  quantityEstimate!: number | null;
  unit!: string | null;
}

export class ExperimentMatch {
  templateId!: string;
  title!: string;
  summary!: string;
  score!: number;
  matchedMaterials!: ExperimentMatchedMaterial[];
  missingMaterials!: string[];
  safetyCategory!: SafetyCategory;
  safetyNotes!: string[];
  estimatedMinutes!: number;
}

export class UnmatchedConfirmedItem {
  id!: string;
  canonicalName!: string | null;
  displayName!: string;
}

export class MatchExperimentsResult {
  scanId!: string;
  confirmedItemCount!: number;
  matches!: ExperimentMatch[];
  noMatches!: boolean;
  unmatchedConfirmedItems!: UnmatchedConfirmedItem[];
  blockedSuggestionCount!: number;
}
