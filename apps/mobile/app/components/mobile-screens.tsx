"use client";

import type { ChangeEvent, JSX, ReactNode } from "react";
import { useRef, useState } from "react";
import Image from "next/image";

import {
  inventoryItems,
  metrics,
  navItems,
  safetyCheckpoints,
  teacherProfile,
} from "../lib/demo-data";
import {
  InventoryApiError,
  analyzeInventoryScan,
  confirmInventoryScan,
  createInventoryScan,
  fileToScanImage,
  formatFileSize,
  getInventoryApiBaseUrl,
  matchExperiments,
  MAX_SCAN_ANALYZE_IMAGES,
  type DetectedScanItem,
  type ExperimentMatchResponse,
  type InventoryScanResponse,
  type MatchExperimentsResponse,
  type SelectedScanImage,
} from "../lib/inventory-api";
import {
  buildLessonDraft,
  type GeneratedLessonDraft,
  type SavedLessonDraft,
} from "../lib/lesson-flow";
import {
  Badge,
  Card,
  MaterialRow,
  MetricGrid,
  PillButton,
  ProgressRail,
  SafetyCallout,
  SectionHeader,
  cn,
} from "./ui";

type TabKey = (typeof navItems)[number]["key"];

const baseWorkflowSteps = [
  {
    label: "Capture classroom items",
    description: "Teacher takes three quick photos of available supplies.",
  },
  {
    label: "Review detected materials",
    description: "Low-confidence and safety-check items stay teacher-owned.",
  },
  {
    label: "Match safe experiments",
    description: "Only templates that fit the confirmed inventory are shown.",
  },
  {
    label: "Generate lesson plan",
    description: "The selected match becomes an editable 45-minute plan.",
  },
  {
    label: "Save lesson",
    description: "Teacher keeps the generated draft in the local library.",
  },
];

const photoSlots = ["Photo 1", "Photo 2", "Photo 3"];

type ScanPhase =
  | "idle"
  | "reading"
  | "ready"
  | "creating"
  | "analyzing"
  | "done"
  | "confirming"
  | "matching"
  | "generating-lesson";

type MobileScreenProps = {
  activeTab: TabKey;
  latestLessonDraft: GeneratedLessonDraft | null;
  latestMatchResult: MatchExperimentsResponse | null;
  onLessonDraftCreated: (lesson: GeneratedLessonDraft | null) => void;
  onLessonSaved: (lesson: GeneratedLessonDraft) => void;
  onMatchResult: (result: MatchExperimentsResponse | null) => void;
  onTabChange: (tab: TabKey) => void;
  savedLessons: SavedLessonDraft[];
};

export function MobileScreen(props: MobileScreenProps): JSX.Element {
  switch (props.activeTab) {
    case "scan":
      return (
        <ScanScreen
          latestLessonDraft={props.latestLessonDraft}
          latestMatchResult={props.latestMatchResult}
          onLessonDraftCreated={props.onLessonDraftCreated}
          onLessonSaved={props.onLessonSaved}
          onMatchResult={props.onMatchResult}
          onTabChange={props.onTabChange}
        />
      );
    case "lessons":
      return (
        <LessonsScreen
          latestLessonDraft={props.latestLessonDraft}
          latestMatchResult={props.latestMatchResult}
          onLessonDraftCreated={props.onLessonDraftCreated}
          onLessonSaved={props.onLessonSaved}
          onTabChange={props.onTabChange}
          savedLessons={props.savedLessons}
        />
      );
    case "library":
      return (
        <LibraryScreen
          latestLessonDraft={props.latestLessonDraft}
          onLessonSaved={props.onLessonSaved}
          onTabChange={props.onTabChange}
          savedLessons={props.savedLessons}
        />
      );
    case "account":
      return <AccountScreen />;
    case "home":
    default:
      return (
        <HomeScreen
          latestLessonDraft={props.latestLessonDraft}
          latestMatchResult={props.latestMatchResult}
          onTabChange={props.onTabChange}
          savedLessons={props.savedLessons}
        />
      );
  }
}

