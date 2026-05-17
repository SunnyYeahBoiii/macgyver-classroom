"use client";

import type { ComponentType, JSX, ReactNode } from "react";

import type { NavItem } from "../lib/demo-data";
import {
  BookIcon,
  CameraIcon,
  HomeIcon,
  ShieldIcon,
  SparkIcon,
  UserIcon,
  type IconProps,
} from "./icons";

type TabKey = NavItem["key"];

const tabIcons = {
  home: HomeIcon,
  scan: CameraIcon,
  lessons: SparkIcon,
  library: BookIcon,
  account: UserIcon,
} satisfies Record<TabKey, ComponentType<IconProps>>;

export function MobileShell(props: {
  activeTab: TabKey;
  navItems: NavItem[];
  onTabChange: (tab: TabKey) => void;
  title: string;
  subtitle: string;
  children: ReactNode;
}): JSX.Element {
  const { activeTab, children, navItems, onTabChange, subtitle, title } = props;

  return (
    <div
      className="min-h-dvh text-[var(--color-heading)]"
      style={{
        background:
          "radial-gradient(circle at top, var(--color-primary-soft) 0%, transparent 34%), linear-gradient(180deg, var(--color-app-bg) 0%, var(--color-subtle) 100%)",
      }}
    >
      <div className="mx-auto flex h-dvh w-full max-w-[420px] flex-col overflow-hidden bg-white shadow-[0_18px_70px_rgba(44,44,42,0.16)]">
        <header className="border-b border-[var(--color-border)] bg-white px-4 pb-3 pt-[max(0.75rem,env(safe-area-inset-top))]">
          <div className="flex items-center gap-3">
            <div className="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-[var(--color-primary)] text-sm font-black text-white">
              MC
            </div>

            <div className="min-w-0 flex-1">
              <p className="truncate text-xs font-semibold text-[var(--color-muted)]">
                MacGyver Classroom
              </p>
              <h1 className="truncate text-lg font-black leading-tight text-[var(--color-heading)]">
                {title}
              </h1>
              <p className="line-clamp-2 text-xs leading-4 text-[var(--color-muted)]">
                {subtitle}
              </p>
            </div>

            <div className="flex shrink-0 items-center gap-1.5 rounded-full bg-[var(--color-primary-soft)] px-2.5 py-1 text-xs font-bold text-[var(--color-primary)]">
              <ShieldIcon className="h-3.5 w-3.5" />
              <span>Safe</span>
            </div>
          </div>
        </header>

        <main className="min-h-0 flex-1 overflow-y-auto bg-[var(--color-screen)]">
          {children}
        </main>

        <nav
          aria-label="Primary"
          className="border-t border-[var(--color-border)] bg-white px-3 pb-[max(0.75rem,env(safe-area-inset-bottom))] pt-2"
        >
          <div className="grid grid-cols-5 gap-2">
            {navItems.map((item) => {
              const Icon = tabIcons[item.key];
              const isActive = item.key === activeTab;

              return (
                <button
                  aria-current={isActive ? "page" : undefined}
                  className={[
                    "flex min-w-0 flex-col items-center justify-center rounded-xl px-1.5 py-2 text-center transition-colors",
                    "focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[var(--color-primary)]",
                    isActive
                      ? "bg-[var(--color-primary)] text-white shadow-sm"
                      : "bg-[var(--color-subtle)] text-[var(--color-muted)] hover:bg-[var(--color-primary-soft)] hover:text-[var(--color-primary)]",
                  ].join(" ")}
                  key={item.key}
                  onClick={() => {
                    onTabChange(item.key);
                  }}
                  type="button"
                >
                  <Icon className="h-5 w-5 shrink-0" />
                  <span className="mt-1 max-w-full truncate text-[11px] font-bold leading-none">
                    {item.label}
                  </span>
                </button>
              );
            })}
          </div>
        </nav>
      </div>
    </div>
  );
}
