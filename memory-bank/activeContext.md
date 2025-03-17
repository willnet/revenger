# アクティブコンテキスト

## 現在の作業の焦点
- CoffeeScriptからJavaScriptへの移行
- テスト環境の安定化
- VSCode devcontainerを活用した開発環境の標準化

## 最近の変更
### 2025/3/17
- すべてのCoffeeScriptファイルをJavaScriptに変換
  - `.coffee`ファイルから`.js`ファイルへの変換が完了
  - テストが失敗する問題が発生（hamlcoffeeの依存関係）

### 2025/3/14
- ChromeDriverのパス設定を修正
  - `spec_helper.rb`のChromeDriverのパスを`/usr/local/bin/chromedriver`から`/usr/bin/chromedriver`に変更
  - `config/initializers/webdrivers.rb`のChromeDriverのパスも同様に修正
  - これにより、Chromeを使用したテストが正常に実行できるようになった

## 現在の課題
- HAMLCoffeeテンプレート（`.hamlc`ファイル）の変換
- テスト実行時の`hamlcoffee`ライブラリが見つからないエラーの解決
- テスト環境の安定性確保
- JavaScriptテストの信頼性向上

## 次のステップ
- HAMLCoffeeテンプレートを別の形式に変換
- `application.js`の`require hamlcoffee`の依存関係を解決
- すべてのテストが正常に実行されることを確認
- CI環境でのテスト実行の安定性確保

## アクティブな決定事項
- Dockerコンテナ内でのテスト実行時は、`RAILS_ENV=test`を明示的に設定する
- ChromeDriverは`/usr/bin/chromedriver`にインストールされていることを前提とする
- Chromiumは`/usr/bin/chromium`にインストールされていることを前提とする
- CoffeeScriptを完全に排除し、純粋なJavaScriptに移行する
- 開発はVSCode devcontainerを使用して行い、環境の一貫性を確保する
