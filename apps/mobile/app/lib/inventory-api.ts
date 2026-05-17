import { teacherProfile } from "./demo-data";

export const MAX_SCAN_ANALYZE_IMAGES = 3;
export const MAX_SCAN_IMAGE_BASE64_LENGTH = 5_000_000;
export const SUPPORTED_SCAN_IMAGE_TYPES = [
  "image/jpeg",
  "image/png",
  "image/webp",
] as const;

export type SupportedScanImageType = (typeof SUPPORTED_SCAN_IMAGE_TYPES)[number];

export type SelectedScanImage = {
  id: string;
  name: string;
  mimeType: SupportedScanImageType;
  dataBase64: string;
  size: number;
};

export type DetectedScanItem = {
  rawLabel: string;
  canonicalName: string | null;
  displayName: string;
  quantityEstimate: number | null;
  unit: string | null;
  confidence: number | null;
  evidence: string[];
  safetyFlags: string[];
  removed?: boolean;
};

export type InventoryScanResponse = {
  id: string;
  status: "CREATED" | "UPLOADED" | "ANALYZING" | "NEEDS_CONFIRMATION" | "CONFIRMED" | "FAILED";
  subject?: string;
  gradeBand?: string;
  classLabel?: string;
  topic?: string;
  errorCode?: string;
  errorMessage?: string;
  detectedItems: DetectedScanItem[];
};

export type ExperimentMatchedMaterial = {
  canonicalName: string;
  displayName: string;
  quantityEstimate: number | null;
  unit: string | null;
};

export type ExperimentMatchResponse = {
  templateId: string;
  title: string;
  summary: string;
  score: number;
  matchedMaterials: ExperimentMatchedMaterial[];
  missingMaterials: string[];
  safetyCategory: "LOW" | "MEDIUM" | "HIGH" | "BLOCKED";
  safetyNotes: string[];
  estimatedMinutes: number;
};

export type UnmatchedConfirmedItem = {
  id: string;
  canonicalName: string | null;
  displayName: string;
};

export type MatchExperimentsResponse = {
  scanId: string;
  confirmedItemCount: number;
  matches: ExperimentMatchResponse[];
  noMatches: boolean;
  unmatchedConfirmedItems: UnmatchedConfirmedItem[];
  blockedSuggestionCount: number;
};

export class InventoryApiError extends Error {
  constructor(
    message: string,
    readonly code = "inventory_request_failed",
  ) {
    super(message);
    this.name = "InventoryApiError";
  }
}

const fallbackApiBaseUrl = "http://127.0.0.1:4000";

export function getInventoryApiBaseUrl(): string {
  return (
    process.env.NEXT_PUBLIC_MCG_API_BASE_URL?.trim() ||
    process.env.NEXT_PUBLIC_API_BASE_URL?.trim() ||
    fallbackApiBaseUrl
  ).replace(/\/+$/, "");
}

export async function fileToScanImage(file: File): Promise<SelectedScanImage> {
  const mimeType = normalizeMimeType(file.type);
  if (!mimeType) {
    throw new InventoryApiError(
      "Only JPEG, PNG, or WebP classroom photos can be analyzed.",
      "scan_image_mime_type_unsupported",
    );
  }

  const dataBase64 = await readFileBase64(file);
  if (dataBase64.length > MAX_SCAN_IMAGE_BASE64_LENGTH) {
    throw new InventoryApiError(
      "Selected image is too large. Choose a smaller photo.",
      "scan_image_too_large",
    );
  }

  return {
    id: `${file.name}-${file.size}-${file.lastModified}`,
    name: file.name,
    mimeType,
    dataBase64,
    size: file.size,
  };
}

export async function createInventoryScan(): Promise<InventoryScanResponse> {
  return requestInventory<InventoryScanResponse>("/inventory/scans", {
    body: JSON.stringify({
      classLabel: teacherProfile.className,
      gradeBand: teacherProfile.gradeLevel,
      subject: teacherProfile.subject,
      topic: teacherProfile.currentTopic,
    }),
    method: "POST",
  });
}

export async function analyzeInventoryScan(
  scanId: string,
  images: SelectedScanImage[],
): Promise<InventoryScanResponse> {
  if (images.length === 0) {
    throw new InventoryApiError(
      "Select at least one classroom photo before analysis.",
      "scan_images_required",
    );
  }
  if (images.length > MAX_SCAN_ANALYZE_IMAGES) {
    throw new InventoryApiError(
      `At most ${MAX_SCAN_ANALYZE_IMAGES} scan images are allowed.`,
      "scan_images_too_many",
    );
  }

  return requestInventory<InventoryScanResponse>(
    `/inventory/scans/${encodeURIComponent(scanId)}/analyze`,
    {
      body: JSON.stringify({
        images: images.map((image) => ({
          dataBase64: image.dataBase64,
          mimeType: image.mimeType,
        })),
      }),
      method: "POST",
    },
  );
}

export async function confirmInventoryScan(
  scanId: string,
): Promise<InventoryScanResponse> {
  return requestInventory<InventoryScanResponse>(
    `/inventory/scans/${encodeURIComponent(scanId)}/confirm`,
    {
      method: "POST",
    },
  );
}

export async function matchExperiments(
  scanId: string,
  maxSuggestions = 3,
): Promise<MatchExperimentsResponse> {
  return requestInventory<MatchExperimentsResponse>("/experiments/match", {
    body: JSON.stringify({
      maxSuggestions,
      scanId,
    }),
    method: "POST",
  });
}

export function formatFileSize(bytes: number): string {
  if (bytes < 1024 * 1024) return `${Math.max(1, Math.round(bytes / 1024))} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}

function normalizeMimeType(type: string): SupportedScanImageType | null {
  if (type === "image/jpg") return "image/jpeg";
  return SUPPORTED_SCAN_IMAGE_TYPES.includes(type as SupportedScanImageType)
    ? (type as SupportedScanImageType)
    : null;
}

function readFileBase64(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.addEventListener("error", () => {
      reject(
        new InventoryApiError(
          "Could not read the selected classroom photo.",
          "scan_image_read_failed",
        ),
      );
    });
    reader.addEventListener("load", () => {
      if (typeof reader.result !== "string") {
        reject(
          new InventoryApiError(
            "Selected image data is unavailable. Choose the photo again.",
            "scan_image_data_unavailable",
          ),
        );
        return;
      }

      const [, base64 = ""] = reader.result.split(",");
      if (!base64) {
        reject(
          new InventoryApiError(
            "Selected image data is unavailable. Choose the photo again.",
            "scan_image_data_unavailable",
          ),
        );
        return;
      }
      resolve(base64);
    });
    reader.readAsDataURL(file);
  });
}

async function requestInventory<T>(
  path: string,
  init: RequestInit,
): Promise<T> {
  const response = await fetch(`${getInventoryApiBaseUrl()}${path}`, {
    ...init,
    headers: {
      "content-type": "application/json",
      ...init.headers,
    },
  });

  if (!response.ok) {
    throw await errorFromResponse(response);
  }

  return (await response.json()) as T;
}

async function errorFromResponse(response: Response): Promise<InventoryApiError> {
  try {
    const payload = (await response.json()) as {
      code?: unknown;
      message?: unknown;
    };
    const code =
      typeof payload.code === "string"
        ? payload.code
        : `http_${response.status}`;
    const message =
      typeof payload.message === "string"
        ? payload.message
        : "Inventory request failed.";
    return new InventoryApiError(message, code);
  } catch {
    return new InventoryApiError(
      "Inventory request failed. Check the API server and try again.",
      `http_${response.status}`,
    );
  }
}
