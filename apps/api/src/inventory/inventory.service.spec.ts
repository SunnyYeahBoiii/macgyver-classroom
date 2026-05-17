import { BadRequestException } from '@nestjs/common';
import { InventoryRepository } from './inventory.repository';
import { InventoryService } from './inventory.service';

const reviewedItem = {
  canonicalName: 'plastic_bottle',
  confidence: 0.9,
  displayName: 'Plastic bottle',
  evidence: ['label visible'],
  quantityEstimate: 1,
  rawLabel: 'plastic bottle',
  safetyFlags: [],
  unit: 'item',
};

describe('InventoryService', () => {
  const createSubject = () => {
    const repository = new InventoryRepository();
    const service = new InventoryService(repository);

    return { repository, service };
  };

  it('rejects confirming a scan before items have been reviewed', () => {
    const { service } = createSubject();
    const scan = service.createDraft({});

    expect(() => service.confirm(scan.id)).toThrow(BadRequestException);
  });

  it('rejects confirming a reviewed scan with no detected items', () => {
    const { service } = createSubject();
    const scan = service.createDraft({});
    service.updateItems(scan.id, []);

    expect(() => service.confirm(scan.id)).toThrow(BadRequestException);
  });

  it('rejects confirming a reviewed scan when all detected items were removed', () => {
    const { service } = createSubject();
    const scan = service.createDraft({});
    service.updateItems(scan.id, [{ ...reviewedItem, removed: true }]);

    expect(() => service.confirm(scan.id)).toThrow(BadRequestException);
  });

  it('confirms a reviewed scan with at least one detected item', () => {
    const { service } = createSubject();
    const scan = service.createDraft({});
    service.updateItems(scan.id, [reviewedItem]);

    expect(service.confirm(scan.id)).toMatchObject({
      id: scan.id,
      status: 'CONFIRMED',
      detectedItems: [reviewedItem],
    });
  });

  it('creates confirmed item snapshots from active reviewed items', () => {
    const { service } = createSubject();
    const scan = service.createDraft({});
    service.updateItems(scan.id, [
      reviewedItem,
      {
        ...reviewedItem,
        canonicalName: 'paper',
        displayName: 'Removed paper',
        rawLabel: 'paper',
        removed: true,
      },
    ]);

    const confirmedScan = service.confirm(scan.id);

    expect(confirmedScan.confirmedItems).toEqual([
      expect.objectContaining({
        active: true,
        canonicalName: 'plastic_bottle',
        displayName: 'Plastic bottle',
        quantityEstimate: 1,
        rawLabel: 'plastic bottle',
        safetyFlags: [],
        scanId: scan.id,
        unit: 'item',
      }),
    ]);
    expect(confirmedScan.confirmedItems?.[0]?.id).toEqual(expect.any(String));
    expect(confirmedScan.confirmedItems?.[0]?.confirmedAt).toEqual(
      expect.any(String),
    );
  });
});
