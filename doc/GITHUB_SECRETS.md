# GitHub Secrets Configuration for Auto-Deployment

このドキュメントでは、GitHub Actionsによる自動デプロイに必要な環境変数（Secrets）をリストアップしています。
これらのSecretsは、GitHubリポジトリの Settings > Secrets and variables > Actions で設定する必要があります。

**注意**: `.kamal/secrets` は環境変数を使用する設定になっています。ローカル開発でも環境変数を設定してください（例: `.env` ファイルや `direnv` を使用）。

## 必須のSecrets

### 1. RAILS_MASTER_KEY
- **説明**: Railsのマスターキー。暗号化されたクレデンシャルを復号化するために使用されます。
- **取得方法**: `config/master.key` ファイルの内容、または新規作成する場合は `rails credentials:edit` を実行してキーを取得
- **例**: `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6`

### 2. SSH_PRIVATE_KEY
- **説明**: デプロイ先サーバー (153.127.39.185) にSSH接続するための秘密鍵
- **取得方法**: 
  - ローカルで使用しているSSH秘密鍵 (通常は `~/.ssh/id_rsa` または `~/.ssh/id_ed25519`)
  - または新規に生成: `ssh-keygen -t ed25519 -C "github-actions-deploy"`
  - 公開鍵をデプロイ先サーバーの `~/.ssh/authorized_keys` に追加する必要があります
- **形式**: 秘密鍵ファイル全体（`-----BEGIN ... PRIVATE KEY-----` から `-----END ... PRIVATE KEY-----` まで）
- **注意**: 秘密鍵は改行を含む複数行のテキストです。GitHubのSecretsに貼り付ける際はそのままコピーしてください。

## セットアップ手順

1. GitHubリポジトリページにアクセス
2. Settings > Secrets and variables > Actions に移動
3. "New repository secret" をクリック
4. 上記の各Secretを名前と値を入力して追加

## トラブルシューティング

### デプロイが失敗する場合

1. **SSH接続エラー**
   - `SSH_PRIVATE_KEY` が正しく設定されているか確認
   - デプロイ先サーバーに公開鍵が登録されているか確認
   - サーバーのIPアドレス (153.127.39.185) が正しいか確認

2. **Rails Master Key エラー**
   - `RAILS_MASTER_KEY` が正しく設定されているか確認
   - キーが `config/master.key` の内容と一致しているか確認

## ワークフローの動作

1. `main` ブランチにプッシュされると自動的にトリガーされます
2. まず、テストジョブが実行されます（RSpec）
3. テストが成功した場合のみ、デプロイジョブが実行されます
4. デプロイは `bundle exec kamal deploy` コマンドで実行されます

## 参考

- ワークフローファイル: `.github/workflows/ci.yml`
- Kamal設定ファイル: `config/deploy.yml`
- Kamalシークレット設定: `.kamal/secrets`

