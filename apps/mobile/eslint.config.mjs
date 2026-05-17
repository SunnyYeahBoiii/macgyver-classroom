import { nextJsConfig } from "@repo/eslint-config/next-js";
import { globalIgnores } from "eslint/config";

export default [
  ...nextJsConfig,
  globalIgnores([
    "android/**",
    ".dart_tool/**",
    ".idea/**",
    "build/**",
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
