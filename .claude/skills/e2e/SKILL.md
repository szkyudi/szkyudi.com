---
name: e2e
description: Playwright で E2E テストを実行し、PC・スマホ両方のスクショを撮る。「E2E回して」「スクショ撮って」「変更が表示されてるか確認」などのときに使う。
---

# e2e — Playwright によるスクショ付き E2E

トップページに対して PC / スマホ両ビューポートで E2E を実行し、フルページのスクショを撮る。
ローカルでの目視確認と、PR に載せる証跡の両方に使う。

## 実行

```bash
pnpm e2e               # ビルド→preview→PC/スマホでテスト＆スクショ
pnpm e2e --project=pc       # PCのみ
pnpm e2e --project=mobile   # スマホのみ
pnpm e2e:report        # 直近のHTMLレポートを開く
```

- 初回や CI 環境ではブラウザの取得が必要: `pnpm exec playwright install chromium`
- `webServer` が `npm run build && npm run preview` を自動起動するので、事前のサーバ起動は不要。

## 出力

- スクショ: `e2e/screenshots/<pc|mobile>/home.png` … **リポジトリに追跡**する（PR の Files changed や本文リンクで確認するため）。UI 変更時はこれもコミットする。
- レポート: `playwright-report/`、中間生成物: `e2e/.results/`（いずれも gitignore 済み・コミットしない）

## 構成

- 設定: [playwright.config.ts](../../../playwright.config.ts) — `pc`(1280×800) と `mobile`(Pixel 5) の 2 プロジェクト。ブラウザは chromium のみ。
- テスト: [e2e/home.spec.ts](../../../e2e/home.spec.ts) — 表示・主要要素・プロダクトカードを検証し、フルページスクショを保存。

## 作業フローでの使いどころ

1. UI/コンテンツを変更したら `pnpm e2e` を実行して PC/スマホ両方で確認する。
2. スクショを `Read` で開いて目視確認する（崩れ・抜けがないか）。
3. 問題なければ `e2e/screenshots/` をコミットし、`/commit` → `/ship` へ。スクショは **PR の Files changed に画像として表示**され、本文にも raw リンクで載る（CI は使わず Claude Code が生成・コミットする）。手動で CI 検証したいときだけ [.github/workflows/e2e.yml](../../../.github/workflows/e2e.yml) を `workflow_dispatch` で回す。

## 拡張するとき

- ページや表示パターンが増えたら `e2e/*.spec.ts` にテストを足す。スクショは `e2e/screenshots/<project>/<name>.png` の規約で保存すれば、そのままコミットして PR / リポジトリで確認できる。
