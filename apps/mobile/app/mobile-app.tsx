"use client";

import type { JSX } from "react";
import { useState } from "react";

import { MobileScreen } from "./components/mobile-screens";
import { MobileShell } from "./components/mobile-shell";
import { navItems, type NavKey } from "./lib/demo-data";
import type { MatchExperimentsResponse } from "./lib/inventory-api";
import type {
  GeneratedLessonDraft,
  SavedLessonDraft,
} from "./lib/lesson-flow";

type TabKey = NavKey;

export function MobileApp(): JSX.Element | null {
  const [activeTab, setActiveTab] = useState<TabKey>("home");
  const [latestMatchResult, setLatestMatchResult] =
    useState<MatchExperimentsResponse | null>(null);
  const [latestLessonDraft, setLatestLessonDraft] =
    useState<GeneratedLessonDraft | null>(null);
  const [savedLessons, setSavedLessons] = useState<SavedLessonDraft[]>([]);
  const currentNavItem =
    navItems.find((item) => item.key === activeTab) ??
    navItems.find((item) => item.key === "home");

  if (!currentNavItem) {
    return null;
  }

  function navigateTo(tab: TabKey) {
    setActiveTab(tab);
  }

  function handleLessonDraftCreated(lesson: GeneratedLessonDraft | null) {
    setLatestLessonDraft(lesson);
  }

  function handleLessonSaved(lesson: GeneratedLessonDraft) {
    setSavedLessons((current) => {
      const existing = current.find((item) => item.id === lesson.id);
      const savedLesson: SavedLessonDraft = {
        ...lesson,
        exportSafetyAccepted: false,
        savedAt: new Date().toISOString(),
        version: existing ? existing.version + 1 : 1,
      };

      return [
        savedLesson,
        ...current.filter((item) => item.id !== lesson.id),
      ];
    });
    setActiveTab("library");
  }

  return (
    <MobileShell
      activeTab={activeTab}
      navItems={navItems}
      onTabChange={navigateTo}
      subtitle={currentNavItem.subtitle}
      title={currentNavItem.title}
    >
      <MobileScreen
        activeTab={activeTab}
        latestLessonDraft={latestLessonDraft}
        latestMatchResult={latestMatchResult}
        onLessonDraftCreated={handleLessonDraftCreated}
        onLessonSaved={handleLessonSaved}
        onMatchResult={setLatestMatchResult}
        onTabChange={navigateTo}
        savedLessons={savedLessons}
      />
    </MobileShell>
  );
}
