# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

ryota = User.create!(
  name: "Ryota Hayakawa",
  email: "Hayakawasan@gmail.com",
  password: "yamatodamashi"
)

Item.create!(
  user: ryota,
  name: "Loincloth",
  slot: "underwear",
  category: "festival",
  status: 1
)

OutFitItem.create!(
  item_id: item.id,
  outfit_id: outfit.id,
  slot: "underwear"
)

Outfit.create!(
  name: "festival outfit",
  description: "When you're at a festival and wanna stay cool while showing your furusato pride.",
  status: 1
)

Message.create!(
  outfit_id: outfit.id,
  role: "user"
  content: "Please create me an outfit that I can wear to the fire festival"
)