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
3. **E2E**: UI/コンテンツに影響があるなら [/e2e](../e2e/SKILL.md) を実行し、PC/スマホのスクショを目視確認。
4. **プッシュ**: `git push -u origin <branch>`。
5. **PR 作成**: 下記テンプレで本文を書き、`gh pr create` で作成する。
6. **確認の引き渡し**: PR の URL を伝える。**Merge はユーザーが行う**（受け入れ確認）。マージ後、CI が回り本番が更新される。

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
- [ ] `npm run build` 成功
- [ ] `npm run e2e`（PC/スマホ）パス

## スクリーンショット
<!-- CI(e2e.yml) が PC/スマホのスクショをこの PR にコメントで自動掲載する -->

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

- `main` への Merge で本番（szkyudi.com）に反映される想定（ホスティングの Git 連携）。
- リポジトリ内にデプロイ設定ファイルは無い。CI で動くのは E2E（`.github/workflows/e2e.yml`）のみ。
- 切り戻しは「revert PR を作って Merge」で行う（履歴を残すため force push しない）。
