---
name: commit
description: 変更を Conventional Commits 準拠・日本語メッセージで、意味のある単位に分割してコミットする。「コミットして」「いい感じに分けてコミット」などのときに使う。
---

# commit — 日本語 Conventional Commits

変更を **Conventional Commits 準拠** かつ **日本語メッセージ** で、レビューしやすい論理単位に分割してコミットする。

## 手順

1. `git status` と `git diff`（ステージ前後両方）で変更全体を把握する。
2. 下記「分割の指針」で変更をグループ分けする。
3. グループごとに `git add <path>`（必要なら `git add -p` でハンク単位）→ コミット。
4. 各コミット後に、そのコミットだけでビルド/テストが壊れない順序になっているか意識する。

## メッセージ書式

```
<type>(<scope>): <概要を日本語で>

<本文：なぜこの変更が必要かを日本語で。任意>

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
```

- **概要**は日本語・簡潔に（句点なし、目安 50 字以内）。「〜を追加」「〜を修正」など。
- `scope` は変更箇所（例: `products`, `layout`, `e2e`, `ci`, `deps`）。不要なら省略可。
- 本文は「何を」ではなく「なぜ」を書く。コードを見れば分かることは書かない。
- 末尾に必ず `Co-Authored-By` トレーラーを付ける。

### type 一覧

| type | 用途 |
|------|------|
| `feat` | 機能・コンテンツの追加（プロダクトカード追加など） |
| `fix` | バグ修正 |
| `docs` | ドキュメントのみ（CLAUDE.md, README, スキル等） |
| `style` | 見た目・整形（ロジック非変更のCSS/フォーマット） |
| `refactor` | 挙動を変えないコード整理 |
| `perf` | パフォーマンス改善 |
| `test` | テストの追加・修正（E2E含む） |
| `build` | ビルド・依存（package.json, lockfile） |
| `ci` | CI 設定（.github/workflows） |
| `chore` | その他雑務（設定・ツール整備など） |

## 分割の指針（いい感じの区切り方）

**1 コミット = 1 つの目的**。レビュアー（このリポジトリでは本人）が「なぜ」を 1 行で言える粒度にする。

- **関心ごとで分ける**: サイトのコンテンツ変更 / ツール・設定整備 / ドキュメント はそれぞれ別コミット。
  - 例: 「アプリ追加(`feat`)」と「Playwright導入(`test`/`build`)」と「CLAUDE.md(`docs`)」は混ぜない。
- **依存とコードを分ける**: `package.json`/lockfile の依存追加(`build`)と、それを使うコード(`test`等)は分けてよい（ただし build が壊れない順序で）。
- **生成物・設定を分ける**: `.claude/`（スキル・ハーネス）や `.github/`（CI）は機能変更と別コミット。
- **リファクタと機能を混ぜない**: 整理(`refactor`)とふるまい変更(`feat`/`fix`)は別コミット。
- **巨大化させない**: 1 つの変更が複数ファイルに渡っても目的が同じなら 1 コミット。逆に 1 ファイルでも目的が違えば `git add -p` で分割。

### このリポジトリでの例

```
feat(products): App Storeアプリ（みらいぼ・コーヒーノート）を追加
test(e2e): PlaywrightでPC/スマホのスクショE2Eを追加
build(deps): @playwright/test を devDependency に追加
ci: PRでE2Eを実行しスクショをPRに掲載するワークフローを追加
chore(claude): コミット・PR・E2E運用のスキルとハーネスを整備
docs: CLAUDE.md を追加
```

## 注意

- `main` には直接コミットしない。作業はブランチで行い、PR にまとめる（`/ship` 参照）。
- ユーザーから明示の指示があるまで `git push` はしない。
