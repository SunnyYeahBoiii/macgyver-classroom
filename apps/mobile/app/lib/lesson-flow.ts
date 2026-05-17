import { lessonPlan } from "./demo-data";
import type { ExperimentMatchResponse } from "./inventory-api";

export type GeneratedLessonDraft = {
  id: string;
  sourceMatchId: string;
  title: string;
  durationMinutes: number;
  materials: string[];
  objectives: string[];
  flow: string[];
  questions: string[];
  safetyNotes: string[];
};

export type SavedLessonDraft = GeneratedLessonDraft & {
  exportSafetyAccepted: boolean;
  savedAt: string;
  version: number;
};

export const demoLessonDraft: GeneratedLessonDraft = {
  durationMinutes: lessonPlan.durationMinutes,
  flow: lessonPlan.flow.map(
    (step) => `${step.time} - ${step.title}: ${step.activity}`,
  ),
  id: lessonPlan.id,
  materials: [...lessonPlan.materials],
  objectives: [...lessonPlan.objectives],
  questions: [...lessonPlan.questions],
  safetyNotes: [...lessonPlan.safetyNotes],
  sourceMatchId: lessonPlan.sourceMatchId,
  title: lessonPlan.title,
};

export function buildLessonDraft(
  match: ExperimentMatchResponse,
): GeneratedLessonDraft {
  const matchedMaterials = match.matchedMaterials.map((material) =>
    material.quantityEstimate && material.unit
      ? `${material.displayName} (${material.quantityEstimate} ${material.unit})`
      : material.displayName,
  );
  const materials = [...matchedMaterials, ...match.missingMaterials];
  const safetyNotes =
    match.safetyNotes.length > 0
      ? match.safetyNotes
      : ["Teacher confirms all matched materials before student use."];

  return {
    durationMinutes: match.estimatedMinutes,
    flow: [
      "Warm-up: connect confirmed classroom materials to the lesson question.",
      "Safety setup: review teacher checks, roles, and safe handling rules.",
      "Activity: build or test the matched experiment in small groups.",
      "Evidence check: record observations and compare results.",
      "Reflection: explain how the evidence connects to the target concept.",
    ],
    id: `lesson-${match.templateId}`,
    materials,
    objectives: [
      `Explain the science idea behind ${match.title}.`,
      "Use confirmed classroom materials to run a safe investigation.",
      "Support a claim with observations from the activity.",
    ],
    questions: [
      "Which matched material was most important to the result?",
      "What evidence supports your explanation?",
      "What would change if one material were replaced?",
    ],
    safetyNotes,
    sourceMatchId: match.templateId,
    title: `${match.title}: ${match.estimatedMinutes}-minute lesson draft`,
  };
}
