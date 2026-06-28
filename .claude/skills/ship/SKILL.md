---
name: ship
description: 変更をブランチ→コミット→PR の流れで仕上げ、PRを「意思決定ログ」として作成する。ユーザーはレビューしてMergeするだけ。「PR出して」「リリースして」「ship」などのときに使う。
---

# ship — PR を意思決定ログにする出荷フロー

このリポジトリの運用方針:

> **conventional commit（日本語）でコミット → PR を意思決定のログとして活用 → ユーザーは受け入れ・確認するだけ → Merge されると本番デプロイ。**

`main` への直接コミットはしない。変更は必ず PR を経由させる。

## フロー

1. **ブランチ**: `main` にいるなら作業ブランチを切る。命名は `type/簡潔な内容`（例 `feat/app-store-apps`）。
2. **コミット**: [/commit](../commit/SKILL.md) に従い、論理単位で日本語 Conventional Commits。
3. **E2E＋スクショ**: UI/コンテンツに影響があるなら [/e2e](../e2e/SKILL.md) を実行し、PC/スマホのスクショを目視確認。スクショは `e2e/screenshots/` に出力され**リポジトリに追跡される**ので、`git add e2e/screenshots && git commit` で `docs(e2e): スクショを更新` などとしてコミットする（生成物なので本体変更とは別コミット推奨）。
4. **プッシュ**: `git push -u origin <branch>`。
5. **PR 作成**: 下記テンプレで本文を書き、`gh pr create` で作成する。スクショは PR の **Files changed タブに画像差分として表示**されるほか、本文にも raw リンクで載せる。
6. **確認の引き渡し**: PR の URL を伝える。**Merge はユーザーが行う**（受け入れ確認）。マージで本番（Vercel）が更新される。

> スクショは GitHub Actions ではなく **Claude Code（このフロー）が生成・コミット**する方針（CI 消費を避けるため）。CI の E2E は手動実行のみの検証用。

## PR 本文テンプレ（意思決定ログ）

PR 本文は後から読んで「なぜこうしたか」が分かる記録にする。Markdown ファイルに書いて `gh pr create --body-file` で渡すと崩れない。

```markdown
## 背景 / なぜ
<!-- 何を解決する変更か。きっかけ・課題 -->

## 変更点
<!-- 箇条書き。コミット単位と対応させると読みやすい -->

## 意思決定 / 検討した代替案
<!-- なぜこの実装にしたか。採らなかった選択肢と理由。後で迷わないための記録 -->

## 確認方法
<!-- 動作確認の手順。E2E を回した場合はその旨 -->
- [ ] `pnpm build` 成功
- [ ] `pnpm e2e`（PC/スマホ）パス

## スクリーンショット
<!-- e2e/screenshots/ にコミット済み。Files changed でも見られるが、本文にも raw で載せる。
     <branch> は PR のブランチ名。Merge 後は main 上の同パスに残る。 -->
### 💻 PC
<img src="https://raw.githubusercontent.com/<owner>/<repo>/<branch>/e2e/screenshots/pc/home.png" width="640">

### 📱 スマホ
<img src="https://raw.githubusercontent.com/<owner>/<repo>/<branch>/e2e/screenshots/mobile/home.png" width="300">

## デプロイ / ロールバック
<!-- Merge で本番反映。問題時は revert PR で戻す -->
```

PR 本文の末尾には次の行を付ける:

```
🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

## gh コマンド例

```bash
git push -u origin feat/app-store-apps
gh pr create --base main --title "feat: App Storeアプリを追加" --body-file /tmp/pr-body.md
gh pr view --web   # ユーザーに見せる
```

## デプロイについて

- `main` への Merge で本番（szkyudi.com）に **Vercel の Git 連携**で反映される。リポジトリ内にデプロイ設定ファイルは無い（Vercel ダッシュボード側設定）。
- パッケージマネージャは **pnpm**。`package-lock.json` を増やさないこと（lockfile 二重持ちで Vercel プレビュービルドが壊れる）。
- CI（`.github/workflows/e2e.yml`）は手動実行のみの E2E 検証用。
- 切り戻しは「revert PR を作って Merge」で行う（履歴を残すため force push しない）。
