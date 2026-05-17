# Mobile Next.js Rebuild Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild `apps/mobile` as a Next.js mobile web app that follows the CITYFARM-2.0 phone-frame pattern while preserving the existing Flutter files for rollback/reference.

**Architecture:** Add a Next.js App Router workspace inside `apps/mobile` without deleting Flutter/native files. The new UI uses a CITYFARM-style constrained mobile frame: desktop stage background, centered phone-width app, safe-area top bar, scrollable main content, and bottom dock. Domain content comes from the current Flutter MVP and product docs: scan photos, review inventory, match experiments, generate/edit lessons, and enforce safety checks.

**Tech Stack:** Next.js 16 App Router, React 19, TypeScript, Tailwind CSS v4, Bun workspace/Turbo, CSS variables, static demo data with client-side tab switching.

---

## Review Findings To Preserve

- CITYFARM reference pattern lives in `/Users/sunny/workspace/CITYFARM-2.0/apps/web/components/cityfarm/layout/AppShell.tsx`, `ShellTopBar.tsx`, `ShellBottomDock.tsx`, and `app/globals.css`.
- CITYFARM frame rules: outer `min-h-dvh`; inner `mx-auto h-dvh w-full max-w-[420px] flex flex-col overflow-hidden`; only `<main>` scrolls with `min-h-0 flex-1 overflow-y-auto`; top bar and bottom dock are normal flex children, not `position: fixed`.
- Do not copy CITYFARM farming palette or commerce labels. Copy the layout behavior only.
- Current Flutter source of truth:
  - `apps/mobile/lib/src/app/app_router.dart`
  - `apps/mobile/lib/src/features/shell/macgyver_shell.dart`
  - `apps/mobile/lib/src/features/mvp_screens.dart`
  - `apps/mobile/lib/src/core/design_system/design_system.dart`
  - `apps/mobile/lib/src/core/models.dart`
- Product flow to show: teacher profile -> photo scan -> detected inventory review -> experiment matching -> lesson generation/editor -> library/account.
- Keep teacher-in-the-loop and safety visible. No auto-advance past inventory review.

## Non-Negotiable Constraints

- Do not modify `apps/web`.
- Do not delete or rewrite Flutter files under `apps/mobile/lib`, `android`, `ios`, `macos`, `windows`, `linux`, `web`, `test`, `pubspec.yaml`, or `pubspec.lock`.
- Add the Next.js app non-destructively through new JS/TS files in `apps/mobile`.
- Do not run `create-next-app apps/mobile`; scaffold manually.
- Use Bun as the package manager. Do not create `package-lock.json`, `pnpm-lock.yaml`, or `yarn.lock`.
- If editing `apps/mobile/README.md`, read the current dirty file first and append a small section only.

## Planned File Structure

Create:

- `apps/mobile/package.json` - JS workspace package for the Next.js replacement app.
- `apps/mobile/next.config.ts` - Next config.
- `apps/mobile/tsconfig.json` - TypeScript config scoped to Next files so Flutter files are ignored.
- `apps/mobile/eslint.config.mjs` - ESLint config using `@repo/eslint-config/next-js` and ignoring Flutter/native dirs.
- `apps/mobile/postcss.config.mjs` - Tailwind v4 PostCSS config.
- `apps/mobile/next-env.d.ts` - Next generated typing reference.
- `apps/mobile/app/layout.tsx` - App Router root layout and metadata.
- `apps/mobile/app/globals.css` - mobile frame tokens, global styles, Tailwind sources.
- `apps/mobile/app/page.tsx` - server entrypoint that renders the client app.
- `apps/mobile/app/mobile-app.tsx` - client state, active tab, screen selection.
- `apps/mobile/app/components/mobile-shell.tsx` - CITYFARM-like frame, top bar, bottom dock.
- `apps/mobile/app/components/mobile-screens.tsx` - dashboard, scan, lessons, library, account screens.
- `apps/mobile/app/components/ui.tsx` - local UI primitives such as card, badge, section header, metric, progress, class join helper.
- `apps/mobile/app/components/icons.tsx` - small inline SVG icons used by nav/buttons.
- `apps/mobile/app/lib/demo-data.ts` - typed static demo data for the MVP flow.