export function HomeScreen(props: {
  latestLessonDraft: GeneratedLessonDraft | null;
  latestMatchResult: MatchExperimentsResponse | null;
  onTabChange: (tab: TabKey) => void;
  savedLessons: SavedLessonDraft[];
}): JSX.Element {
  const matchedLessonCount = props.latestMatchResult?.matches.length ?? 0;
  const confirmedItemCount = props.latestMatchResult?.confirmedItemCount ?? 0;
  const savedLessonCount = props.savedLessons.length;
  const activeDraft = props.latestLessonDraft ?? null;
  const flowSteps = buildHomeWorkflowSteps({
    hasDraft: !!activeDraft,
    hasMatch: !!props.latestMatchResult,
    hasSavedLesson: savedLessonCount > 0,
  });

  return (
    <div className="space-y-4 p-4">
      <SectionHeader
        description="Photo-to-lesson demo path"
        eyebrow="Today"
        title={`Ready for ${teacherProfile.className}`}
      />

      <div className="flex flex-wrap gap-2">
        <Badge tone="blue">API backend/mock backend</Badge>
        <Badge tone="green">Teacher MVP</Badge>
        <Badge tone="amber">Safety checks</Badge>
      </div>

      <Card className="space-y-4">
        <div className="space-y-2">
          <p className="text-sm font-semibold uppercase tracking-normal text-slate-500">
            Current topic
          </p>
          <h2 className="text-2xl font-semibold leading-tight text-slate-950">
            {teacherProfile.currentTopic}
          </h2>
          <p className="text-sm leading-5 text-slate-600">
            Turn a confirmed classroom inventory into a safe, editable lesson
            for {teacherProfile.gradeLevel} {teacherProfile.subject}.
          </p>
        </div>

        <PillButton
          className="w-full"
          onClick={() => props.onTabChange("scan")}
          variant="primary"
        >
          Scan classroom items
        </PillButton>
      </Card>

      <MetricGrid
        metrics={[
          {
            detail: props.latestMatchResult
              ? "Confirmed in current scan"
              : "No current scan",
            label: "Materials",
            tone: props.latestMatchResult ? "green" : "neutral",
            value: String(confirmedItemCount),
          },
          {
            detail: props.latestMatchResult
              ? "Ready for lesson creation"
              : "Scan first",
            label: "Matches",
            tone: matchedLessonCount > 0 ? "blue" : "neutral",
            value: String(matchedLessonCount),
          },
          {
            detail: activeDraft
              ? activeDraft.title
              : savedLessonCount > 0
                ? "Saved in library"
                : metrics[2]?.helper,
            label: "Lessons",
            tone: savedLessonCount > 0 ? "green" : activeDraft ? "amber" : "neutral",
            value: String(savedLessonCount || (activeDraft ? 1 : 0)),
          },
        ]}
      />

      {props.latestMatchResult || activeDraft || savedLessonCount > 0 ? (
        <Card className="space-y-3">
          <SectionHeader
            action={
              savedLessonCount > 0 ? (
                <Badge tone="green">Saved</Badge>
              ) : activeDraft ? (
                <Badge tone="amber">Draft</Badge>
              ) : (
                <Badge tone="blue">Matched</Badge>
              )
            }
            description={
              activeDraft
                ? activeDraft.title
                : props.latestMatchResult?.noMatches
                  ? "No safe match yet. Add more materials and scan again."
                  : "Confirmed materials are ready for lesson generation."
            }
            title="Current flow"
          />
          <div className="grid grid-cols-2 gap-2">
            <PillButton
              onClick={() => props.onTabChange("lessons")}
              variant="secondary"
            >
              Review matches
            </PillButton>
            <PillButton
              onClick={() => props.onTabChange("library")}
              variant="secondary"
            >
              Open library
            </PillButton>
          </div>
        </Card>
      ) : null}

      <Card>
        <SectionHeader
          className="mb-4"
          description="A teacher-controlled path from photos to a lesson."
          title="Workflow"
        />
        <ProgressRail steps={flowSteps} />
      </Card>
    </div>
  );
}

function buildHomeWorkflowSteps(flags: {
  hasDraft: boolean;
  hasMatch: boolean;
  hasSavedLesson: boolean;
}) {
  if (flags.hasSavedLesson) {
    return baseWorkflowSteps.map((step) => ({
      ...step,
      status: "complete" as const,
    }));
  }

  const completedThrough = flags.hasDraft ? 3 : flags.hasMatch ? 2 : -1;
  const currentIndex = flags.hasDraft ? 4 : flags.hasMatch ? 3 : 0;

  return baseWorkflowSteps.map((step, index) => ({
    ...step,
    status:
      index <= completedThrough
        ? ("complete" as const)
        : index === currentIndex
          ? ("current" as const)
          : ("pending" as const),
  }));
}

