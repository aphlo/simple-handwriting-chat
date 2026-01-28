# Simple Handwriting Chat

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

<p align="center">
  <img src="web/src/app/icon.png" alt="App Icon" width="120" height="120">
</p>

<p align="center">
  シンプル筆談
</p>

<p align="center">
  <a href="https://apps.apple.com/us/app/simple-handwriting-chat/id6758146611">
    <img src="web/public/apple/ja.svg" alt="Download on the App Store" height="40">
  </a>
  <a href="https://play.google.com/store/apps/details?id=com.aphlo.simplehandwritingchat">
    <img src="web/public/google/ja.svg" alt="Google Playで手に入れよう" height="40">
  </a>
</p>

<p align="center">
  <a href="https://simple-handwriting-chat.web.app/">公式サイト</a>
</p>

## Overview

Flutter製のiOS/Androidアプリと、Next.js製のマーケティングWebサイトで構成されるモノレポです。

## Directory Structure

```
.
├── lib/                    # Flutter アプリ (Dart)
│   ├── main.dart           # エントリーポイント
│   ├── pages/              # 画面
│   │   ├── mirror_drawing_page.dart  # メイン描画画面
│   │   └── menu_page.dart            # メニュー画面
│   ├── painters/           # CustomPainter
│   │   └── mirror_painter.dart       # ミラー描画ロジック
│   ├── services/           # サービス層
│   │   ├── ad_service.dart           # 広告
│   │   └── review_service.dart       # アプリレビュー
│   └── l10n/               # 多言語化 (en/ja)
├── web/                    # Next.js Webサイト
│   ├── src/
│   │   ├── app/            # App Router (i18n対応)
│   │   ├── components/     # Reactコンポーネント
│   │   └── locales/        # 翻訳ファイル (en/ja)
│   └── public/             # 静的アセット
├── ios/                    # iOS固有設定
├── android/                # Android固有設定
└── test/                   # テスト
```

## Tech Stack

- **Mobile**: Flutter 3.38.6 (FVM)
- **Web**: Next.js (Static Export)
- **Backend**: Firebase (Hosting, Analytics)
- **Package Manager**: pnpm (Web)

## License

[MIT](LICENSE)