Modify:

- `apps/mobile/README.md` - add a short "Next.js mobile shell" section only after implementation passes checks.
- `bun.lock` - only through `bun install`, if dependency graph changes.

## Shared Interfaces For Parallel Agents

Use these stable contracts so implementation agents can work on separate files.

```ts
// apps/mobile/app/lib/demo-data.ts
export type TabKey = "home" | "scan" | "lessons" | "library" | "account";

export type NavItem = {
  key: TabKey;
  label: string;
  title: string;
  subtitle: string;
};

export type InventoryItem = {
  id: string;
  name: string;
  rawLabel: string;
  quantity: number;
  unit: string;
  confidence: number;
  evidence: string;
  safety: "safe" | "check";
};

export type ExperimentMatch = {
  id: string;
  title: string;
  gradeBand: string;
  subject: string;
  durationMinutes: number;
  safety: "safe" | "check";
  availableMaterials: string[];
  missingMaterials: string[];
  reasoning: string;
};

export type LessonPlan = {
  title: string;
  topic: string;
  gradeBand: string;
  subject: string;
  durationMinutes: number;
  objectives: string[];
  materials: string[];
  flow: string[];
  questions: string[];
  safetyNotes: string[];
};
```

```ts
// apps/mobile/app/components/mobile-shell.tsx
import type { ReactNode } from "react";
import type { NavItem, TabKey } from "../lib/demo-data";

export function MobileShell(props: {
  activeTab: TabKey;
  navItems: NavItem[];
  onTabChange: (tab: TabKey) => void;
  title: string;
  subtitle: string;
  children: ReactNode;
}): JSX.Element;
```

```ts
// apps/mobile/app/components/mobile-screens.tsx
import type { TabKey } from "../lib/demo-data";

export function MobileScreen(props: { activeTab: TabKey }): JSX.Element;
```

## Parallel Sub-Agent Strategy

### Wave 1 - Independent Build Slices

Run these agents in parallel because write sets do not overlap.

1. **Infra Agent**
   - Owns: `package.json`, `next.config.ts`, `tsconfig.json`, `eslint.config.mjs`, `postcss.config.mjs`, `next-env.d.ts`.
   - Must not touch `app/**`.

2. **Shell Agent**
   - Owns: `app/components/mobile-shell.tsx`, `app/components/icons.tsx`.
   - Must implement frame behavior from CITYFARM and use the shared `MobileShell` interface.

3. **Data Agent**
   - Owns: `app/lib/demo-data.ts`.
   - Must model product docs and Flutter MVP content with typed data only.

4. **UI Primitives Agent**
   - Owns: `app/components/ui.tsx`.
   - Must implement lightweight primitives with 8px-or-less cards, accessible badges, and no nested card patterns.

5. **Screens Agent**
   - Owns: `app/components/mobile-screens.tsx`.
   - Uses interfaces from `demo-data.ts` and primitives from `ui.tsx`.
   - May import unresolved files during parallel work; Integration Agent resolves final compile.

### Wave 2 - Integration And Verification

Run after Wave 1 completes.

6. **Integration Agent**
   - Owns: `app/layout.tsx`, `app/page.tsx`, `app/mobile-app.tsx`, `app/globals.css`.
   - Wires shell, data, screens, metadata, responsive CSS, and active-tab state.

7. **Docs Agent**
   - Owns: `apps/mobile/README.md`.
   - Reads current file first and appends concise Next.js run instructions.

8. **QA Agent**
   - Owns no production files unless fixing failing checks is explicitly assigned by the coordinator.
   - Runs lint/typecheck/build and reports exact failures.

9. **Design Review Agent**
   - Owns no files by default.
   - Uses browser screenshots at 390x844 and 1280x900. Checks no horizontal overflow, dock visible, header not duplicated, text fits, frame centered.