export function ScanScreen(props: {
  latestLessonDraft: GeneratedLessonDraft | null;
  latestMatchResult: MatchExperimentsResponse | null;
  onLessonDraftCreated: (lesson: GeneratedLessonDraft | null) => void;
  onLessonSaved: (lesson: GeneratedLessonDraft) => void;
  onMatchResult: (result: MatchExperimentsResponse | null) => void;
  onTabChange: (tab: TabKey) => void;
}): JSX.Element {
  const cameraInputRef = useRef<HTMLInputElement>(null);
  const galleryInputRef = useRef<HTMLInputElement>(null);
  const [selectedImages, setSelectedImages] = useState<SelectedScanImage[]>([]);
  const [scanId, setScanId] = useState<string | null>(null);
  const [analyzedScan, setAnalyzedScan] =
    useState<InventoryScanResponse | null>(null);
  const [confirmedScan, setConfirmedScan] =
    useState<InventoryScanResponse | null>(null);
  const [matchResult, setMatchResult] =
    useState<MatchExperimentsResponse | null>(null);
  const [selectedMatchId, setSelectedMatchId] = useState<string | null>(null);
  const [generatedLesson, setGeneratedLesson] =
    useState<GeneratedLessonDraft | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [phase, setPhase] = useState<ScanPhase>("idle");

  const detectedItems = analyzedScan?.detectedItems ?? [];
  const isBusy =
    phase === "reading" ||
    phase === "creating" ||
    phase === "analyzing" ||
    phase === "confirming" ||
    phase === "matching" ||
    phase === "generating-lesson";
  const canAddMore = selectedImages.length < MAX_SCAN_ANALYZE_IMAGES && !isBusy;
  const canAnalyze = selectedImages.length > 0 && !isBusy;
  const canMatch =
    !!scanId &&
    !!analyzedScan &&
    detectedItems.length > 0 &&
    !matchResult &&
    (analyzedScan.status === "NEEDS_CONFIRMATION" ||
      confirmedScan?.status === "CONFIRMED") &&
    !isBusy;

  function resetScanResults() {
    setScanId(null);
    setAnalyzedScan(null);
    setConfirmedScan(null);
    setMatchResult(null);
    setSelectedMatchId(null);
    setGeneratedLesson(null);
    props.onMatchResult(null);
    props.onLessonDraftCreated(null);
  }

  async function handleFileInput(event: ChangeEvent<HTMLInputElement>) {
    const files = Array.from(event.target.files ?? []);
    event.target.value = "";
    if (files.length === 0) return;

    setPhase("reading");
    setError(null);
    setNotice(null);

    try {
      const availableSlots = MAX_SCAN_ANALYZE_IMAGES - selectedImages.length;
      if (availableSlots <= 0) {
        setNotice(`Only ${MAX_SCAN_ANALYZE_IMAGES} photos can be analyzed at once.`);
        setPhase(selectedImages.length > 0 ? "ready" : "idle");
        return;
      }

      const acceptedFiles = files.slice(0, availableSlots);
      const nextImages = await Promise.all(acceptedFiles.map(fileToScanImage));
      setSelectedImages((current) => [...current, ...nextImages]);
      resetScanResults();
      setPhase("ready");
      if (files.length > acceptedFiles.length) {
        setNotice(`Only ${MAX_SCAN_ANALYZE_IMAGES} photos can be analyzed at once.`);
      }
    } catch (caught) {
      setPhase(selectedImages.length > 0 ? "ready" : "idle");
      setError(messageForError(caught));
    }
  }

  function removeImage(imageId: string) {
    const nextImages = selectedImages.filter((image) => image.id !== imageId);
    setSelectedImages(nextImages);
    resetScanResults();
    setNotice(null);
    setPhase(nextImages.length === 0 ? "idle" : "ready");
  }

  async function analyzeSelectedImages() {
    if (!canAnalyze) return;

    setPhase("creating");
    setError(null);
    setNotice("Creating inventory scan...");

    try {
      const scan = scanId ? null : await createInventoryScan();
      const nextScanId = scan?.id ?? scanId;
      if (!nextScanId) {
        throw new InventoryApiError(
          "Could not start an inventory scan.",
          "scan_create_failed",
        );
      }

      setScanId(nextScanId);
      setConfirmedScan(null);
      setMatchResult(null);
      setSelectedMatchId(null);
      setGeneratedLesson(null);
      props.onMatchResult(null);
      props.onLessonDraftCreated(null);
      setPhase("analyzing");
      setNotice("Sending photos to AI for inventory analysis...");

      const analyzed = await analyzeInventoryScan(nextScanId, selectedImages);
      setAnalyzedScan(analyzed);
      setPhase("done");
      setNotice(
        analyzed.errorMessage ??
          `AI returned ${analyzed.detectedItems.length} detected material${analyzed.detectedItems.length === 1 ? "" : "s"}.`,
      );
      if (analyzed.status === "FAILED") {
        setError(analyzed.errorMessage ?? "Could not analyze the inventory photo.");
      }
    } catch (caught) {
      setPhase(selectedImages.length > 0 ? "ready" : "idle");
      setNotice(null);
      setError(messageForError(caught));
    }
  }

  async function confirmInventoryAndMatchLessons() {
    const activeScanId = confirmedScan?.id ?? scanId;
    if (!activeScanId || (!confirmedScan && !analyzedScan)) return;

    setError(null);
    setGeneratedLesson(null);

    try {
      let nextConfirmedScan = confirmedScan;
      if (!nextConfirmedScan) {
        setPhase("confirming");
        setNotice("Confirming inventory for lesson matching...");
        nextConfirmedScan = await confirmInventoryScan(activeScanId);
        setConfirmedScan(nextConfirmedScan);
        setAnalyzedScan(nextConfirmedScan);
      }

      setPhase("matching");
      setNotice("Matching confirmed materials with safe lesson templates...");
      const matches = await matchExperiments(activeScanId, 3);
      setMatchResult(matches);
      props.onMatchResult(matches);
      props.onLessonDraftCreated(null);
      setSelectedMatchId(null);
      setPhase("done");
      setNotice(
        matches.noMatches
          ? `Confirmed ${matches.confirmedItemCount} material${matches.confirmedItemCount === 1 ? "" : "s"}, but no suitable lesson match was found.`
          : `Found ${matches.matches.length} lesson match${matches.matches.length === 1 ? "" : "es"} from ${matches.confirmedItemCount} confirmed material${matches.confirmedItemCount === 1 ? "" : "s"}.`,
      );
    } catch (caught) {
      setPhase(selectedImages.length > 0 ? "done" : "idle");
      setNotice(null);
      setError(messageForError(caught));
    }
  }

  function createLessonFromMatch(match: ExperimentMatchResponse) {
    setPhase("generating-lesson");
    setError(null);
    setSelectedMatchId(match.templateId);

    const lesson = buildLessonDraft(match);
    setGeneratedLesson(lesson);
    props.onLessonDraftCreated(lesson);
    setPhase("done");
    setNotice(`Lesson draft created from ${match.title}.`);
  }

  return (
    <div className="space-y-4 p-4">
      <SectionHeader
        description="Capture and upload photos before confirming inventory."
        title="Classroom scan"
      />

      <div className="grid grid-cols-3 gap-2">
        {photoSlots.map((slot, index) => {
          const image = selectedImages[index];

          return (
            <div
              className={cn(
                "relative flex aspect-[3/4] min-w-0 flex-col items-center justify-center overflow-hidden rounded-lg border border-dashed bg-white p-2 text-center",
                image
                  ? "border-blue-300 text-blue-800"
                  : "border-slate-300 text-slate-500",
              )}
              key={slot}
            >
              {image ? (
                <>
                  <Image
                    alt={`${image.name} preview`}
                    className="object-cover"
                    fill
                    sizes="120px"
                    src={`data:${image.mimeType};base64,${image.dataBase64}`}
                    unoptimized
                  />
                  <button
                    aria-label={`Remove ${image.name}`}
                    className="absolute right-1 top-1 rounded-full bg-white/95 px-2 py-1 text-[11px] font-bold text-slate-800 shadow-sm"
                    onClick={() => removeImage(image.id)}
                    type="button"
                  >
                    Remove
                  </button>
                  <span className="absolute inset-x-1 bottom-1 rounded-md bg-white/95 px-1 py-1 text-[10px] font-semibold leading-3 text-slate-800">
                    {image.name}
                  </span>
                </>
              ) : (
                <>
                  <span className="text-xs font-semibold">{slot}</span>
                  <span className="mt-1 text-[11px] leading-4">Add image</span>
                </>
              )}
            </div>
          );
        })}
      </div>

      <input
        accept="image/jpeg,image/png,image/webp"
        capture="environment"
        className="sr-only"
        onChange={handleFileInput}
        ref={cameraInputRef}
        type="file"
      />
      <input
        accept="image/jpeg,image/png,image/webp"
        className="sr-only"
        multiple
        onChange={handleFileInput}
        ref={galleryInputRef}
        type="file"
      />

      <div className="grid grid-cols-2 gap-2">
        <PillButton
          disabled={!canAddMore}
          onClick={() => cameraInputRef.current?.click()}
        >
          Capture photo
        </PillButton>
        <PillButton
          disabled={!canAddMore}
          onClick={() => galleryInputRef.current?.click()}
        >
          Upload photos
        </PillButton>
      </div>

      <Card className="space-y-2">
        <div className="flex items-start justify-between gap-3">
          <div className="min-w-0">
            <p className="text-sm font-semibold text-slate-950">
              AI endpoint
            </p>
            <p className="break-all text-xs leading-4 text-slate-600">
              {getInventoryApiBaseUrl()}/inventory/scans/:id/analyze
            </p>
          </div>
          <Badge tone={phase === "done" ? "green" : isBusy ? "blue" : "neutral"}>
            {phaseLabel(phase)}
          </Badge>
        </div>
        {selectedImages.length > 0 ? (
          <div className="flex flex-wrap gap-2">
            {selectedImages.map((image) => (
              <Badge key={image.id} tone="blue">
                {image.name} ({formatFileSize(image.size)})
              </Badge>
            ))}
          </div>
        ) : (
          <p className="text-sm leading-5 text-slate-600">
            Select up to {MAX_SCAN_ANALYZE_IMAGES} classroom photos, then send
            them to the API for AI material detection.
          </p>
        )}
      </Card>

      {notice ? (
        <SafetyCallout title="Status" tone={phase === "done" ? "green" : "blue"}>
          {notice}
        </SafetyCallout>
      ) : null}

      {error ? (
        <SafetyCallout title="Flow stopped" tone="red">
          {error}
        </SafetyCallout>
      ) : null}

      <Card>
        <SectionHeader
          className="mb-2"
          description="Confidence and evidence remain visible for teacher review."
          title="Detected materials"
        />
        {detectedItems.length > 0 ? (
          detectedItems.map((item, index) => (
            <MaterialRow
              confidence={item.confidence ?? undefined}
              evidence={item.evidence.join(" ") || item.rawLabel}
              key={`${item.rawLabel}-${index}`}
              name={item.displayName}
              status={statusForDetectedItem(item)}
              statusTone={item.safetyFlags.length > 0 ? "amber" : "blue"}
            />
          ))
        ) : (
          <div className="rounded-lg bg-slate-50 p-4 text-sm leading-5 text-slate-600">
            AI results will appear here after analysis. Until then, no
            detected material is trusted for matching.
          </div>
        )}
      </Card>

      <SafetyCallout
        items={
          detectedItems.length > 0
            ? detectedItems
                .filter((item) => item.safetyFlags.length > 0)
                .flatMap((item) => item.safetyFlags)
            : inventoryItems
                .filter((item) => item.safety.status !== "cleared")
                .map((item) => item.safety.requiredAction ?? item.safety.note)
        }
        title="Teacher confirmation required"
      >
        Confirm quantities, confidence, and safety actions before matching.
      </SafetyCallout>

      {!analyzedScan || analyzedScan.status === "FAILED" ? (
        <PillButton
          className="w-full"
          disabled={!canAnalyze}
          onClick={analyzeSelectedImages}
          variant="primary"
        >
          {phase === "analyzing" || phase === "creating"
            ? "Sending photos to AI..."
            : "Analyze inventory with AI"}
        </PillButton>
      ) : (
        <PillButton
          className="w-full"
          disabled={!canMatch}
          onClick={confirmInventoryAndMatchLessons}
          variant="primary"
        >
          {phase === "confirming"
            ? "Confirming inventory..."
            : phase === "matching"
              ? "Matching lessons..."
              : matchResult
                ? "Lesson matches ready"
                : "Confirm inventory and match lessons"}
        </PillButton>
      )}

      {matchResult ? (
        <section className="space-y-3">
          <SectionHeader
            description={`${matchResult.confirmedItemCount} confirmed material${matchResult.confirmedItemCount === 1 ? "" : "s"} matched against safe experiment templates.`}
            title="Lesson matches"
          />

          {matchResult.noMatches ? (
            <SafetyCallout title="No suitable match" tone="amber">
              Add more classroom materials or adjust the confirmed inventory,
              then run matching again.
            </SafetyCallout>
          ) : (
            matchResult.matches.map((match) => (
              <Card className="space-y-3" key={match.templateId}>
                <div className="flex items-start justify-between gap-3">
                  <div className="min-w-0 space-y-1">
                    <p className="text-sm font-semibold text-slate-950">
                      {match.title}
                    </p>
                    <p className="line-clamp-3 text-sm leading-5 text-slate-600">
                      {match.summary}
                    </p>
                  </div>
                  <div className="flex shrink-0 flex-col items-end gap-1">
                    <Badge tone={toneForMatch(match)}>
                      {scoreLabel(match.score)}
                    </Badge>
                    <Badge tone="neutral">{match.estimatedMinutes}m</Badge>
                  </div>
                </div>

                <div className="space-y-2">
                  <p className="text-xs font-semibold uppercase tracking-normal text-slate-500">
                    Matched materials
                  </p>
                  <div className="flex flex-wrap gap-2">
                    {match.matchedMaterials.map((material) => (
                      <Badge
                        key={`${match.templateId}-${material.canonicalName}`}
                        tone="green"
                      >
                        {material.displayName}
                      </Badge>
                    ))}
                  </div>
                </div>

                {match.missingMaterials.length > 0 ? (
                  <div className="space-y-2">
                    <p className="text-xs font-semibold uppercase tracking-normal text-slate-500">
                      Optional gaps
                    </p>
                    <div className="flex flex-wrap gap-2">
                      {match.missingMaterials.map((material) => (
                        <Badge key={`${match.templateId}-${material}`} tone="amber">
                          {material}
                        </Badge>
                      ))}
                    </div>
                  </div>
                ) : null}

                <SafetyCallout
                  className="p-3"
                  items={match.safetyNotes}
                  title="Safety notes"
                  tone={toneForMatch(match)}
                />

                <PillButton
                  active={selectedMatchId === match.templateId}
                  aria-pressed={selectedMatchId === match.templateId}
                  className="w-full"
                  disabled={isBusy}
                  onClick={() => createLessonFromMatch(match)}
                  variant={
                    selectedMatchId === match.templateId ? "primary" : "secondary"
                  }
                >
                  {phase === "generating-lesson" &&
                  selectedMatchId === match.templateId
                    ? "Creating lesson..."
                    : "Create lesson"}
                </PillButton>
              </Card>
            ))
          )}

          {matchResult.blockedSuggestionCount > 0 ||
          matchResult.unmatchedConfirmedItems.length > 0 ? (
            <SafetyCallout
              items={[
                ...(matchResult.blockedSuggestionCount > 0
                  ? [
                      `${matchResult.blockedSuggestionCount} unsafe suggestion${matchResult.blockedSuggestionCount === 1 ? "" : "s"} hidden.`,
                    ]
                  : []),
                ...matchResult.unmatchedConfirmedItems.map(
                  (item) => `${item.displayName} was confirmed but not used.`,
                ),
              ]}
              title="Matching notes"
              tone="blue"
            />
          ) : null}
        </section>
      ) : null}

      {generatedLesson ? (
        <Card className="space-y-4">
          <SectionHeader
            action={<Badge tone="green">Draft</Badge>}
            description={`${generatedLesson.durationMinutes} minutes from selected material match`}
            title={generatedLesson.title}
          />

          <LessonDraftSection
            items={generatedLesson.objectives}
            title="Objectives"
          />
          <LessonDraftSection
            items={generatedLesson.materials}
            title="Materials"
          />
          <LessonDraftSection items={generatedLesson.flow} title="Flow" />
          <LessonDraftSection
            items={generatedLesson.questions}
            title="Questions"
          />
          <LessonDraftSection
            items={generatedLesson.safetyNotes}
            title="Safety notes"
          />
          <div className="grid grid-cols-2 gap-2">
            <PillButton
              onClick={() => props.onLessonSaved(generatedLesson)}
              variant="primary"
            >
              Save lesson
            </PillButton>
            <PillButton
              onClick={() => props.onTabChange("lessons")}
              variant="secondary"
            >
              Review match
            </PillButton>
          </div>
        </Card>
      ) : null}
    </div>
  );
}

