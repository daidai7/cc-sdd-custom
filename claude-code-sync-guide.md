# Claude Code チャット履歴同期ガイド

> Syncthing を使って複数マシン間で Claude Code のチャット履歴を共有する方法

## 概要

Claude Code はチャット履歴を `~/.claude/projects/` に保存します。このガイドでは、Syncthing を使って複数マシン間でこの履歴を同期し、どのマシンからでも `--continue` / `--resume` でセッションを再開できるようにします。

### この方法のメリット

- ✅ チャット履歴が自動で共有される
- ✅ `claude --continue` / `claude --resume` が別マシンでも動作
- ✅ 「コンテキストを更新して」を忘れても履歴は残る
- ✅ cc-sdd-custom と併用可能

### 前提条件

- macOS または Linux（Windows WSL も可）
- 同期したいマシンが同じネットワーク上、または Syncthing リレー経由で接続可能

---

## 1. Syncthing のインストール

### macOS (Homebrew)

```bash
brew install syncthing

# バックグラウンドサービスとして起動
brew services start syncthing
```

### Ubuntu/Debian

```bash
sudo apt install syncthing

# ユーザーサービスとして起動
systemctl --user enable syncthing
systemctl --user start syncthing
```

### 確認

```bash
# Web UI にアクセス（ブラウザで開く）
open http://localhost:8384  # macOS
xdg-open http://localhost:8384  # Linux
```

---

## 2. 同期フォルダの準備

### 2.1 プライマリマシン（MacMini など）での設定

```bash
# 1. 同期用ディレクトリを作成
mkdir -p ~/Sync/claude-history

# 2. 既存の履歴を移動
mv ~/.claude/projects/* ~/Sync/claude-history/

# 3. シンボリックリンクを作成
rmdir ~/.claude/projects 2>/dev/null || rm ~/.claude/projects
ln -s ~/Sync/claude-history ~/.claude/projects

# 4. 確認
ls -la ~/.claude/
# projects -> /Users/yourname/Sync/claude-history
```

### 2.2 セカンダリマシン（MacBook など）での設定

```bash
# 1. 同期用ディレクトリを作成（Syncthing が同期してくれる）
mkdir -p ~/Sync/claude-history

# 2. 既存の projects ディレクトリをバックアップ・削除
mv ~/.claude/projects ~/.claude/projects.backup 2>/dev/null
rm -rf ~/.claude/projects

# 3. シンボリックリンクを作成
ln -s ~/Sync/claude-history ~/.claude/projects

# 4. 確認
ls -la ~/.claude/
```

---

## 3. Syncthing の設定

### 3.1 デバイスの追加

1. **両方のマシン** で Syncthing Web UI（http://localhost:8384）を開く
2. 右下の「デバイスID」をコピー
3. 相手のマシンの Web UI で「リモートデバイスを追加」→ デバイスID を貼り付け
4. 両方で承認

### 3.2 フォルダの共有

**プライマリマシン（MacMini）で：**

1. 「フォルダを追加」をクリック
2. 設定：
   - **フォルダラベル**: `claude-history`
   - **フォルダパス**: `~/Sync/claude-history`
   - **フォルダID**: `claude-history`（両マシンで同じにする）
3. 「共有」タブで、セカンダリマシンにチェック
4. 保存

**セカンダリマシン（MacBook）で：**

1. 共有リクエストが届くので「追加」
2. フォルダパスを `~/Sync/claude-history` に設定
3. 保存

### 3.3 同期の確認

```bash
# 両マシンで実行
ls ~/Sync/claude-history/

# 同じ内容が表示されればOK
```

---

## 4. プロジェクトパスの統一（重要）

Claude Code はプロジェクトのパスをキーとして履歴を管理します。
マシン間でパスが異なると、履歴が別々に保存されてしまいます。

### 4.1 推奨：同じパスを使う

```bash
# 両マシンで同じパスを使用
~/projects/some-project/
```

### 4.2 パスが異なる場合の対処

もしパスが異なる場合（例：MacMini は `/Users/username/`、MacBook は `/Users/name/`）：

```bash
# シンボリックリンクでパスを統一
# MacBook で
sudo mkdir -p /Users/username
sudo ln -s /Users/name/projects /Users/username/projects
```

または、ホームディレクトリからの相対パスを統一：

```bash
# 両マシンで ~/projects/ を使う
mkdir -p ~/projects
cd ~/projects
git clone <your-repo> some-project
```

### 4.3 パスエンコーディングの確認

Claude Code は `/Users/username/projects/some-project` を `-Users-username-projects-some-project` としてエンコードします。

```bash
# 現在のエンコードされたパスを確認
ls ~/Sync/claude-history/

# 出力例：
# -Users-username-projects-some-project/
```

---

## 5. 運用ガイドライン

### 5.1 同時編集の回避

**重要**: 同じプロジェクトで同時に Claude Code を使わないでください。

```
✅ MacMini で作業 → 終了 → MacBook で継続
❌ MacMini と MacBook で同時に作業（競合の原因）
```

### 5.2 セッション再開の方法

```bash
# 別マシンで前回の続きを再開
cd ~/projects/some-project
claude --continue

# または特定のセッションを選択
claude --resume
```

### 5.3 同期状態の確認

```bash
# Syncthing の同期状態を確認
# Web UI (http://localhost:8384) で「同期中」「最新」を確認

# または CLI で
syncthing cli show system
```

### 5.4 cc-sdd-custom との併用

