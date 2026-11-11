# PokeClo

> 🇯🇵 **日本語をご希望の方へ:** 日本語版のREADMEは[このページの下部](#pokeclo-日本語)にあります。

PokeClo is a wardrobe management app that lets you photograph and catalog your clothing, combine pieces into outfits, and chat about your looks with an AI stylist.

## Features

- **Item catalog** — Upload photos of your clothes and tag each piece with a slot (outer, top, bottom, footwear), category, season, and rich descriptive metadata.
- **Outfit builder** — Combine items across slots into named outfits you can revisit and refine.
- **Outfit chat** — Each outfit has its own conversation thread for styling feedback, occasion suggestions, or "does this work?" second opinions.
- **Cloud image storage** — Photos are served through Cloudinary in development and production.
- **User accounts** — Authentication handled by Devise; every item and outfit belongs to a user.

## Tech Stack

- **Backend** — Ruby on Rails 8.1, PostgreSQL, Puma
- **Frontend** — Hotwire (Turbo + Stimulus), Bootstrap 5.3, Font Awesome, `simple_form`, Propshaft
- **Auth & Authorization** — Devise, Pundit
- **Storage** — Active Storage backed by Cloudinary
- **AI** — `ruby_llm` for the outfit chat feature
- **Infra** — Kamal for deployment, Solid Queue / Cache / Cable, Thruster

## Getting Started

### Prerequisites

- Ruby (see `.ruby-version`)
- PostgreSQL
- Node runtime (for importmap-managed assets)
- A Cloudinary account

### Setup

```bash
bundle install

# Configure environment
cp .env.example .env   # if present — otherwise create one
# Set CLOUDINARY_URL=cloudinary://<key>:<secret>@<cloud-name>

bin/rails db:create db:migrate db:seed
```

### Run

```bash
bin/dev
```

The app will be available at http://localhost:3000. The seed data creates a demo user (`demo@example.com` / `123123`) with a starter wardrobe. Seeding **deletes all existing data** first, so use it only in development (it refuses to run in production).

## Common Tasks

```bash
bin/rails test                          # run the full test suite
bin/rails test test/models/item_test.rb # run one file
bin/rails console                       # open a Rails console
bin/rubocop                             # lint
bin/brakeman                            # security scan
```

## Domain Model

```
User
 ├── has_many :items
 └── has_many :outfits

Item ── OutfitItem ── Outfit ── has_many :messages
```

`OutfitItem` is the join table between items and outfits and stores the slot the item occupies in that particular outfit. `Message` records the role/content of each turn in an outfit's chat thread.

## Credits

Generated from the [Le Wagon Rails template](https://github.com/lewagon/rails-templates).

---

# PokeClo (日本語)

PokeCloは、手持ちの服を撮影して登録し、アイテムを組み合わせてコーディネートを作成し、AIスタイリストとコーデについてチャットできるワードローブ管理アプリです。

## 機能

- **アイテムカタログ** — 服の写真をアップロードし、各アイテムにスロット(アウター、トップス、ボトムス、シューズ)、カテゴリー、シーズン、詳細なメタデータを設定できます。
- **コーデビルダー** — スロットごとにアイテムを組み合わせて名前付きのコーディネートを作成し、後から見直したり調整したりできます。
- **コーデチャット** — 各コーディネートに専用のチャットスレッドがあり、スタイリングのアドバイスやシーンに合わせた提案、「これって合ってる?」というセカンドオピニオンを得られます。
- **クラウド画像ストレージ** — 開発環境・本番環境ともに、写真はCloudinary経由で配信されます。
- **ユーザーアカウント** — 認証はDeviseで行い、すべてのアイテムとコーディネートはユーザーに紐づきます。

## 技術スタック

- **バックエンド** — Ruby on Rails 8.1、PostgreSQL、Puma
- **フロントエンド** — Hotwire(Turbo + Stimulus)、Bootstrap 5.3、Font Awesome、`simple_form`、Propshaft
- **認証・認可** — Devise、Pundit
- **ストレージ** — Cloudinaryをバックエンドとする Active Storage
- **AI** — コーデチャット機能に `ruby_llm` を使用
- **インフラ** — デプロイにKamal、Solid Queue / Cache / Cable、Thruster

## はじめに

### 前提条件

- Ruby(`.ruby-version` を参照)
- PostgreSQL
- Nodeランタイム(importmapで管理するアセット用)
- Cloudinaryアカウント

### セットアップ

```bash
bundle install

# 環境変数の設定
cp .env.example .env   # ファイルがある場合。ない場合は新規作成してください
# CLOUDINARY_URL=cloudinary://<key>:<secret>@<cloud-name> を設定

bin/rails db:create db:migrate db:seed
```

### 起動

```bash
bin/dev
```

アプリは http://localhost:3000 で利用できます。シードデータにより、初期ワードローブ付きのデモユーザー(`demo@example.com` / `123123`)が作成されます。シード処理は**既存のデータをすべて削除**してから実行されるため、開発環境でのみ使用してください(本番環境では実行されないようになっています)。

## よく使うコマンド

```bash
bin/rails test                          # テストスイート全体を実行
bin/rails test test/models/item_test.rb # 1ファイルのみ実行
bin/rails console                       # Railsコンソールを開く
bin/rubocop                             # Lint
bin/brakeman                            # セキュリティスキャン
```

## ドメインモデル

```
User
 ├── has_many :items
 └── has_many :outfits

Item ── OutfitItem ── Outfit ── has_many :messages
```

`OutfitItem` はアイテムとコーディネートの中間テーブルで、そのコーディネート内でアイテムが占めるスロットを保持します。`Message` はコーデチャットの各発言のロール(役割)と内容を記録します。

## クレジット

[Le Wagon Rails テンプレート](https://github.com/lewagon/rails-templates)をもとに生成されました。