function statusForDetectedItem(item: DetectedScanItem): string | undefined {
  if (item.safetyFlags.length > 0) return "Safety flag";
  if (typeof item.confidence === "number" && item.confidence < 0.8) {
    return "Low confidence";
  }
  return undefined;
}

function phaseLabel(phase: ScanPhase): string {
  switch (phase) {
    case "reading":
      return "Reading";
    case "creating":
      return "Creating";
    case "analyzing":
      return "Analyzing";
    case "confirming":
      return "Confirming";
    case "matching":
      return "Matching";
    case "generating-lesson":
      return "Generating";
    case "done":
      return "Done";
    case "ready":
    case "idle":
    default:
      return "Ready";
  }
}

function scoreLabel(score: number): string {
  if (score <= 1) return `${Math.round(score * 100)}%`;
  if (score <= 5) return `${score.toFixed(score % 1 === 0 ? 0 : 1)} fit`;
  return `${Math.round(score)}%`;
}

function toneForMatch(match: ExperimentMatchResponse): "green" | "blue" | "amber" {
  if (
    match.safetyCategory === "MEDIUM" ||
    match.safetyCategory === "HIGH" ||
    match.missingMaterials.length > 0
  ) {
    return "amber";
  }
  return match.score >= 1.5 ? "green" : "blue";
}

