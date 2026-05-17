import { buildLessonPlanSystemPrompt } from './lesson-plan.prompt';

describe('buildLessonPlanSystemPrompt', () => {
  it('requires generated lesson content to be written in English', () => {
    const prompt = buildLessonPlanSystemPrompt({
      confirmedItems: [
        {
          active: true,
          canonicalName: 'paper_cup',
          confidence: 0.91,
          confirmedAt: '2026-05-17T00:00:00.000Z',
          displayName: 'Paper cup',
          evidence: ['Visible paper cup stack.'],
          id: 'item-1',
          quantityEstimate: 10,
          rawLabel: 'paper cup',
          safetyFlags: [],
          scanId: 'scan-1',
          unit: 'pieces',
        },
      ],
      experiment: {
        estimatedMinutes: 35,
        id: 'paper-cup-sound-amplifier',
        optionalMaterials: [],
        requiredMaterials: [
          { canonicalName: 'paper_cup', displayName: 'Paper cup' },
        ],
        safetyCategory: 'LOW',
        safetyNotes: [{ category: 'LOW', message: 'Use gentle tapping only.' }],
        summary: 'Compare vibration and loudness.',
        title: 'Paper Cup Sound Amplifier',
      },
      teacherContext: {
        gradeBand: 'Grade 8',
        subject: 'Physics',
        topic: 'Sound and vibration',
      },
    });

    expect(prompt).toContain(
      'Write every generated lesson field in clear English.',
    );
    expect(prompt).not.toContain('Vietnamese');
  });
});
