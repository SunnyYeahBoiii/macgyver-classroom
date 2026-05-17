import type { ExperimentMaterialRequirement } from './experiment-material-requirement.entity';
import type {
  ExperimentSafetyNote,
  SafetyCategory,
} from './experiment-safety-note.entity';

export class ExperimentTemplate {
  id!: string;
  title!: string;
  summary!: string;
  requiredMaterials!: ExperimentMaterialRequirement[];
  optionalMaterials!: ExperimentMaterialRequirement[];
  safetyCategory!: SafetyCategory;
  safetyNotes!: ExperimentSafetyNote[];
  estimatedMinutes!: number;
  disabled?: boolean;
  blockedReason?: string;
}
