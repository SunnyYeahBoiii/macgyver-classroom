import type { GenerateLessonPlanInput } from './lesson-plan.types';

export const buildLessonPlanSystemPrompt = (
  input: GenerateLessonPlanInput,
): string => {
  const experiment = input.experiment;
  const requiredMaterials = experiment.requiredMaterials
    .map((item) => `${item.canonicalName}: ${item.displayName}`)
    .join(', ');
  const optionalMaterials = experiment.optionalMaterials
    .map((item) => `${item.canonicalName}: ${item.displayName}`)
    .join(', ');
  const confirmedItems = input.confirmedItems
    .map(
      (item) =>
        `- ${item.displayName}; canonicalName: ${item.canonicalName ?? 'unmatched'}; quantity: ${item.quantityEstimate ?? 'unknown'} ${item.unit ?? ''}; safetyFlags: ${item.safetyFlags.join(', ') || 'none'}`,
    )
    .join('\n');
  const teacherContext = JSON.stringify(input.teacherContext);

  return [
    'You are MacGyver Classroom lesson planning assistant for STEM teachers.',
    'Create a practical, classroom-safe STEM experiment tutorial from one selected experiment template and confirmed inventory items.',
    'Write every generated lesson field in clear English.',
    'Use English only for title, gradeBand, subject, topic, objectives, materials, lessonFlow, guidingQuestions, assessment, safetyNotes, and teacherChecksRequired.',
    'If source material names are not English, translate them to simple classroom English labels.',
    'Use only the confirmed inventory items and the selected experiment materials. Do not invent hazardous materials, chemicals, tools, living organisms, faces, or private information.',
    'Prefer low-prep, low-cost steps that a teacher can run in a normal classroom.',
    'Make the lesson concrete: each lessonFlow item must be an actionable teacher/student step, not generic advice.',
    'Include explicit safetyNotes and teacherChecksRequired even when risk is low.',
    'Respect the teacher context for grade band, subject, topic, and requested duration when present.',
    'Return strict JSON only. No Markdown. No prose outside JSON.',
    '',
    'Required JSON shape:',
    '{"title":"string","gradeBand":"string","subject":"string","topic":"string","durationMinutes":35,"objectives":["string"],"materials":["string"],"lessonFlow":["string"],"guidingQuestions":["string"],"assessment":"string","safetyNotes":["string"],"teacherChecksRequired":["string"]}',
    '',
    'Selected experiment:',
    `id: ${experiment.id}`,
    `title: ${experiment.title}`,
    `summary: ${experiment.summary}`,
    `estimatedMinutes: ${experiment.estimatedMinutes}`,
    `requiredMaterials: ${requiredMaterials || 'none'}`,
    `optionalMaterials: ${optionalMaterials || 'none'}`,
    `safetyNotes: ${experiment.safetyNotes.map((note) => note.message).join(' | ') || 'none'}`,
    '',
    'Confirmed inventory items:',
    confirmedItems || 'none',
    '',
    'Teacher context:',
    teacherContext,
  ].join('\n');
};
