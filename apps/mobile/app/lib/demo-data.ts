export type NavKey = "home" | "scan" | "lessons" | "library" | "account";

export type ConfidenceLabel = "high" | "medium" | "low";

export type SafetyStatus = "cleared" | "needs_review" | "blocked";

export type MaterialAvailability = "available" | "missing";

export type CheckpointStatus = "complete" | "required" | "blocked";

export interface NavItem {
  readonly key: NavKey;
  readonly label: string;
  readonly title: string;
  readonly subtitle: string;
}

export interface TeacherProfile {
  readonly name: string;
  readonly subject: string;
  readonly gradeLevel: string;
  readonly className: string;
  readonly currentTopic: string;
  readonly lessonDurationMinutes: number;
  readonly schoolContext: string;
}

export interface InventorySafety {
  readonly status: SafetyStatus;
  readonly note: string;
  readonly requiredAction?: string;
}

export interface InventoryItem {
  readonly id: string;
  readonly name: string;
  readonly quantity: string;
  readonly confidence: number;
  readonly confidenceLabel: ConfidenceLabel;
  readonly evidence: readonly string[];
  readonly properties: readonly string[];
  readonly safety: InventorySafety;
  readonly confirmed: boolean;
}

export interface ExperimentMaterial {
  readonly name: string;
  readonly availability: MaterialAvailability;
  readonly source: string;
}

export interface ExperimentMatch {
  readonly id: string;
  readonly title: string;
  readonly summary: string;
  readonly fitScore: number;
  readonly estimatedMinutes: number;
  readonly topicFit: string;
  readonly materials: readonly ExperimentMaterial[];
  readonly safetyNote: string;
  readonly reasoning: string;
}

export interface LessonFlowStep {
  readonly time: string;
  readonly title: string;
  readonly activity: string;
}

export interface LessonPlan {
  readonly id: string;
  readonly title: string;
  readonly sourceMatchId: string;
  readonly durationMinutes: number;
  readonly objectives: readonly string[];
  readonly materials: readonly string[];
  readonly flow: readonly LessonFlowStep[];
  readonly questions: readonly string[];
  readonly safetyNotes: readonly string[];
  readonly exportSafetyAccepted: boolean;
}

export interface DemoMetric {
  readonly key: "detectedItems" | "suggestions" | "lessonDuration";
  readonly label: string;
  readonly value: string;
  readonly helper: string;
}

export interface SafetyCheckpoint {
  readonly id: string;
  readonly label: string;
  readonly description: string;
  readonly status: CheckpointStatus;
  readonly blocksExport: boolean;
}

export const navItems: NavItem[] = [
  {
    key: "home",
    label: "Home",
    title: "Teacher Dashboard",
    subtitle: "Photo-to-lesson demo path",
  },
  {
    key: "scan",
    label: "Scan",
    title: "Inventory Scan",
    subtitle: "Capture and review classroom objects",
  },
  {
    key: "lessons",
    label: "Lessons",
    title: "Experiment Matches",
    subtitle: "Choose a safe activity",
  },
  {
    key: "library",
    label: "Library",
    title: "Lesson Library",
    subtitle: "Saved generated plans",
  },
  {
    key: "account",
    label: "Account",
    title: "Teacher Profile",
    subtitle: "Class context and safety defaults",
  },
];

export const teacherProfile: TeacherProfile = {
  name: "Nguyen Linh",
  subject: "Physics",
  gradeLevel: "Grade 8",
  className: "8A1",
  currentTopic: "Forces and motion",
  lessonDurationMinutes: 45,
  schoolContext: "Urban lower-secondary classroom with shared lab supplies",
};