10. **Final Review Agent**
    - Owns no files.
    - Reviews diff against this plan, CI readiness, and no accidental `apps/web`/Flutter rewrites.

## Task 1: Scaffold Next Workspace Package

**Files:**

- Create: `apps/mobile/package.json`
- Create: `apps/mobile/next.config.ts`
- Create: `apps/mobile/tsconfig.json`
- Create: `apps/mobile/eslint.config.mjs`
- Create: `apps/mobile/postcss.config.mjs`
- Create: `apps/mobile/next-env.d.ts`

- [ ] **Step 1: Create package manifest**

Use this content:

```json
{
  "name": "mobile",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev --port 3002",
    "build": "next build",
    "start": "next start",
    "lint": "eslint --max-warnings 0",
    "check-types": "next typegen && tsc --noEmit"
  },
  "dependencies": {
    "next": "16.2.6",
    "react": "19.2.4",
    "react-dom": "19.2.4"
  },
  "devDependencies": {
    "@repo/eslint-config": "*",
    "@repo/typescript-config": "*",
    "@tailwindcss/postcss": "^4",
    "@types/node": "^22.15.3",
    "@types/react": "19.2.2",
    "@types/react-dom": "19.2.2",
    "eslint": "^9.39.1",
    "tailwindcss": "^4",
    "typescript": "5.9.2"
  },
  "ignoreScripts": [
    "sharp",
    "unrs-resolver"
  ],
  "trustedDependencies": [
    "sharp",
    "unrs-resolver"
  ]
}
```

- [ ] **Step 2: Create Next config**

```ts
import type { NextConfig } from "next";

const nextConfig: NextConfig = {};

export default nextConfig;
```

- [ ] **Step 3: Create TypeScript config**

```json
{
  "extends": "@repo/typescript-config/nextjs.json",
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./*"]
    }
  },
  "include": [
    "next-env.d.ts",
    "next.config.ts",
    "app/**/*.ts",
    "app/**/*.tsx",
    ".next/types/**/*.ts",
    ".next/dev/types/**/*.ts"
  ],
  "exclude": [
    "node_modules",
    "android",
    "ios",
    "linux",
    "macos",
    "windows",
    "lib",
    "test",
    "integration_test",
    "web"
  ]
}
```

- [ ] **Step 4: Create ESLint config**

```js
import { nextJsConfig } from "@repo/eslint-config/next-js";
import { globalIgnores } from "eslint/config";

export default [
  ...nextJsConfig,
  globalIgnores([
    "android/**",
    "ios/**",
    "linux/**",
    "macos/**",
    "windows/**",
    "lib/**",
    "test/**",
    "integration_test/**",
    "web/**",
    "pubspec.lock",
  ]),
];
```

- [ ] **Step 5: Create PostCSS config**

```js
const config = {
  plugins: {
    "@tailwindcss/postcss": {},
  },
};

export default config;
```

- [ ] **Step 6: Create Next env typing file**

```ts
/// <reference types="next" />
/// <reference types="next/image-types/global" />

// This file should not be edited.
// See https://nextjs.org/docs/app/api-reference/config/typescript for more information.
```

- [ ] **Step 7: Install dependencies**

Run from repo root:

```bash
bun install
```

Expected: `bun.lock` may update. No npm/pnpm/yarn lockfile is created.

## Task 2: Build CITYFARM-Style Mobile Shell

**Files:**

- Create: `apps/mobile/app/components/icons.tsx`
- Create: `apps/mobile/app/components/mobile-shell.tsx`

- [ ] **Step 1: Implement icon set**

Icons needed: `HomeIcon`, `CameraIcon`, `SparkIcon`, `BookIcon`, `UserIcon`, `ShieldIcon`, `ChevronLeftIcon`, `CheckIcon`, `AlertIcon`, `SearchIcon`.

Implementation rule: each icon is an SVG component with `aria-hidden="true"`, `focusable="false"`, `viewBox="0 0 24 24"`, and `currentColor`.

- [ ] **Step 2: Implement `MobileShell`**

Requirements:

- Outer stage: `min-h-dvh` with subtle MacGyver background.
- Inner phone frame: `mx-auto flex h-dvh w-full max-w-[420px] flex-col overflow-hidden bg-white`.
- Header: safe-area top padding using `pt-[max(0.75rem,env(safe-area-inset-top))]`, border bottom, brand chip `MC`, route title/subtitle, compact status pill.
- Main: `min-h-0 flex-1 overflow-y-auto bg-[var(--color-screen)]`.
- Dock: 5 columns, safe-area bottom padding, active tab uses primary blue, inactive tab uses screen/subtle background, each button has `aria-current` when active.
- Use `<button type="button">` for tabs because this is a single-page prototype.

## Task 3: Create Typed Demo Data

**Files:**

- Create: `apps/mobile/app/lib/demo-data.ts`

- [ ] **Step 1: Export nav items**

Tabs must match Flutter shell order:

```ts
export const navItems: NavItem[] = [
  { key: "home", label: "Home", title: "Teacher Dashboard", subtitle: "Photo-to-lesson demo path" },
  { key: "scan", label: "Scan", title: "Inventory Scan", subtitle: "Capture and review classroom objects" },
  { key: "lessons", label: "Lessons", title: "Experiment Matches", subtitle: "Choose a safe activity" },
  { key: "library", label: "Library", title: "Lesson Library", subtitle: "Saved generated plans" },
  { key: "account", label: "Account", title: "Teacher Profile", subtitle: "Class context and safety defaults" }
];
```

- [ ] **Step 2: Export product data**

Include:

- Teacher profile: `Nguyen Linh`, Physics, Grade 8, class `8A1`, topic `Forces and motion`, 45 minutes.
- Inventory items: plastic bottle, rubber bands, wooden skewers, magnets; each has confidence and evidence.
- Experiment matches: `Rubber Band Powered Car`, `Magnetic Field Mapping`, and `Paper Bridge Load Test`.
- Lesson plan: 45-minute plan with objectives, materials, flow, questions, and safety notes.
- Metrics: detected items, suggestions, lesson duration.
- Safety checkpoints: teacher confirms inventory, unsafe templates filtered, export blocked until safety accepted.

## Task 4: Build Local UI Primitives

**Files:**

- Create: `apps/mobile/app/components/ui.tsx`

- [ ] **Step 1: Implement `cn`**

```ts
export function cn(...classes: Array<string | false | null | undefined>) {
  return classes.filter(Boolean).join(" ");
}
```

- [ ] **Step 2: Implement primitives**

Create these exports:

- `Card`
- `Badge`
- `SectionHeader`
- `MetricGrid`
- `ProgressRail`
- `MaterialRow`
- `PillButton`
- `SafetyCallout`

Design rules:

- Cards use `rounded-lg` or lower and a subtle border.
- No cards inside cards.
- Badges have accessible text and visible contrast.
- Buttons have stable heights and no text overflow.
- Use `type="button"` for interactive controls.

## Task 5: Build Mobile Screens

**Files:**

- Create: `apps/mobile/app/components/mobile-screens.tsx`

- [ ] **Step 1: Implement dashboard screen**

Show:

- Today section: "Photo-to-lesson demo path".
- Badges: API backend/mock backend, Teacher MVP, Safety checks.
- Primary action: "Scan classroom items".
- Metrics: detected items, suggestions, 45m target.
- Workflow list: capture, review, match, generate.

- [ ] **Step 2: Implement scan screen**

Show:

- Image capture/upload area with three photo slots.
- Detected material list with confidence/evidence.
- Low-confidence or safety-check material visibly marked.
- Teacher confirmation panel.
- Button text: "Use this inventory for matching".

- [ ] **Step 3: Implement lessons screen**

Show:

- Safe-only filter chip in selected state.
- Three experiment match cards.
- Available/missing material badges.
- Safety note and reasoning.
- Lesson generation context preview.

- [ ] **Step 4: Implement library screen**

Show:

