# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Start development server
bin/dev

# Database
bin/rails db:create db:migrate
bin/rails db:seed

# Run all tests
bin/rails test

# Run a single test file
bin/rails test test/models/item_test.rb

# Run a specific test by line number
bin/rails test test/models/item_test.rb:15

# Rails console
bin/rails console

# Generate migration
bin/rails generate migration AddFieldToTable field:type

# Linting
bin/rubocop

# Security scan
bin/brakeman
```

## Architecture

**PokeClo** is a clothing/outfit management Rails 8.1 app built on the [Le Wagon Rails template](https://github.com/lewagon/rails-templates). Users manage wardrobe items, combine them into outfits, and can chat about outfits (Message model supports AI conversation patterns).

### Authentication

`ApplicationController` enforces `before_action :authenticate_user!` globally via Devise. Public actions must explicitly call `skip_before_action :authenticate_user!`.

### Domain Model

```
User
 ├── has_many :items
 └── has_many :outfits

Item (belongs_to :user)
 ├── has_many :outfit_items (dependent: :destroy)
 ├── has_many :outfits (through: :outfit_items)
 └── has_one_attached :photo  ← Active Storage / Cloudinary

Outfit (belongs_to :user)
 ├── has_many :outfit_items
 ├── has_many :items (through: :outfit_items)
 └── has_many :messages

OutfitItem (join table: Item ↔ Outfit, stores slot string)

Message (belongs_to :outfit, role: 'user'|'assistant', content)
```

### Key Fields

- `Item.characteristics` — JSONB for flexible attributes (color, size, brand, etc.)
- `Item.slot` / `OutfitItem.slot` — clothing position (e.g., "top", "bottom", "shoes")
- `Item.status`, `Outfit.status` — integer enum columns (enum not yet defined in model)
- `Item.season` — optional string

### File Storage

Active Storage is configured with **Cloudinary** in development and production. Requires `CLOUDINARY_URL` in `.env`. Test environment uses local disk (`tmp/storage`).

### Frontend Stack

- Hotwire (Turbo + Stimulus) via importmap
- Bootstrap 5.3 + Font Awesome
- `simple_form` for form generation
- Propshaft asset pipeline

### Controllers Not Yet Created

Only `PagesController` (home page) and Devise controllers exist. No CRUD controllers for `Item`, `Outfit`, `OutfitItem`, or `Message` have been built yet.
