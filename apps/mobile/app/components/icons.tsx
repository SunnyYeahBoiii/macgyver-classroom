import type { ReactNode, SVGProps } from "react";

export type IconProps = SVGProps<SVGSVGElement>;

function SvgIcon({
  children,
  className,
  ...props
}: IconProps & { children: ReactNode }) {
  return (
    <svg
      {...props}
      aria-hidden="true"
      className={className}
      fill="none"
      focusable="false"
      stroke="currentColor"
      strokeLinecap="round"
      strokeLinejoin="round"
      strokeWidth={1.8}
      viewBox="0 0 24 24"
    >
      {children}
    </svg>
  );
}

export function HomeIcon(props: IconProps) {
  return (
    <SvgIcon {...props}>
      <path d="m3.75 10.5 8.25-7 8.25 7" />
      <path d="M5.75 9.25v10.5h4.5v-6h3.5v6h4.5V9.25" />
    </SvgIcon>
  );
}

export function CameraIcon(props: IconProps) {
  return (
    <SvgIcon {...props}>
      <path d="M4.5 8.25a2 2 0 0 1 2-2h2l1.5-2h4l1.5 2h2a2 2 0 0 1 2 2v9.25a2 2 0 0 1-2 2h-11a2 2 0 0 1-2-2Z" />
      <circle cx="12" cy="13" r="3.25" />
    </SvgIcon>
  );
}

export function SparkIcon(props: IconProps) {
  return (
    <SvgIcon {...props}>
      <path d="m12 3.5 1.85 5.15L19 10.5l-5.15 1.85L12 17.5l-1.85-5.15L5 10.5l5.15-1.85Z" />
      <path d="m5.5 15.5.7 1.8 1.8.7-1.8.7-.7 1.8-.7-1.8-1.8-.7 1.8-.7Z" />
      <path d="m18 4 .5 1.25L19.75 6l-1.25.5L18 7.75l-.5-1.25L16.25 6l1.25-.75Z" />
    </SvgIcon>
  );
}

export function BookIcon(props: IconProps) {
  return (
    <SvgIcon {...props}>
      <path d="M5.75 4.25h7a2.5 2.5 0 0 1 2.5 2.5v13h-7a2.5 2.5 0 0 0-2.5 2.5Z" />
      <path d="M18.25 4.25h-3a2.5 2.5 0 0 0-2.5 2.5v13h5.5Z" />
      <path d="M8.25 8.25h3.25" />
      <path d="M8.25 11.25h3.25" />
    </SvgIcon>
  );
}

export function UserIcon(props: IconProps) {
  return (
    <SvgIcon {...props}>
      <circle cx="12" cy="8" r="3.5" />
      <path d="M5.25 20.25a6.75 6.75 0 0 1 13.5 0" />
    </SvgIcon>
  );
}

export function ShieldIcon(props: IconProps) {
  return (
    <SvgIcon {...props}>
      <path d="M12 3.5 19 6v5.25c0 4.25-2.75 7.5-7 9.25-4.25-1.75-7-5-7-9.25V6Z" />
      <path d="m8.75 12 2.25 2.25 4.5-5" />
    </SvgIcon>
  );
}

export function ChevronLeftIcon(props: IconProps) {
  return (
    <SvgIcon {...props}>
      <path d="m15 18-6-6 6-6" />
    </SvgIcon>
  );
}

export function CheckIcon(props: IconProps) {
  return (
    <SvgIcon {...props}>
      <path d="m5 12.5 4.25 4.25L19 7" />
    </SvgIcon>
  );
}

export function AlertIcon(props: IconProps) {
  return (
    <SvgIcon {...props}>
      <path d="M11.25 4.75a.85.85 0 0 1 1.5 0l8 14a.85.85 0 0 1-.75 1.25H4a.85.85 0 0 1-.75-1.25Z" />
      <path d="M12 9v4" />
      <path d="M12 17h.01" />
    </SvgIcon>
  );
}

export function SearchIcon(props: IconProps) {
  return (
    <SvgIcon {...props}>
      <circle cx="10.75" cy="10.75" r="6" />
      <path d="m15.25 15.25 4.5 4.5" />
    </SvgIcon>
  );
}
