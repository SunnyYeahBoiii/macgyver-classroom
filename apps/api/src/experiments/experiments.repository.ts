import { Injectable } from '@nestjs/common';
import type { ExperimentMaterialRequirement } from './entities/experiment-material-requirement.entity';
import type { ExperimentTemplate } from './entities/experiment-template.entity';

const material = (
  canonicalName: string,
  displayName: string,
): ExperimentMaterialRequirement => ({
  canonicalName,
  displayName,
});

const CURATED_EXPERIMENT_TEMPLATES: ExperimentTemplate[] = [
  {
    estimatedMinutes: 20,
    id: 'bottle-fountain-air-pressure',
    optionalMaterials: [material('straw', 'Straw'), material('tape', 'Tape')],
    requiredMaterials: [
      material('plastic_bottle', 'Plastic bottle'),
      material('water', 'Water'),
    ],
    safetyCategory: 'LOW',
    safetyNotes: [
      {
        category: 'LOW',
        message:
          'Use clean water and keep spills away from electrical outlets.',
      },
    ],
    summary:
      'Compare water flow with and without an air path to observe pressure changes.',
    title: 'Bottle Fountain Air Pressure',
  },
  {
    estimatedMinutes: 15,
    id: 'water-volume-estimator',
    optionalMaterials: [material('paper', 'Paper'), material('ruler', 'Ruler')],
    requiredMaterials: [
      material('plastic_bottle', 'Plastic bottle'),
      material('water', 'Water'),
    ],
    safetyCategory: 'LOW',
    safetyNotes: [
      {
        category: 'LOW',
        message: 'Wipe water from desks after the measurement activity.',
      },
    ],
    summary:
      'Mark water levels on a bottle to estimate volume and compare measurements.',
    title: 'Bottle Volume Estimator',
  },
  {
    estimatedMinutes: 20,
    id: 'rubber-band-sound-box',
    optionalMaterials: [material('string', 'String')],
    requiredMaterials: [
      material('cardboard', 'Cardboard'),
      material('rubber_band', 'Rubber band'),
    ],
    safetyCategory: 'LOW',
    safetyNotes: [
      {
        category: 'LOW',
        message: 'Do not stretch rubber bands toward faces.',
      },
    ],
    summary:
      'Stretch rubber bands over cardboard to compare pitch, vibration, and tension.',
    title: 'Rubber Band Sound Box',
  },
  {
    estimatedMinutes: 25,
    id: 'paper-bridge-load-test',
    optionalMaterials: [material('ruler', 'Ruler'), material('tape', 'Tape')],
    requiredMaterials: [material('paper', 'Paper'), material('coin', 'Coin')],
    safetyCategory: 'LOW',
    safetyNotes: [
      {
        category: 'LOW',
        message: 'Keep coins off the floor after testing bridge strength.',
      },
    ],
    summary:
      'Fold paper into bridge shapes and compare how many coins each shape holds.',
    title: 'Paper Bridge Load Test',
  },
  {
    estimatedMinutes: 35,
    id: 'paper-cup-sound-amplifier',
    optionalMaterials: [material('tape', 'Tape')],
    requiredMaterials: [
      material('paper_cup', 'Paper cup'),
      material('paper_plate', 'Paper plate'),
      material('wooden_fork', 'Wooden fork'),
    ],
    safetyCategory: 'LOW',
    safetyNotes: [
      {
        category: 'LOW',
        message:
          'Use gentle tapping only and replace any cracked wooden forks.',
      },
    ],
    summary:
      'Tap a paper plate with a wooden fork and use a paper cup as a simple sound chamber to compare vibration and loudness.',
    title: 'Paper Cup Sound Amplifier',
  },
  {
    blockedReason: 'Battery circuits need a full teacher safety checklist.',
    disabled: true,
    estimatedMinutes: 25,
    id: 'simple-battery-circuit',
    optionalMaterials: [],
    requiredMaterials: [
      material('battery', 'Battery'),
      material('copper_wire', 'Copper wire'),
      material('led', 'LED'),
    ],
    safetyCategory: 'BLOCKED',
    safetyNotes: [
      {
        category: 'BLOCKED',
        message: 'Do not suggest battery circuit experiments in MVP matching.',
      },
    ],
    summary: 'Build a low-voltage LED circuit with a battery and wire.',
    title: 'Simple Battery Circuit',
  },
];

@Injectable()
export class ExperimentsRepository {
  listTemplates(): ExperimentTemplate[] {
    return CURATED_EXPERIMENT_TEMPLATES.map((template) => ({
      ...template,
      optionalMaterials: template.optionalMaterials.map((item) => ({
        ...item,
      })),
      requiredMaterials: template.requiredMaterials.map((item) => ({
        ...item,
      })),
      safetyNotes: template.safetyNotes.map((note) => ({ ...note })),
    }));
  }

  findTemplate(templateId: string): ExperimentTemplate | undefined {
    return this.listTemplates().find((template) => template.id === templateId);
  }
}
