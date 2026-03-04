require "open-uri"
# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Message.destroy_all
OutfitItem.destroy_all
Outfit.destroy_all
Item.destroy_all
User.destroy_all

ryota = User.create!(
  name: "Ryota Hayakawa",
  email: "r.hayakawasan@gmail.com",
  password: "yamatodamashi"
)

item1 = Item.new(
  user: ryota,
  name: "sports shirt",
  slot: "shirt",
  category: "sports",
  description: "A lightweight sports shirt",
  status: 1
)

item2 = Item.new(
  user: ryota,
  name: "sports pants",
  slot: "pants",
  category: "sports",
  description: "Comfortable sports pants",
  status: 1
)

item3 = Item.new(
  user: ryota,
  name: "sports shoes",
  slot: "shoes",
  category: "sports",
  description: "Durable sports shoes",
  status: 1
)

item4 = Item.new(
  user: ryota,
  name: "sports jacket",
  slot: "jacket",
  category: "sports",
  description: "A warm sports jacket",
  status: 1
)

file1 = URI.open("https://c.imgz.jp/265/98748265/98748265b_1_d_500.jpg")
item1.photo.attach(io: file1, filename: "#{item1.name}.png", content_type: "image/png")
item1.save

file2 = URI.open("https://c.imgz.jp/014/104681014/104681014_8_d_500.jpg")
item2.photo.attach(io: file2, filename: "#{item2.name}.png", content_type: "image/png")
item2.save

file3 = URI.open("https://c.imgz.jp/763/104136763/104136763b_1_d_500.jpg")
item3.photo.attach(io: file3, filename: "#{item3.name}.png", content_type: "image/png")
item3.save

file4 = URI.open("https://c.imgz.jp/662/101761662/101761662b_34_d_500.jpg")
item4.photo.attach(io: file4, filename: "#{item4.name}.png", content_type: "image/png")
item4.save

outfit = Outfit.create!(
  user: ryota,
  name: "festival outfit",
  description: "When you're at a festival and wanna stay cool while showing your furusato pride.",
  status: 1
)

OutfitItem.create!(
  item_id: item1.id,
  outfit_id: outfit.id,
  slot: item1.slot
)

Message.create!(
  outfit_id: outfit.id,
  role: "user",
  content: "Please create me an outfit that I can wear to the fire festival"
)
