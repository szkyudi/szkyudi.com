import { defineConfig, devices } from "@playwright/test";

/**
 * E2E 設定。
 * - `npm run build && npm run preview` で本番ビルドを配信し、それに対してテストする。
 * - PC とスマホ（モバイル）両方のビューポートでスクショを撮る。
 * - スクショは `e2e/screenshots/<viewport>/` に出力（CI が PR にインライン掲載する）。
 */
export default defineConfig({
  testDir: "./e2e",
  outputDir: "./e2e/.results",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  reporter: process.env.CI
    ? [["html", { open: "never" }], ["list"]]
    : [["list"]],
  use: {
    baseURL: "http://localhost:4321",
    trace: "on-first-retry",
  },
  projects: [
    {
      name: "pc",
      use: { ...devices["Desktop Chrome"], viewport: { width: 1280, height: 800 } },
    },
    {
      name: "mobile",
      // Chromium ベースのモバイル端末。ブラウザは chromium のみで完結させる。
      use: { ...devices["Pixel 5"] },
    },
  ],
  webServer: {
    command: "npm run build && npm run preview",
    url: "http://localhost:4321",
    reuseExistingServer: !process.env.CI,
    timeout: 120 * 1000,
  },
});