function messageForError(error: unknown): string {
  if (error instanceof InventoryApiError) return error.message;
  if (error instanceof Error) return error.message;
  return "Could not analyze the inventory photo.";
}

function LessonDraftSection(props: {
  items: string[];
  title: string;
}): JSX.Element {
  return (
    <section className="rounded-lg border border-slate-200 bg-slate-50 p-3">
      <h3 className="text-sm font-semibold text-slate-950">{props.title}</h3>
      <ul className="mt-2 space-y-2">
        {props.items.map((item) => (
          <li className="flex gap-2 text-sm leading-5 text-slate-600" key={item}>
            <span
              aria-hidden="true"
              className="mt-2 size-1.5 shrink-0 rounded-full bg-blue-700"
            />
            <span className="min-w-0">{item}</span>
          </li>
        ))}
      </ul>
    </section>
  );
}

function LessonDraftCard(props: {
  action?: ReactNode;
  description?: ReactNode;
  footer?: ReactNode;
  lesson: GeneratedLessonDraft;
}): JSX.Element {
  return (
    <Card className="space-y-4">
      <SectionHeader
        action={props.action}
        description={
          props.description ??
          `${props.lesson.durationMinutes} minutes from selected material match`
        }
        title={props.lesson.title}
      />
      <LessonDraftSection items={props.lesson.objectives} title="Objectives" />
      <LessonDraftSection items={props.lesson.materials} title="Materials" />
      <LessonDraftSection items={props.lesson.flow} title="Flow" />
      <LessonDraftSection items={props.lesson.questions} title="Questions" />
      <LessonDraftSection items={props.lesson.safetyNotes} title="Safety notes" />
      {props.footer ? <div>{props.footer}</div> : null}
    </Card>
  );
}