- Search input visual.
- Saved lesson card for generated lesson.
- Editable generated plan sections: objectives, materials, flow, questions, safety notes.
- Export safety confirmation state.

- [ ] **Step 5: Implement account screen**

Show:

- Teacher profile fields from demo data.
- School/class context.
- Security/password visual block.
- Safety defaults and privacy note for classroom photos.

## Task 6: Integrate App Router, Global CSS, And Client State

**Files:**

- Create: `apps/mobile/app/layout.tsx`
- Create: `apps/mobile/app/page.tsx`
- Create: `apps/mobile/app/mobile-app.tsx`
- Create: `apps/mobile/app/globals.css`

- [ ] **Step 1: Root layout**

Use `app/globals.css`, set `lang="vi"`, and metadata:

```ts
export const metadata = {
  title: "MacGyver Classroom Mobile",
  description: "Mobile workflow for turning classroom objects into safe STEM lessons.",
};
```

- [ ] **Step 2: Page entrypoint**

`page.tsx` should render only `<MobileApp />`.

- [ ] **Step 3: Client app state**

`mobile-app.tsx` should:

- Use `useState<TabKey>("home")`.
- Resolve current nav item from `navItems`.
- Render `MobileShell`.
- Render `MobileScreen`.

- [ ] **Step 4: Global CSS**

Use Tailwind v4 and source scanning:

```css
@import "tailwindcss";

@source "./**/*.{js,ts,jsx,tsx,mjs}";
@source "../app/**/*.{js,ts,jsx,tsx,mjs}";
@source "../../packages/**/*.{js,ts,jsx,tsx,mjs}";
```

Define CSS variables based on Flutter tokens:

- `--color-app-bg: #FAFAF7`
- `--color-screen: #FFFFFF`
- `--color-subtle: #F5F2EA`
- `--color-heading: #2C2C2A`
- `--color-muted: #5F5E5A`
- `--color-primary: #1A24A8`
- `--color-primary-soft: #E8EAF8`
- `--color-accent: #F5B945`
- `--color-warning: #B47514`
- `--color-danger: #A32D2D`
- `--color-border: #E5E2D7`

Base rules:

- `html, body { max-width: 100%; overflow-x: hidden; }`
- `body { min-height: 100vh; margin: 0; }`
- `* { box-sizing: border-box; }`
- Focus ring uses primary color.

## Task 7: Update Mobile README

**Files:**

- Modify: `apps/mobile/README.md`

- [ ] **Step 1: Read current README**

Run:

```bash
sed -n '1,220p' apps/mobile/README.md
```

- [ ] **Step 2: Append concise Next.js section**

Add a section with:

- The Flutter files are preserved for reference.
- The Next.js mobile shell runs from the same `apps/mobile` workspace.
- Commands:
  - `bun install`
  - `npm --workspace mobile run dev`
  - `npm --workspace mobile run lint`
  - `npm --workspace mobile run check-types`
  - `npm --workspace mobile run build`

## Task 8: Verify Locally

**Files:**

- No planned production edits.

- [ ] **Step 1: Confirm no unintended files**

Run:

```bash
git status --short
```

Expected:

- New Next files under `apps/mobile`.
- `apps/mobile/README.md` modified only if Task 7 ran.
- `bun.lock` changed only if dependencies changed.
- No `apps/web` modifications from this work.
- No deletions of Flutter/native files.

- [ ] **Step 2: Run focused checks**

Run:

```bash
npm --workspace mobile run lint
npm --workspace mobile run check-types
npm --workspace mobile run build
```

Expected: all pass.

- [ ] **Step 3: Run app in browser**

Run:

```bash
npm --workspace mobile run dev
```

Open `http://localhost:3002`.

Use Browser at:

- Desktop viewport: `1280x900`.
- Mobile viewport: `390x844`.

Check:

- Phone frame is centered and maxes at about 420px.
- Header and dock stay visible as flex children.
- Main content scrolls.
- No horizontal overflow.
- Text fits buttons/cards.
- No duplicate headers.
- Active dock tab changes content.

## Task 9: Final Review