export const inventoryItems: InventoryItem[] = [
  {
    id: "plastic-bottle",
    name: "Plastic bottle",
    quantity: "1 clean 500 ml bottle",
    confidence: 0.93,
    confidenceLabel: "high",
    evidence: [
      "Clear cylindrical bottle outline detected in photo slot 1",
      "Cap and label contour match common classroom water bottle",
    ],
    properties: ["lightweight", "rollable", "reusable body"],
    safety: {
      status: "cleared",
      note: "Use an empty, clean bottle with no sharp cut edges.",
    },
    confirmed: true,
  },
  {
    id: "rubber-bands",
    name: "Rubber bands",
    quantity: "6 assorted bands",
    confidence: 0.88,
    confidenceLabel: "high",
    evidence: [
      "Elastic loops grouped near desk organizer in photo slot 2",
      "Color and shape match rubber band bundle",
    ],
    properties: ["elastic", "stores energy", "low mass"],
    safety: {
      status: "needs_review",
      note: "Avoid snapping bands toward faces or eyes.",
      requiredAction: "Teacher reminds students to stretch bands slowly.",
    },
    confirmed: false,
  },
  {
    id: "wooden-skewers",
    name: "Wooden skewers",
    quantity: "8 blunt-ended sticks",
    confidence: 0.82,
    confidenceLabel: "medium",
    evidence: [
      "Parallel wooden sticks detected beside craft tray",
      "Length and color match bamboo skewers or dowels",
    ],
    properties: ["rigid axle", "lightweight", "straight edge"],
    safety: {
      status: "needs_review",
      note: "Pointed tips must be trimmed or covered before student use.",
      requiredAction: "Confirm blunt ends before activity starts.",
    },
    confirmed: false,
  },
  {
    id: "magnets",
    name: "Magnets",
    quantity: "4 small bar magnets",
    confidence: 0.74,
    confidenceLabel: "medium",
    evidence: [
      "Rectangular red and blue objects detected in photo slot 3",
      "Magnet label visible on storage box, but object edges are partially covered",
    ],
    properties: ["magnetic field", "attracts steel", "polarity"],
    safety: {
      status: "needs_review",
      note: "Keep small magnets away from mouths, phones, and medical devices.",
      requiredAction: "Teacher counts magnets before and after class.",
    },
    confirmed: false,
  },
];

export const experimentMatches: ExperimentMatch[] = [
  {
    id: "rubber-band-powered-car",
    title: "Rubber Band Powered Car",
    summary:
      "Students build a simple rolling model to connect stored elastic energy, friction, and motion.",
    fitScore: 94,
    estimatedMinutes: 45,
    topicFit: "Forces and motion",
    materials: [
      {
        name: "Plastic bottle",
        availability: "available",
        source: "Detected inventory",
      },
      {
        name: "Rubber bands",
        availability: "available",
        source: "Detected inventory",
      },
      {
        name: "Wooden skewers",
        availability: "available",
        source: "Detected inventory",
      },
      {
        name: "Bottle caps or cardboard wheels",
        availability: "missing",
        source: "Common classroom substitute",
      },
    ],
    safetyNote:
      "Use blunt axles, slow rubber-band winding, and teacher-approved cutting only.",
    reasoning:
      "Best match because three detected materials map directly to the build and the activity fits a 45-minute Grade 8 physics lesson.",
  },
  {
    id: "magnetic-field-mapping",
    title: "Magnetic Field Mapping",
    summary:
      "Students map invisible magnetic field direction with paper, compasses, and bar magnets.",
    fitScore: 87,
    estimatedMinutes: 40,
    topicFit: "Forces at a distance",
    materials: [
      {
        name: "Magnets",
        availability: "available",
        source: "Detected inventory",
      },
      {
        name: "Paper",
        availability: "missing",
        source: "Classroom stationery",
      },
      {
        name: "Compass or iron filings in sealed pouch",
        availability: "missing",
        source: "Teacher supply",
      },
    ],
    safetyNote:
      "Do not use loose iron filings; keep magnets away from electronics and medical devices.",
    reasoning:
      "Strong concept match for forces, but missing mapping tools make it a secondary suggestion.",
  },
  {
    id: "paper-bridge-load-test",
    title: "Paper Bridge Load Test",
    summary:
      "Students compare bridge shapes by testing how structure changes load capacity.",
    fitScore: 79,
    estimatedMinutes: 35,
    topicFit: "Balanced forces and structures",
    materials: [
      {
        name: "Paper",
        availability: "missing",
        source: "Classroom stationery",
      },
      {
        name: "Books",
        availability: "missing",
        source: "Classroom supply",
      },
      {
        name: "Coins or washers",
        availability: "missing",
        source: "Teacher supply",
      },
      {
        name: "Wooden skewers",
        availability: "available",
        source: "Optional reinforcement from detected inventory",
      },
    ],
    safetyNote:
      "Keep stacked books low and test loads over the desk surface only.",
    reasoning:
      "Safe fallback activity with clear force concepts, but it uses fewer detected materials.",
  },
];

