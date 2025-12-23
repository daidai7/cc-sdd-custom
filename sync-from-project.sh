#!/bin/bash
# プロジェクトから cc-sdd-custom へワークフローを同期するスクリプト
#
# 使い方（プロジェクトディレクトリで実行）:
#   /path/to/cc-sdd-custom/sync-from-project.sh
#
# または環境変数で cc-sdd-custom のパスを指定:
#   CC_SDD_CUSTOM_DIR=/path/to/cc-sdd-custom ./sync-from-project.sh

set -e

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# cc-sdd-custom ディレクトリを取得
if [ -n "$CC_SDD_CUSTOM_DIR" ]; then
  CUSTOM_DIR="$CC_SDD_CUSTOM_DIR"
elif [ -n "${BASH_SOURCE[0]}" ]; then
  CUSTOM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  echo -e "${RED}❌ エラー: cc-sdd-custom ディレクトリが特定できません${NC}"
  echo "   CC_SDD_CUSTOM_DIR 環境変数を設定してください"
  exit 1
fi

# 現在のプロジェクト
PROJECT_DIR="$(pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"

echo -e "${BLUE}🔄 プロジェクトからワークフローを同期${NC}"
echo "   プロジェクト: $PROJECT_NAME"
echo "   cc-sdd-custom: $CUSTOM_DIR"
echo ""

# workflow.md の同期
SOURCE_WORKFLOW=".kiro/settings/templates/steering/workflow.md"
DEST_WORKFLOW="$CUSTOM_DIR/patches/workflow.md"

if [ -f "$SOURCE_WORKFLOW" ]; then
  # 差分を確認
  if [ -f "$DEST_WORKFLOW" ]; then
    if diff -q "$SOURCE_WORKFLOW" "$DEST_WORKFLOW" > /dev/null 2>&1; then
      echo -e "${YELLOW}⏭️  workflow.md に変更なし${NC}"
    else
      echo -e "${GREEN}📝 workflow.md を更新${NC}"
      echo ""
      echo "--- 差分 ---"
      diff "$DEST_WORKFLOW" "$SOURCE_WORKFLOW" || true
      echo "------------"
      echo ""
      read -p "更新しますか？ [y/N] " -n 1 -r
      echo ""
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp "$SOURCE_WORKFLOW" "$DEST_WORKFLOW"
        echo -e "${GREEN}✅ workflow.md を更新しました${NC}"
      else
        echo -e "${YELLOW}⏭️  スキップ${NC}"
      fi
    fi
  else
    echo -e "${GREEN}📝 workflow.md を新規作成${NC}"
    cp "$SOURCE_WORKFLOW" "$DEST_WORKFLOW"
    echo -e "${GREEN}✅ workflow.md を作成しました${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  $SOURCE_WORKFLOW が見つかりません${NC}"
fi

echo ""
echo -e "${GREEN}🎉 同期完了！${NC}"
echo ""
echo "次のステップ:"
echo "  cd $CUSTOM_DIR"
echo "  git add -A && git commit -m 'chore: $PROJECT_NAME からワークフロー同期'"
echo "  git push"
echo ""
