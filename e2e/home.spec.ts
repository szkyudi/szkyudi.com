import { test, expect } from "@playwright/test";

/**
 * トップページ（プロフィール）の E2E。
 * 各ビューポート（pc / mobile）でフルページのスクショを
 * `e2e/screenshots/<viewport>/home.png` に保存する。
 */
test("トップページが表示され、各プロダクトが並ぶ", async ({ page }, testInfo) => {
  await page.goto("/");

  // タイトルとプロフィールの基本要素
  await expect(page).toHaveTitle(/すずきゆーだい/);
  await expect(page.getByRole("heading", { name: "すずきゆーだい", level: 1 })).toBeVisible();

  // プロダクト一覧（カード）が並んでいる
  const cards = page.locator(".card-list li");
  await expect(cards.first()).toBeVisible();
  expect(await cards.count()).toBeGreaterThanOrEqual(8);

  // App Store アプリが掲載されている
  await expect(page.getByText("ワリカンジ", { exact: true })).toBeVisible();
  await expect(page.getByText("みらいぼ", { exact: true })).toBeVisible();
  await expect(page.getByText("コーヒーノート", { exact: true })).toBeVisible();

  // フルページのスクショ（ビューポート別に保存）
  await page.screenshot({
    path: `e2e/screenshots/${testInfo.project.name}/home.png`,
    fullPage: true,
  });
});