```
claude-history 同期: 全チャット履歴（自動）
      ↓
cc-sdd-custom: 重要な決定事項のサマリー（明示的に記録）
      ↓
Git: 仕様書・設計書（コードと一緒に管理）
```

**使い分け**：
- 日常の作業継続 → `claude --continue`（同期された履歴を使用）
- 重要な決定の明文化 → 「コンテキストを更新して」（session-*.md に記録）
- 長期的な仕様管理 → requirements.md, design.md（Git 管理）

---

## 6. VS Code 拡張機能での使い方

VS Code の Claude Code 拡張機能は CLI と **同じ履歴ファイル（`~/.claude/`）を使用** します。
Syncthing で同期すれば、VS Code の「Past Conversations」でも別マシンのセッションが表示されます。

### 6.1 Past Conversations での確認

1. VS Code で Claude Code パネルを開く
2. 上部の時計アイコン（History）をクリック
3. 同期されたセッションが一覧に表示される

```
Past Conversations
├── some-project - Data Integration Design (2025-12-24)  ← MacMini で作成
├── some-project - Requirements Review (2025-12-23)
└── ...
```

### 6.2 セッションの再開方法

**方法1: Past Conversations から選択**
1. History アイコンをクリック
2. 再開したいセッションをクリック
3. 続きから会話開始

**方法2: コマンドパレットから**
1. `Cmd+Shift+P`（Mac）/ `Ctrl+Shift+P`（Windows/Linux）
2. 「Claude Code: Resume Conversation」を選択
3. セッションを選択

**方法3: ターミナルから（CLI）**
```bash
cd ~/projects/some-project
claude --resume
```

### 6.3 同期の確認方法

VS Code で同期が正しく動作しているか確認：

```bash
# 1. 別マシンでセッションを作成後、Syncthing の同期完了を待つ

# 2. VS Code を再起動（または Claude Code パネルをリロード）

# 3. Past Conversations に新しいセッションが表示されることを確認
```

### 6.4 SSH リモート開発時の注意

⚠️ **SSH 経由で VS Code を使う場合の制限**

SSH Remote 経由で VS Code を使用すると、履歴が正しく保存されない問題が報告されています（[Issue #9258](https://github.com/anthropics/claude-code/issues/9258)）。

**回避策**:
- ローカルの VS Code で作業する
- SSH 経由の場合は CLI（`claude` コマンド）を使用する
- 重要なセッションは cc-sdd-custom のセッションログに明示的に記録する

---

## 7. トラブルシューティング

### 7.1 `--continue` で「セッションが見つからない」

```bash
# 1. 同期が完了しているか確認
ls ~/Sync/claude-history/

# 2. シンボリックリンクが正しいか確認
ls -la ~/.claude/projects

# 3. パスエンコーディングが一致しているか確認
ls ~/Sync/claude-history/ | grep some-project
```

### 7.2 同期の競合が発生した場合

```bash
# 競合ファイル（.sync-conflict-*）を確認
find ~/Sync/claude-history -name "*.sync-conflict-*"

# 手動でマージするか、新しい方を採用
# 通常は新しい日付のファイルを残す
```

### 7.3 Syncthing が起動しない

```bash
# macOS
brew services restart syncthing

# Linux
systemctl --user restart syncthing

# ログを確認
syncthing --logfile=- 2>&1 | head -50
```

### 7.4 ディスク容量の確認

```bash
# Claude Code 履歴のサイズ確認
du -sh ~/Sync/claude-history/

# 古いセッションの削除（必要に応じて）
# 30日以上前のセッションを削除
find ~/Sync/claude-history -name "*.jsonl" -mtime +30 -delete
```

### 7.5 VS Code で Past Conversations が表示されない

```bash
# 1. VS Code を完全に再起動
# Command Palette → Developer: Reload Window

# 2. Claude Code 拡張機能のバージョン確認（最新版推奨）

# 3. シンボリックリンクが正しく設定されているか確認
ls -la ~/.claude/projects

# 4. 同期フォルダにセッションファイルがあるか確認
ls ~/Sync/claude-history/
```

---

## 8. セットアップチェックリスト

### プライマリマシン（MacMini）

- [ ] Syncthing インストール・起動
- [ ] `~/Sync/claude-history` 作成
- [ ] 既存履歴を移動
- [ ] `~/.claude/projects` → `~/Sync/claude-history` シンボリックリンク
- [ ] Syncthing でフォルダ共有設定

### セカンダリマシン（MacBook）

- [ ] Syncthing インストール・起動
- [ ] デバイス追加・承認
- [ ] 共有フォルダ追加
- [ ] `~/.claude/projects` → `~/Sync/claude-history` シンボリックリンク
- [ ] プロジェクトパスの統一

### 動作確認

- [ ] プライマリで Claude Code セッション実行
- [ ] セカンダリで `claude --continue` が動作
- [ ] Syncthing Web UI で「最新」表示
- [ ] VS Code の Past Conversations に両マシンのセッションが表示

---

## 9. 参考情報

- [Syncthing 公式ドキュメント](https://docs.syncthing.net/)
- [Claude Code ドキュメント](https://docs.anthropic.com/claude-code)
- [Claude Code VS Code 拡張機能](https://code.claude.com/docs/en/vs-code)
- [cc-sdd-custom](https://github.com/daidai7/cc-sdd-custom)

---

## 更新履歴

| 日付 | 内容 |
|------|------|
| 2025-12-25 | 初版作成 |
| 2025-12-25 | VS Code 拡張機能セクション追加 |

---
