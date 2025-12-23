#!/bin/bash
# cc-sdd カスタマイズ適用スクリプト
#
# 使い方:
#   curl -sL https://raw.githubusercontent.com/daidai7/cc-sdd-custom/main/apply.sh | bash
#
# または:
#   git clone https://github.com/daidai7/cc-sdd-custom.git /tmp/cc-sdd-custom
#   /tmp/cc-sdd-custom/apply.sh
#
# 前提条件:
#   - cc-sdd が既にインストールされていること（.claude/commands/kiro/ が存在）

set -e

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# スクリプトのディレクトリを取得（ローカル実行時用）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# GitHub Raw URL（curl実行時用）
CUSTOM_REPO="https://raw.githubusercontent.com/daidai7/cc-sdd-custom/main"

echo "🔧 cc-sdd カスタマイズを適用中..."
echo ""

# 前提条件チェック
if [ ! -d ".claude/commands/kiro" ]; then
  echo -e "${RED}❌ エラー: cc-sdd がインストールされていません${NC}"
  echo "   .claude/commands/kiro/ が見つかりません"
  echo "   先に cc-sdd をインストールしてください"
  exit 1
fi

# workflow.md の取得元を決定
if [ -f "$SCRIPT_DIR/patches/workflow.md" ]; then
  WORKFLOW_SOURCE="$SCRIPT_DIR/patches/workflow.md"
  echo "📁 ローカルファイルを使用: $WORKFLOW_SOURCE"
else
  WORKFLOW_SOURCE="$CUSTOM_REPO/patches/workflow.md"
  echo "🌐 GitHubからダウンロード: $WORKFLOW_SOURCE"
fi

# 1. workflow.md テンプレートを追加
echo ""
echo "📝 workflow.md テンプレートを追加..."
mkdir -p .kiro/settings/templates/steering

if [ -f "$SCRIPT_DIR/patches/workflow.md" ]; then
  cp "$SCRIPT_DIR/patches/workflow.md" .kiro/settings/templates/steering/workflow.md
else
  curl -sL "$WORKFLOW_SOURCE" -o .kiro/settings/templates/steering/workflow.md
fi
echo -e "${GREEN}✅ .kiro/settings/templates/steering/workflow.md${NC}"

# 2. steering-principles.md にworkflow.mdを追記
PRINCIPLES=".kiro/settings/rules/steering-principles.md"
if [ -f "$PRINCIPLES" ]; then
  if grep -q "workflow.md" "$PRINCIPLES"; then
    echo -e "${YELLOW}⏭️  steering-principles.md は既に更新済み${NC}"
  else
    # macOS と Linux の両方に対応
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' 's/- \*\*structure.md\*\*:.*/&\
- **workflow.md**: Session continuation, magic commands, output language rules/' "$PRINCIPLES"
    else
      sed -i 's/- \*\*structure.md\*\*:.*/&\n- **workflow.md**: Session continuation, magic commands, output language rules/' "$PRINCIPLES"
    fi
    echo -e "${GREEN}✅ steering-principles.md 更新${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  $PRINCIPLES が見つかりません（スキップ）${NC}"
fi

# 3. steering.md コマンドを更新
STEERING_CMD=".claude/commands/kiro/steering.md"
if [ -f "$STEERING_CMD" ]; then
  if grep -q "workflow.md" "$STEERING_CMD"; then
    echo -e "${YELLOW}⏭️  steering.md コマンドは既に更新済み${NC}"
  else
    # macOS と Linux の両方に対応
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' 's/product.md, tech.md, structure.md)/product.md, tech.md, structure.md, workflow.md)/g' "$STEERING_CMD"
    else
      sed -i 's/product.md, tech.md, structure.md)/product.md, tech.md, structure.md, workflow.md)/g' "$STEERING_CMD"
    fi
    echo -e "${GREEN}✅ steering.md コマンド更新${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  $STEERING_CMD が見つかりません（スキップ）${NC}"
fi

# 4. .kiro/context/ ディレクトリを作成
if [ ! -d ".kiro/context" ]; then
  mkdir -p .kiro/context
  echo -e "${GREEN}✅ .kiro/context/ ディレクトリ作成${NC}"
else
  echo -e "${YELLOW}⏭️  .kiro/context/ は既に存在${NC}"
fi

# 5. .gitkeep を追加（空ディレクトリをgit管理するため）
if [ ! -f ".kiro/context/.gitkeep" ]; then
  touch .kiro/context/.gitkeep
  echo -e "${GREEN}✅ .kiro/context/.gitkeep 作成${NC}"
fi

echo ""
echo -e "${GREEN}🎉 カスタマイズ適用完了！${NC}"
echo ""
echo "次のステップ:"
echo "  1. /kiro:steering を実行 → workflow.md も生成されます"
echo "  2. 「これまでの経緯を読み込んで」で前回の続きから開始"
echo "  3. 「コンテキストを更新して」でセッション終了時に保存"
echo ""
