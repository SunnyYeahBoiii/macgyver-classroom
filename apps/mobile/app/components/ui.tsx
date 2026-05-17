import type {
  ButtonHTMLAttributes,
  HTMLAttributes,
  ReactNode,
} from "react";

export function cn(...classes: Array<string | false | null | undefined>) {
  return classes.filter(Boolean).join(" ");
}

type Tone = "neutral" | "blue" | "green" | "amber" | "red";

const badgeTones: Record<Tone, string> = {
  neutral: "border-slate-300 bg-white text-slate-700",
  blue: "border-blue-200 bg-blue-50 text-blue-800",
  green: "border-emerald-200 bg-emerald-50 text-emerald-800",
  amber: "border-amber-300 bg-amber-50 text-amber-900",
  red: "border-red-200 bg-red-50 text-red-800",
};

const calloutTones: Record<Tone, string> = {
  neutral: "border-slate-300 bg-slate-50 text-slate-900",
  blue: "border-blue-200 bg-blue-50 text-blue-950",
  green: "border-emerald-200 bg-emerald-50 text-emerald-950",
  amber: "border-amber-300 bg-amber-50 text-amber-950",
  red: "border-red-200 bg-red-50 text-red-950",
};

const metricTones: Record<Tone, string> = {
  neutral: "bg-slate-50",
  blue: "bg-blue-50",
  green: "bg-emerald-50",
  amber: "bg-amber-50",
  red: "bg-red-50",
};

type CardProps = HTMLAttributes<HTMLDivElement>;

export function Card({ className, ...props }: CardProps) {
  return (
    <div
      className={cn(
        "rounded-lg border border-slate-200 bg-white p-4 shadow-sm",
        className,
      )}
      {...props}
    />
  );
}

type BadgeProps = HTMLAttributes<HTMLSpanElement> & {
  tone?: Tone;
};

export function Badge({ className, tone = "neutral", ...props }: BadgeProps) {
  return (
    <span
      className={cn(
        "inline-flex min-h-6 max-w-full items-center rounded-full border px-2.5 py-1 text-xs font-semibold leading-none",
        badgeTones[tone],
        className,
      )}
      {...props}
    />
  );
}

type SectionHeaderProps = HTMLAttributes<HTMLElement> & {
  action?: ReactNode;
  description?: ReactNode;
  eyebrow?: ReactNode;
  title: ReactNode;
};

export function SectionHeader({
  action,
  className,
  description,
  eyebrow,
  title,
  ...props
}: SectionHeaderProps) {
  return (
    <header
      className={cn(
        "flex items-start justify-between gap-3 text-slate-950",
        className,
      )}
      {...props}
    >
      <div className="min-w-0 space-y-1">
        {eyebrow ? (
          <p className="text-xs font-semibold uppercase tracking-normal text-slate-500">
            {eyebrow}
          </p>
        ) : null}
        <h2 className="text-lg font-semibold leading-tight">{title}</h2>
        {description ? (
          <p className="text-sm leading-5 text-slate-600">{description}</p>
        ) : null}
      </div>
      {action ? <div className="shrink-0">{action}</div> : null}
    </header>
  );
}

type MetricItem = {
  detail?: ReactNode;
  label: ReactNode;
  tone?: Tone;
  value: ReactNode;
};

type MetricGridProps = HTMLAttributes<HTMLDivElement> & {
  metrics?: MetricItem[];
};

export function MetricGrid({
  children,
  className,
  metrics,
  ...props
}: MetricGridProps) {
  return (
    <div
      className={cn("grid grid-cols-3 gap-2", className)}
      {...props}
    >
      {metrics?.map((metric, index) => (
        <div
          className={cn(
            "min-w-0 rounded-md p-3",
            metric.tone ? metricTones[metric.tone] : metricTones.neutral,
          )}
          key={`${String(metric.label)}-${index}`}
        >
          <div className="text-xs font-medium leading-4 text-slate-600">
            {metric.label}
          </div>
          <div className="mt-1 truncate text-xl font-semibold leading-7 text-slate-950">
            {metric.value}
          </div>
          {metric.detail ? (
            <div className="mt-1 text-xs leading-4 text-slate-500">
              {metric.detail}
            </div>
          ) : null}
        </div>
      ))}
      {children}
    </div>
  );
}

type ProgressStep = {
  description?: ReactNode;
  label: ReactNode;
  status?: "complete" | "current" | "pending";
};

type ProgressRailProps = HTMLAttributes<HTMLOListElement> & {
  steps: ProgressStep[];
};

