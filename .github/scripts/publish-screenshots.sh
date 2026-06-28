#!/usr/bin/env bash
#
# E2E のスクショを PR にインライン掲載する。
# - スクショ専用のオーファンブランチ `e2e-screenshots` に push（外部ホスト不要）
# - raw.githubusercontent の URL を埋め込んだ PR コメントを upsert（同一 PR では更新）
#
# 想定: 同一リポジトリのブランチからの PR（GITHUB_TOKEN に write 権限があること）。
set -euo pipefail

SRC="e2e/screenshots"
BRANCH="e2e-screenshots"
MARKER="<!-- e2e-screenshots -->"

if [ ! -d "$SRC" ] || [ -z "$(find "$SRC" -name '*.png' -print -quit)" ]; then
  echo "スクショが無いためスキップします。"
  exit 0
fi

SHORT_SHA="${SHA:0:7}"
DEST_DIR="pr-${PR}/${SHA}"
TMP="$(mktemp -d)"

git config --global user.name "github-actions[bot]"
git config --global user.email "41898282+github-actions[bot]@users.noreply.github.com"

# オーファンブランチの作業ツリーを用意（既存なら引き継ぐ）
git fetch origin "$BRANCH" --depth=1 || true
if git show-ref --verify --quiet "refs/remotes/origin/$BRANCH"; then
  git worktree add "$TMP" "origin/$BRANCH"
  git -C "$TMP" checkout -B "$BRANCH"
else
  git worktree add --detach "$TMP"
  git -C "$TMP" checkout --orphan "$BRANCH"
  git -C "$TMP" rm -rf . >/dev/null 2>&1 || true
fi

mkdir -p "$TMP/$DEST_DIR"
cp -R "$SRC/." "$TMP/$DEST_DIR/"

git -C "$TMP" add -A
git -C "$TMP" commit -m "ci: PR #${PR} のE2Eスクショ (${SHORT_SHA})" >/dev/null 2>&1 || {
  echo "差分なし。コメントのみ更新します。"
}
git -C "$TMP" push origin "$BRANCH"

# PR コメント本文を生成
BODY_FILE="$TMP/comment.md"
{
  echo "$MARKER"
  echo "## 🖼️ E2E スクリーンショット"
  echo
  echo "コミット \`${SHORT_SHA}\` 時点のトップページ表示です（E2E: 自動キャプチャ）。"

  for vp in pc mobile; do
    dir="$SRC/$vp"
    [ -d "$dir" ] || continue
    if [ "$vp" = "pc" ]; then
      label="💻 PC"
      width=640
    else
      label="📱 スマホ"
      width=300
    fi
    echo
    echo "### $label"
    echo
    for f in "$dir"/*.png; do
      [ -e "$f" ] || continue
      name="$(basename "$f")"
      url="https://raw.githubusercontent.com/${REPO}/${BRANCH}/${DEST_DIR}/${vp}/${name}"
      echo "<img src=\"${url}\" width=\"${width}\" alt=\"${vp}/${name}\"><br>"
    done
  done
} >"$BODY_FILE"

# 既存のスクショコメントがあれば更新、無ければ新規作成（sticky）
EXISTING="$(gh api "repos/${REPO}/issues/${PR}/comments" --paginate \
  --jq ".[] | select(.body | contains(\"${MARKER}\")) | .id" | head -n1 || true)"

if [ -n "$EXISTING" ]; then
  gh api -X PATCH "repos/${REPO}/issues/comments/${EXISTING}" -F body=@"$BODY_FILE" >/dev/null
  echo "コメントを更新しました (id=${EXISTING})。"
else
  gh api -X POST "repos/${REPO}/issues/${PR}/comments" -F body=@"$BODY_FILE" >/dev/null
  echo "コメントを新規作成しました。"
fi