function formatSavedAt(value: string): string {
  const savedAt = new Date(value);
  if (Number.isNaN(savedAt.getTime())) return "recently";
  return savedAt.toLocaleDateString("en-US", {
    day: "numeric",
    month: "short",
  });
}

export function LessonsScreen(props: {
  latestLessonDraft: GeneratedLessonDraft | null;
  latestMatchResult: MatchExperimentsResponse | null;
  onLessonDraftCreated: (lesson: GeneratedLessonDraft | null) => void;
  onLessonSaved: (lesson: GeneratedLessonDraft) => void;
  onTabChange: (tab: TabKey) => void;
  savedLessons: SavedLessonDraft[];
}): JSX.Element {
  const matchResult = props.latestMatchResult;
  const matches = matchResult?.matches ?? [];
  const latestLessonDraft = props.latestLessonDraft;
  const draftIsSaved = props.savedLessons.some(
    (lesson) => lesson.id === latestLessonDraft?.id,
  );

  function createLessonFromMatch(match: ExperimentMatchResponse) {
    props.onLessonDraftCreated(buildLessonDraft(match));
  }

  return (
    <div className="space-y-4 p-4">
      <SectionHeader
        description={
          matchResult
            ? `${matchResult.confirmedItemCount} confirmed material${matchResult.confirmedItemCount === 1 ? "" : "s"} matched against safe experiment templates.`
            : "Scan and confirm classroom materials before choosing a lesson."
        }
        title="Experiment matches"
      />

      <div className="flex flex-wrap gap-2">
        <PillButton active aria-pressed="true">
          Safe-only
        </PillButton>
        <Badge tone="blue">{teacherProfile.gradeLevel}</Badge>
        <Badge tone="neutral">{teacherProfile.lessonDurationMinutes}m</Badge>
      </div>

      {!matchResult ? (
        <Card className="space-y-3">
          <SectionHeader
            action={<Badge tone="neutral">Empty</Badge>}
            description="No confirmed scan is available in this session yet."
            title="Start with inventory"
          />
          <PillButton
            className="w-full"
            onClick={() => props.onTabChange("scan")}
            variant="primary"
          >
            Scan classroom items
          </PillButton>
        </Card>
      ) : matchResult.noMatches ? (
        <SafetyCallout title="No suitable match" tone="amber">
          Confirmed materials did not match a safe lesson template. Add more
          materials or rescan before creating a lesson.
        </SafetyCallout>
      ) : (
        <div className="space-y-3">
          {matches.map((match) => (
            <Card className="space-y-3" key={match.templateId}>
              <div className="flex items-start justify-between gap-3">
                <div className="min-w-0 space-y-1">
                  <p className="text-sm font-semibold text-slate-950">
                    {match.title}
                  </p>
                  <p className="line-clamp-3 text-sm leading-5 text-slate-600">
                    {match.summary}
                  </p>
                </div>
                <div className="flex shrink-0 flex-col items-end gap-1">
                  <Badge tone={toneForMatch(match)}>
                    {scoreLabel(match.score)}
                  </Badge>
                  <Badge tone="neutral">{match.estimatedMinutes}m</Badge>
                </div>
              </div>

              <div className="space-y-2">
                <p className="text-xs font-semibold uppercase tracking-normal text-slate-500">
                  Matched materials
                </p>
                <div className="flex flex-wrap gap-2">
                  {match.matchedMaterials.map((material) => (
                    <Badge
                      key={`${match.templateId}-${material.canonicalName}`}
                      tone="green"
                    >
                      {material.displayName}
                    </Badge>
                  ))}
                </div>
              </div>

              {match.missingMaterials.length > 0 ? (
                <div className="space-y-2">
                  <p className="text-xs font-semibold uppercase tracking-normal text-slate-500">
                    Optional gaps
                  </p>
                  <div className="flex flex-wrap gap-2">
                    {match.missingMaterials.map((material) => (
                      <Badge key={`${match.templateId}-${material}`} tone="amber">
                        {material}
                      </Badge>
                    ))}
                  </div>
                </div>
              ) : null}

              <SafetyCallout
                className="p-3"
                items={match.safetyNotes}
                title="Safety notes"
                tone={toneForMatch(match)}
              />

              <PillButton
                className="w-full"
                onClick={() => createLessonFromMatch(match)}
                variant={
                  latestLessonDraft?.sourceMatchId === match.templateId
                    ? "primary"
                    : "secondary"
                }
              >
                {latestLessonDraft?.sourceMatchId === match.templateId &&
                draftIsSaved
                  ? "Saved lesson"
                  : latestLessonDraft?.sourceMatchId === match.templateId
                  ? "Lesson draft ready"
                  : "Create lesson"}
              </PillButton>
            </Card>
          ))}
        </div>
      )}

      {latestLessonDraft ? (
        <LessonDraftCard
          action={
            draftIsSaved ? (
              <Badge tone="green">Saved</Badge>
            ) : (
              <Badge tone="amber">Draft</Badge>
            )
          }
          footer={
            draftIsSaved ? (
              <PillButton
                className="w-full"
                onClick={() => props.onTabChange("library")}
                variant="primary"
              >
                Open library
              </PillButton>
            ) : (
              <div className="grid grid-cols-2 gap-2">
                <PillButton
                  onClick={() => props.onLessonSaved(latestLessonDraft)}
                  variant="primary"
                >
                  Save lesson
                </PillButton>
                <PillButton
                  onClick={() => props.onTabChange("library")}
                  variant="secondary"
                >
                  Open library
                </PillButton>
              </div>
            )
          }
          lesson={latestLessonDraft}
        />
      ) : null}

      <Card>
        <SectionHeader
          description={`${teacherProfile.subject}, ${teacherProfile.gradeLevel}, ${teacherProfile.lessonDurationMinutes} minutes`}
          title="Lesson generation context"
        />
        <div className="mt-3 flex flex-wrap gap-2">
          <Badge tone="blue">{teacherProfile.currentTopic}</Badge>
          <Badge tone="neutral">{teacherProfile.className}</Badge>
          <Badge tone="green">{inventoryItems.length} materials detected</Badge>
        </div>
      </Card>
    </div>
  );
}