export const lessonPlan: LessonPlan = {
  id: "lesson-rubber-band-powered-car",
  title: "Rubber Band Powered Car",
  sourceMatchId: "rubber-band-powered-car",
  durationMinutes: 45,
  objectives: [
    "Explain how elastic potential energy can become motion.",
    "Identify friction and axle alignment as forces that affect speed and distance.",
    "Use evidence from a short test run to improve a simple vehicle design.",
  ],
  materials: [
    "Clean plastic bottle",
    "Rubber bands",
    "Blunt wooden skewers",
    "Bottle caps or cardboard wheels",
    "Tape",
    "Ruler",
  ],
  flow: [
    {
      time: "0-5 min",
      title: "Prompt",
      activity:
        "Ask students how a stretched rubber band can make an object move without a motor.",
    },
    {
      time: "5-12 min",
      title: "Safety and build plan",
      activity:
        "Confirm blunt skewers, assign roles, and sketch the axle and rubber-band path.",
    },
    {
      time: "12-28 min",
      title: "Build",
      activity:
        "Teams assemble the car body, axle, wheels, and rubber-band drive under teacher supervision.",
    },
    {
      time: "28-38 min",
      title: "Test and improve",
      activity:
        "Teams measure travel distance, identify friction points, and adjust one variable.",
    },
    {
      time: "38-45 min",
      title: "Explain",
      activity:
        "Students connect their evidence to stored energy, friction, and balanced or unbalanced forces.",
    },
  ],
  questions: [
    "Where is energy stored before the car starts moving?",
    "Which force slowed the car the most during the test?",
    "What changed when your team adjusted the axle or rubber band?",
    "How would the result differ on a rougher surface?",
  ],
  safetyNotes: [
    "Teacher confirms all inventory before matching starts.",
    "Students do not point stretched rubber bands at faces or eyes.",
    "Wooden skewer tips must be blunt, trimmed, or covered.",
    "Any cutting or wheel piercing is handled by the teacher.",
    "Export remains blocked until the teacher accepts safety notes.",
  ],
  exportSafetyAccepted: false,
};

export const metrics: DemoMetric[] = [
  {
    key: "detectedItems",
    label: "Detected items",
    value: "4",
    helper: "Ready for teacher review",
  },
  {
    key: "suggestions",
    label: "Suggestions",
    value: "3",
    helper: "Safe experiment matches",
  },
  {
    key: "lessonDuration",
    label: "Lesson target",
    value: "45m",
    helper: "Grade 8 physics",
  },
];

export const safetyCheckpoints: SafetyCheckpoint[] = [
  {
    id: "teacher-confirms-inventory",
    label: "Teacher confirms inventory",
    description:
      "Detected objects require teacher review before they are used for matching.",
    status: "required",
    blocksExport: false,
  },
  {
    id: "unsafe-templates-filtered",
    label: "Unsafe templates filtered",
    description:
      "Activities requiring flame, glass, chemicals, or mains electricity are excluded.",
    status: "complete",
    blocksExport: false,
  },
  {
    id: "export-blocked-until-safety-accepted",
    label: "Export blocked until safety accepted",
    description:
      "Lesson export stays disabled until the teacher accepts the generated safety notes.",
    status: "blocked",
    blocksExport: true,
  },
];