**Files:**

- No production edits unless a reviewer finding requires a targeted fix.

- [ ] **Step 1: Spec compliance review**

Check implementation against:

- CITYFARM frame behavior.
- Flutter route/tab/content mapping.
- Product flow from PRD and feature docs.
- Non-negotiable constraints above.

- [ ] **Step 2: Code quality review**

Check:

- Components are focused and typed.
- No duplicated large data blobs outside `demo-data.ts`.
- No nested cards.
- No `apps/web` edits.
- ESLint/typecheck/build pass.
- README instructions are accurate.

## Ready-To-Use Sub-Agent Prompts

### Infra Agent Prompt

```text
Implement Task 1 from docs/superpowers/plans/2026-05-17-mobile-nextjs-rebuild.md. You own only apps/mobile/package.json, next.config.ts, tsconfig.json, eslint.config.mjs, postcss.config.mjs, and next-env.d.ts. Do not touch app/**, apps/web, Flutter/native files, or lockfiles except through bun install if required. Return files changed and verification attempted.
```

### Shell Agent Prompt

```text
Implement Task 2 from docs/superpowers/plans/2026-05-17-mobile-nextjs-rebuild.md. You own only apps/mobile/app/components/mobile-shell.tsx and apps/mobile/app/components/icons.tsx. Copy CITYFARM layout behavior conceptually, not its palette/content. Use the shared MobileShell interface from the plan. Do not edit data, screens, layout, CSS, or package config.
```

### Data Agent Prompt

```text
Implement Task 3 from docs/superpowers/plans/2026-05-17-mobile-nextjs-rebuild.md. You own only apps/mobile/app/lib/demo-data.ts. Use product docs and Flutter content summarized in the plan. Export typed data only. Do not edit UI/components/config.
```

### UI Primitives Agent Prompt

```text
Implement Task 4 from docs/superpowers/plans/2026-05-17-mobile-nextjs-rebuild.md. You own only apps/mobile/app/components/ui.tsx. Build accessible local primitives. Cards must have 8px-or-less radius and no nested card pattern. Do not edit screens, data, shell, layout, or config.
```

### Screens Agent Prompt

```text
Implement Task 5 from docs/superpowers/plans/2026-05-17-mobile-nextjs-rebuild.md. You own only apps/mobile/app/components/mobile-screens.tsx. Use imports from ../lib/demo-data and ./ui as defined by the plan. Implement all five tabs: home, scan, lessons, library, account. Do not edit shell, CSS, data, layout, or config.
```

### Integration Agent Prompt

```text
Implement Task 6 from docs/superpowers/plans/2026-05-17-mobile-nextjs-rebuild.md after Tasks 1-5 are complete. You own only apps/mobile/app/layout.tsx, page.tsx, mobile-app.tsx, and globals.css. Wire active-tab state, MobileShell, MobileScreen, and CSS tokens. Fix import paths only if needed. Do not edit apps/web or Flutter/native files.
```

### QA Agent Prompt

```text
Run Task 8 from docs/superpowers/plans/2026-05-17-mobile-nextjs-rebuild.md. Do not edit files unless the coordinator assigns a concrete fix. Report exact command results for npm --workspace mobile run lint, check-types, build, and browser checks at localhost:3002.
```

### Final Review Agent Prompt

```text
Review the completed implementation against docs/superpowers/plans/2026-05-17-mobile-nextjs-rebuild.md. Use code-review stance. Findings first with file/line evidence. Check no apps/web edits, no deleted Flutter/native files, CITYFARM frame behavior, mobile UX, accessibility, lint/typecheck/build status, and README accuracy.
```

## Execution Recommendation

Use subagent-driven execution:

1. Dispatch Wave 1 agents in parallel.
2. Wait for all Wave 1 agents.
3. Dispatch Integration Agent.
4. Dispatch Docs Agent.
5. Dispatch QA and Design Review.
6. Apply targeted fixes if review finds issues.
7. Dispatch Final Review.

Do not start implementation until the coordinator confirms this plan is the active plan.
