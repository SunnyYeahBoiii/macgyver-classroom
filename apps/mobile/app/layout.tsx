import type { Metadata } from "next";
import type { JSX, ReactNode } from "react";

import "./globals.css";

export const metadata: Metadata = {
  title: "MacGyver Classroom Mobile",
  description:
    "Mobile workflow for turning classroom objects into safe STEM lessons.",
};

export default function RootLayout(props: {
  children: ReactNode;
}): JSX.Element {
  return (
    <html lang="vi">
      <body>{props.children}</body>
    </html>
  );
}
