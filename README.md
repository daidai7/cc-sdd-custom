# cc-sdd-custom

cc-sdd (Kiro-style Spec Driven Development) の個人カスタマイズ。

## 機能

### workflow.md テンプレート

セッション継続のためのワークフローを定義：

- **セッションログ**: `.kiro/context/session-YYYY-MM-DD.md`
- **合い言葉コマンド**:
  - 「コンテキストを更新して」→ 進捗をログに保存
  - 「これまでの経緯を読み込んで」→ 前回の続きから開始
- **出力言語ルール**: 日本語での出力

## 使い方

### 新規プロジェクトへの適用

```bash
# 1. cc-sdd をインストール（公式手順に従う）

# 2. カスタマイズを適用
curl -sL https://raw.githubusercontent.com/daidai7/cc-sdd-custom/main/apply.sh | bash

# 3. 開発開始
/kiro:steering
```

### ローカルから適用

```bash
# リポジトリをクローン
git clone https://github.com/daidai7/cc-sdd-custom.git ~/cc-sdd-custom

# プロジェクトディレクトリで実行
cd /path/to/your/project
~/cc-sdd-custom/apply.sh
```

### ワークフローの更新（プロジェクト → cc-sdd-custom）

プロジェクトでワークフローを改善した場合、cc-sdd-customに反映：

```bash
# プロジェクトディレクトリで実行
~/cc-sdd-custom/sync-from-project.sh

# cc-sdd-custom をプッシュ
cd ~/cc-sdd-custom
git add -A && git commit -m "chore: workflow更新"
git push
```

## ファイル構成

```
cc-sdd-custom/
├── README.md
├── claude-code-sync-guide.md # Claude Code チャット履歴同期ガイド
├── apply.sh                  # カスタマイズ適用スクリプト
├── sync-from-project.sh      # プロジェクトから同期するスクリプト
└── patches/                
    └── workflow.md           # steeringテンプレート
```

## ワークフロー図

```
┌─────────────────────────────────────────────────────────────┐
│                     新規プロジェクト                          │
├─────────────────────────────────────────────────────────────┤
│  1. cc-sdd インストール                                      │
│  2. curl ... | bash  (cc-sdd-custom適用)                    │
│  3. /kiro:steering  (workflow.md生成)                       │
│  4. 開発開始                                                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     開発サイクル                             │
├─────────────────────────────────────────────────────────────┤
│  セッション開始: 「これまでの経緯を読み込んで」               │
│       ↓                                                      │
│  開発作業                                                    │
│       ↓                                                      │
│  セッション終了: 「コンテキストを更新して」                   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ (ワークフロー改善時)
┌─────────────────────────────────────────────────────────────┐
│                   cc-sdd-custom 更新                         │
├─────────────────────────────────────────────────────────────┤
│  1. sync-from-project.sh  (差分確認・コピー)                 │
│  2. git push              (GitHubに反映)                     │
│  3. 他プロジェクトで apply.sh (最新を適用)                   │
└─────────────────────────────────────────────────────────────┘
```

## 今後の拡張予定

- [ ] 複数言語対応（英語版workflow.md）
- [ ] プロジェクトタイプ別テンプレート（Web, CLI, Library）
- [ ] カスタムスラッシュコマンドの追加
