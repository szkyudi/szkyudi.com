---
name: e2e
description: Playwright で E2E テストを実行し、PC・スマホ両方のスクショを撮る。「E2E回して」「スクショ撮って」「変更が表示されてるか確認」などのときに使う。
---

# e2e — Playwright によるスクショ付き E2E

トップページに対して PC / スマホ両ビューポートで E2E を実行し、フルページのスクショを撮る。
ローカルでの目視確認と、PR に載せる証跡の両方に使う。

## 実行

```bash
npm run e2e            # ビルド→preview→PC/スマホでテスト＆スクショ
npm run e2e -- --project=pc       # PCのみ
npm run e2e -- --project=mobile   # スマホのみ
npm run e2e:report     # 直近のHTMLレポートを開く
```

- 初回や CI 環境ではブラウザの取得が必要: `npx playwright install chromium`
- `webServer` が `npm run build && npm run preview` を自動起動するので、事前のサーバ起動は不要。

## 出力

- スクショ: `e2e/screenshots/<pc|mobile>/home.png`（gitignore 済み・コミットしない）
- レポート: `playwright-report/`、中間生成物: `e2e/.results/`（いずれも gitignore 済み）

## 構成

- 設定: [playwright.config.ts](../../../playwright.config.ts) — `pc`(1280×800) と `mobile`(Pixel 5) の 2 プロジェクト。ブラウザは chromium のみ。
- テスト: [e2e/home.spec.ts](../../../e2e/home.spec.ts) — 表示・主要要素・プロダクトカードを検証し、フルページスクショを保存。

## 作業フローでの使いどころ

1. UI/コンテンツを変更したら `npm run e2e` を実行して PC/スマホ両方で確認する。
2. スクショを `Read` で開いて目視確認する（崩れ・抜けがないか）。
3. 問題なければ `/commit` → `/ship` へ。PR では CI が同じ E2E を回し、**PC/スマホのスクショを PR コメントにインライン掲載**する（[.github/workflows/e2e.yml](../../../.github/workflows/e2e.yml)）。

## 拡張するとき

- ページや表示パターンが増えたら `e2e/*.spec.ts` にテストを足す。スクショは `e2e/screenshots/<project>/<name>.png` の規約で保存すると CI がそのまま拾って PR に載せる。
