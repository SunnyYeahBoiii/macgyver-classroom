import { Injectable } from '@nestjs/common';
import type { ConfirmedItem } from '../inventory/entities/confirmed-item.entity';
import { InventoryService } from '../inventory/inventory.service';
import type { MatchExperimentsDto } from './dto/match-experiments.dto';
import type {
  ExperimentMatch,
  ExperimentMatchedMaterial,
  MatchExperimentsResult,
  UnmatchedConfirmedItem,
} from './entities/experiment-match.entity';
import type { ExperimentTemplate } from './entities/experiment-template.entity';
import { ExperimentsRepository } from './experiments.repository';

const DEFAULT_MAX_SUGGESTIONS = 3;
const BLOCKED_MATERIALS = new Set(['battery']);
const BLOCKING_SAFETY_FLAG_PATTERNS = [
  'do not disassemble battery',
  'hazard',
  'khong thao pin',
  'không tháo pin',
  'unsafe',
];

type TemplateCandidate = {
  match: ExperimentMatch;
  blocked: boolean;
};

@Injectable()
export class MatchingService {
  constructor(
    private readonly inventoryService: InventoryService,
    private readonly experimentsRepository: ExperimentsRepository,
  ) {}

  match(dto: MatchExperimentsDto): MatchExperimentsResult {
    const confirmedItems = this.inventoryService.getActiveConfirmedItems(
      dto.scanId,
    );
    const materialsByName = this.materialLookup(confirmedItems);
    const candidates = this.experimentsRepository
      .listTemplates()
      .map((template) => this.toCandidate(template, materialsByName))
      .filter((candidate): candidate is TemplateCandidate => !!candidate);
    const blockedSuggestionCount = candidates.filter(
      (candidate) => candidate.blocked,
    ).length;
    const maxSuggestions = this.maxSuggestions(dto.maxSuggestions);
    const matches = candidates
      .filter((candidate) => !candidate.blocked)
      .map((candidate) => candidate.match)
      .sort(
        (left, right) =>
          right.score - left.score || left.title.localeCompare(right.title),
      )
      .slice(0, maxSuggestions);

    return {
      blockedSuggestionCount,
      confirmedItemCount: confirmedItems.length,
      matches,
      noMatches: matches.length === 0,
      scanId: dto.scanId,
      unmatchedConfirmedItems: this.unmatchedConfirmedItems(
        confirmedItems,
        matches,
      ),
    };
  }

  private materialLookup(
    confirmedItems: ConfirmedItem[],
  ): Map<string, ConfirmedItem> {
    const materialsByName = new Map<string, ConfirmedItem>();
    for (const item of confirmedItems) {
      if (item.canonicalName && !materialsByName.has(item.canonicalName)) {
        materialsByName.set(item.canonicalName, item);
      }
    }
    return materialsByName;
  }

  private toCandidate(
    template: ExperimentTemplate,
    materialsByName: Map<string, ConfirmedItem>,
  ): TemplateCandidate | null {
    const requiredItems = template.requiredMaterials.map((requirement) =>
      materialsByName.get(requirement.canonicalName),
    );
    if (requiredItems.some((item) => !item)) return null;

    const matchedRequired = requiredItems.filter(
      (item): item is ConfirmedItem => !!item,
    );
    const matchedOptional = template.optionalMaterials
      .map((requirement) => materialsByName.get(requirement.canonicalName))
      .filter((item): item is ConfirmedItem => !!item);
    const matchedItems = [...matchedRequired, ...matchedOptional];

    return {
      blocked: this.isBlocked(template, matchedItems),
      match: {
        estimatedMinutes: template.estimatedMinutes,
        matchedMaterials: matchedItems.map((item) =>
          this.toMatchedMaterial(item),
        ),
        missingMaterials: [],
        safetyCategory: template.safetyCategory,
        safetyNotes: template.safetyNotes.map((note) => note.message),
        score: matchedRequired.length + matchedOptional.length * 0.25,
        summary: template.summary,
        templateId: template.id,
        title: template.title,
      },
    };
  }

  private isBlocked(
    template: ExperimentTemplate,
    matchedItems: ConfirmedItem[],
  ): boolean {
    if (template.disabled || template.safetyCategory === 'BLOCKED') return true;

    return matchedItems.some(
      (item) =>
        (item.canonicalName && BLOCKED_MATERIALS.has(item.canonicalName)) ||
        item.safetyFlags.some((flag) =>
          BLOCKING_SAFETY_FLAG_PATTERNS.some((pattern) =>
            flag.toLowerCase().includes(pattern),
          ),
        ),
    );
  }

  private toMatchedMaterial(item: ConfirmedItem): ExperimentMatchedMaterial {
    return {
      canonicalName: item.canonicalName ?? item.displayName,
      displayName: item.displayName,
      quantityEstimate: item.quantityEstimate,
      unit: item.unit,
    };
  }

  private unmatchedConfirmedItems(
    confirmedItems: ConfirmedItem[],
    matches: ExperimentMatch[],
  ): UnmatchedConfirmedItem[] {
    const matchedMaterialNames = new Set(
      matches.flatMap((match) =>
        match.matchedMaterials.map((material) => material.canonicalName),
      ),
    );

    return confirmedItems
      .filter(
        (item) =>
          !item.canonicalName || !matchedMaterialNames.has(item.canonicalName),
      )
      .map((item) => ({
        canonicalName: item.canonicalName,
        displayName: item.displayName,
        id: item.id,
      }));
  }

  private maxSuggestions(maxSuggestions: number | undefined): number {
    if (maxSuggestions === undefined) return DEFAULT_MAX_SUGGESTIONS;
    return Math.min(Math.max(maxSuggestions, 1), 5);
  }
}
