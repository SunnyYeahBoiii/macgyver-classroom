import type { MaterialCatalogItem } from '../materials/static-material-catalog';

export const MATERIAL_VISION_PROVIDER = Symbol('MATERIAL_VISION_PROVIDER');

export type MaterialScanImage = {
  mimeType: string;
  dataBase64: string;
};

export type MaterialVisionItem = {
  rawLabel: string;
  displayName: string;
  canonicalName: string | null;
  quantityEstimate: number | null;
  unit: string | null;
  confidence: number | null;
  evidence: string | string[] | null;
  safetyFlags: string[];
};

export type MaterialVisionResult = {
  items: MaterialVisionItem[];
  noMaterialsDetected: boolean;
  message: string | null;
};

export type AnalyzeMaterialImagesInput = {
  images: MaterialScanImage[];
  catalog: MaterialCatalogItem[];
};

export interface MaterialVisionProvider {
  readonly modelName: string;
  readonly providerName: string;

  analyzeMaterials(
    input: AnalyzeMaterialImagesInput,
  ): Promise<MaterialVisionResult>;
}
