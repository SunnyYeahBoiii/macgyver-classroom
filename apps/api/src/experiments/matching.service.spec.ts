import { BadRequestException } from '@nestjs/common';
import type { DetectedItem } from '../inventory/entities/detected-item.entity';
import { InventoryRepository } from '../inventory/inventory.repository';
import { InventoryService } from '../inventory/inventory.service';
import { ExperimentsRepository } from './experiments.repository';
import { MatchingService } from './matching.service';

const detectedItem = (
  canonicalName: string | null,
  displayName: string,
): DetectedItem => ({
  canonicalName,
  confidence: 0.9,
  displayName,
  evidence: [],
  quantityEstimate: 1,
  rawLabel: displayName,
  safetyFlags: [],
  unit: 'item',
});

describe('MatchingService', () => {
  const createSubject = () => {
    const inventoryRepository = new InventoryRepository();
    const inventoryService = new InventoryService(inventoryRepository);
    const experimentsRepository = new ExperimentsRepository();
    const service = new MatchingService(
      inventoryService,
      experimentsRepository,
    );

    return { inventoryService, service };
  };

  const confirmedScanId = (
    inventoryService: InventoryService,
    items: DetectedItem[],
  ): string => {
    const scan = inventoryService.createDraft({});
    inventoryService.updateItems(scan.id, items);
    return inventoryService.confirm(scan.id).id;
  };

  it('requires a confirmed inventory scan', () => {
    const { inventoryService, service } = createSubject();
    const scan = inventoryService.createDraft({});

    expect(() => service.match({ scanId: scan.id })).toThrow(
      BadRequestException,
    );
  });

  it('returns ranked suggestions that depend on confirmed items', () => {
    const { inventoryService, service } = createSubject();
    const bottleScanId = confirmedScanId(inventoryService, [
      detectedItem('plastic_bottle', 'Plastic bottle'),
      detectedItem('water', 'Water'),
      detectedItem('straw', 'Straw'),
    ]);
    const soundScanId = confirmedScanId(inventoryService, [
      detectedItem('cardboard', 'Cardboard'),
      detectedItem('rubber_band', 'Rubber band'),
    ]);

    const bottleResult = service.match({
      maxSuggestions: 1,
      scanId: bottleScanId,
    });
    const soundResult = service.match({ scanId: soundScanId });

    expect(bottleResult.matches).toHaveLength(1);
    const [bottleMatch] = bottleResult.matches;
    expect(bottleMatch).toMatchObject({
      missingMaterials: [],
      templateId: 'bottle-fountain-air-pressure',
    });
    expect(bottleMatch?.matchedMaterials).toEqual(
      expect.arrayContaining([
        expect.objectContaining({ canonicalName: 'plastic_bottle' }),
        expect.objectContaining({ canonicalName: 'water' }),
      ]),
    );
    expect(soundResult.matches.map((match) => match.templateId)).toContain(
      'rubber-band-sound-box',
    );
    expect(soundResult.matches.map((match) => match.templateId)).not.toContain(
      'bottle-fountain-air-pressure',
    );
  });

  it('returns an explicit no-match result for confirmed items without a template', () => {
    const { inventoryService, service } = createSubject();
    const scanId = confirmedScanId(inventoryService, [
      detectedItem('marble', 'Marble'),
    ]);

    expect(service.match({ scanId })).toMatchObject({
      confirmedItemCount: 1,
      matches: [],
      noMatches: true,
      scanId,
    });
  });

  it('matches paper cup paper plate and wooden fork to the sound amplifier lesson', () => {
    const { inventoryService, service } = createSubject();
    const scanId = confirmedScanId(inventoryService, [
      detectedItem('paper_cup', 'Paper cup'),
      detectedItem('paper_plate', 'Paper plate'),
      detectedItem('wooden_fork', 'Wooden fork'),
    ]);

    const result = service.match({ scanId });

    const [match] = result.matches;
    expect(match).toMatchObject({
      missingMaterials: [],
      templateId: 'paper-cup-sound-amplifier',
      title: 'Paper Cup Sound Amplifier',
    });
    expect(match?.matchedMaterials).toEqual(
      expect.arrayContaining([
        expect.objectContaining({ canonicalName: 'paper_cup' }),
        expect.objectContaining({ canonicalName: 'paper_plate' }),
        expect.objectContaining({ canonicalName: 'wooden_fork' }),
      ]),
    );
  });

  it('returns no matches when confirmed items have no canonical material names', () => {
    const { inventoryService, service } = createSubject();
    const scanId = confirmedScanId(inventoryService, [
      detectedItem(null, 'Mystery classroom item'),
    ]);

    expect(service.match({ scanId })).toMatchObject({
      confirmedItemCount: 1,
      matches: [],
      noMatches: true,
      unmatchedConfirmedItems: [
        expect.objectContaining({ displayName: 'Mystery classroom item' }),
      ],
    });
  });

  it('filters blocked unsafe templates from suggestions', () => {
    const { inventoryService, service } = createSubject();
    const scanId = confirmedScanId(inventoryService, [
      detectedItem('battery', 'Battery'),
      detectedItem('copper_wire', 'Copper wire'),
      detectedItem('led', 'LED'),
    ]);

    expect(service.match({ scanId })).toMatchObject({
      blockedSuggestionCount: 1,
      matches: [],
      noMatches: true,
    });
  });
});
