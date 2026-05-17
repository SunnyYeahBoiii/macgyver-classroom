export type SafetyCategory = 'LOW' | 'MEDIUM' | 'HIGH' | 'BLOCKED';

export class ExperimentSafetyNote {
  category!: SafetyCategory;
  message!: string;
}