export function LibraryScreen(props: {
  latestLessonDraft: GeneratedLessonDraft | null;
  onLessonSaved: (lesson: GeneratedLessonDraft) => void;
  onTabChange: (tab: TabKey) => void;
  savedLessons: SavedLessonDraft[];
}): JSX.Element {
  const hasSavedLessons = props.savedLessons.length > 0;
  const unsavedDraft =
    props.latestLessonDraft &&
    !props.savedLessons.some((lesson) => lesson.id === props.latestLessonDraft?.id)
      ? props.latestLessonDraft
      : null;

  return (
    <div className="space-y-4 p-4">
      <SectionHeader
        description="Saved generated plans stay editable before export."
        title="Lesson library"
      />

      <div
        aria-label="Search saved lessons"
        className="flex h-11 items-center rounded-full border border-slate-300 bg-white px-4 text-sm text-slate-500"
      >
        Search saved lessons
      </div>

      {!hasSavedLessons && !unsavedDraft ? (
        <Card className="space-y-3">
          <SectionHeader
            action={<Badge tone="neutral">Empty</Badge>}
            description="Create and save a generated lesson before it appears here."
            title="No saved lessons"
          />
          <PillButton
            className="w-full"
            onClick={() => props.onTabChange("scan")}
            variant="primary"
          >
            Scan classroom items
          </PillButton>
        </Card>
      ) : null}

      {unsavedDraft ? (
        <LessonDraftCard
          action={<Badge tone="amber">Unsaved</Badge>}
          description="Generated from the selected material match. Save it to keep it in the library."
          footer={
            <PillButton
              className="w-full"
              onClick={() => props.onLessonSaved(unsavedDraft)}
              variant="primary"
            >
              Save lesson to library
            </PillButton>
          }
          lesson={unsavedDraft}
        />
      ) : null}

      {props.savedLessons.map((lesson) => (
        <LessonDraftCard
          action={
            <Badge tone={lesson.exportSafetyAccepted ? "green" : "amber"}>
              {lesson.exportSafetyAccepted ? "Export ready" : "Export held"}
            </Badge>
          }
          description={`${lesson.durationMinutes} minutes - saved ${formatSavedAt(lesson.savedAt)} - version ${lesson.version}`}
          footer={
            <PillButton className="w-full" variant="secondary">
              Edit generated plan
            </PillButton>
          }
          key={`${lesson.id}-${lesson.version}`}
          lesson={lesson}
        />
      ))}

      <SafetyCallout
        items={safetyCheckpoints
          .filter((checkpoint) => checkpoint.blocksExport)
          .map((checkpoint) => checkpoint.description)}
        title="Export safety confirmation"
        tone={hasSavedLessons ? "amber" : "blue"}
      >
        {hasSavedLessons
          ? "Export remains blocked until the teacher accepts safety notes."
          : "Saved lessons will require safety confirmation before export."}
      </SafetyCallout>
    </div>
  );
}