export function ProgressRail({
  className,
  steps,
  ...props
}: ProgressRailProps) {
  return (
    <ol className={cn("space-y-3", className)} {...props}>
      {steps.map((step, index) => {
        const status = step.status ?? "pending";
        const isComplete = status === "complete";
        const isCurrent = status === "current";

        return (
          <li
            aria-current={isCurrent ? "step" : undefined}
            className="grid grid-cols-[1.5rem_1fr] gap-3"
            key={index}
          >
            <div className="flex flex-col items-center">
              <span
                aria-hidden="true"
                className={cn(
                  "mt-0.5 size-3 rounded-full ring-4",
                  isComplete && "bg-emerald-600 ring-emerald-100",
                  isCurrent && "bg-blue-700 ring-blue-100",
                  !isComplete && !isCurrent && "bg-slate-300 ring-slate-100",
                )}
              />
              {index < steps.length - 1 ? (
                <span
                  aria-hidden="true"
                  className="mt-2 h-full min-h-6 w-px bg-slate-200"
                />
              ) : null}
            </div>
            <div className="min-w-0 pb-1">
              <p className="text-sm font-semibold leading-5 text-slate-950">
                {step.label}
              </p>
              {step.description ? (
                <p className="text-sm leading-5 text-slate-600">
                  {step.description}
                </p>
              ) : null}
            </div>
          </li>
        );
      })}
    </ol>
  );
}

type MaterialRowProps = HTMLAttributes<HTMLDivElement> & {
  confidence?: number;
  evidence?: ReactNode;
  name: ReactNode;
  status?: ReactNode;
  statusTone?: Tone;
};

export function MaterialRow({
  className,
  confidence,
  evidence,
  name,
  status,
  statusTone = "amber",
  ...props
}: MaterialRowProps) {
  const confidencePercent =
    typeof confidence === "number"
      ? Math.max(0, Math.min(100, confidence > 1 ? confidence : confidence * 100))
      : null;
  const confidenceLabel =
    confidencePercent === null ? null : `${Math.round(confidencePercent)}%`;
  const confidenceTone =
    confidencePercent !== null && confidencePercent < 80 ? "amber" : "blue";

  return (
    <div
      className={cn(
        "flex min-h-16 items-center justify-between gap-3 border-b border-slate-200 py-3 last:border-b-0",
        className,
      )}
      {...props}
    >
      <div className="min-w-0">
        <p className="truncate text-sm font-semibold text-slate-950">{name}</p>
        {evidence ? (
          <p className="mt-1 line-clamp-2 text-sm leading-5 text-slate-600">
            {evidence}
          </p>
        ) : null}
      </div>
      <div className="flex shrink-0 items-center gap-2">
        {confidenceLabel ? (
          <Badge tone={confidenceTone}>{confidenceLabel}</Badge>
        ) : null}
        {status ? <Badge tone={statusTone}>{status}</Badge> : null}
      </div>
    </div>
  );
}

type PillButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  active?: boolean;
  variant?: "primary" | "secondary";
};

export function PillButton({
  active = false,
  children,
  className,
  type = "button",
  variant = "secondary",
  ...props
}: PillButtonProps) {
  const isPrimary = variant === "primary";

  return (
    <button
      className={cn(
        "inline-flex h-11 max-w-full items-center justify-center rounded-full px-4 text-sm font-semibold leading-none transition-colors disabled:cursor-not-allowed disabled:opacity-60",
        "focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700",
        isPrimary && "bg-slate-950 text-white hover:bg-slate-800",
        !isPrimary &&
          "border border-slate-300 bg-white text-slate-800 hover:bg-slate-50",
        active && !isPrimary && "border-blue-700 bg-blue-50 text-blue-800",
        className,
      )}
      type={type}
      {...props}
    >
      <span className="min-w-0 truncate">{children}</span>
    </button>
  );
}

type SafetyCalloutProps = HTMLAttributes<HTMLElement> & {
  items?: ReactNode[];
  title?: ReactNode;
  tone?: Tone;
};

export function SafetyCallout({
  children,
  className,
  items,
  title = "Safety check",
  tone = "amber",
  ...props
}: SafetyCalloutProps) {
  return (
    <aside
      className={cn(
        "rounded-lg border p-4 text-sm leading-5",
        calloutTones[tone],
        className,
      )}
      {...props}
    >
      <p className="font-semibold">{title}</p>
      {children ? <div className="mt-1 text-current">{children}</div> : null}
      {items?.length ? (
        <ul className="mt-3 space-y-2">
          {items.map((item, index) => (
            <li className="flex gap-2" key={index}>
              <span
                aria-hidden="true"
                className="mt-2 size-1.5 rounded-full bg-current"
              />
              <span className="min-w-0">{item}</span>
            </li>
          ))}
        </ul>
      ) : null}
    </aside>
  );
}
