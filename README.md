# PokeClo

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

The app will be available at http://localhost:3000. The seed data creates a demo user (`glen@gmail.com` / `123123`) with a starter wardrobe.

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