export function AccountScreen(): JSX.Element {
  return (
    <div className="space-y-4 p-4">
      <SectionHeader
        description="Class context and safety defaults guide generated plans."
        title="Teacher profile"
      />

      <Card>
        <div className="grid grid-cols-2 gap-3">
          <ProfileField label="Name" value={teacherProfile.name} />
          <ProfileField label="Subject" value={teacherProfile.subject} />
          <ProfileField label="Grade" value={teacherProfile.gradeLevel} />
          <ProfileField label="Class" value={teacherProfile.className} />
          <ProfileField
            className="col-span-2"
            label="Current topic"
            value={teacherProfile.currentTopic}
          />
        </div>
      </Card>

      <Card className="space-y-2">
        <SectionHeader
          description={teacherProfile.schoolContext}
          title="School and class context"
        />
        <Badge tone="blue">{teacherProfile.lessonDurationMinutes}m lessons</Badge>
      </Card>

      <Card className="space-y-3">
        <SectionHeader
          description="Password and account controls are represented for the MVP profile flow."
          title="Security"
        />
        <div className="rounded-lg border border-slate-200 bg-slate-50 p-3">
          <p className="text-sm font-semibold text-slate-950">Password</p>
          <p className="mt-1 text-sm text-slate-600">
            Last updated recently - two-step verification optional
          </p>
        </div>
        <PillButton className="w-full">Manage password</PillButton>
      </Card>

      <SafetyCallout
        items={safetyCheckpoints.map((checkpoint) => checkpoint.description)}
        title="Safety defaults"
        tone="blue"
      >
        Classroom photos are used only to detect materials for the active
        teacher session and should not include student faces or personal data.
      </SafetyCallout>
    </div>
  );
}

function ProfileField(props: {
  className?: string;
  label: string;
  value: string;
}): JSX.Element {
  return (
    <div
      className={cn(
        "min-w-0 rounded-lg border border-slate-200 bg-slate-50 p-3",
        props.className,
      )}
    >
      <p className="text-xs font-semibold uppercase tracking-normal text-slate-500">
        {props.label}
      </p>
      <p className="mt-1 truncate text-sm font-semibold text-slate-950">
        {props.value}
      </p>
    </div>
  );
}
