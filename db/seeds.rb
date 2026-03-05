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
  slot: "top",
  category: "sports",
  description: "A lightweight sports shirt",
  status: 1
)

item2 = Item.new(
  user: ryota,
  name: "sports pants",
  slot: "bottom",
  category: "sports",
  description: "Comfortable sports pants",
  status: 1
)

item3 = Item.new(
  user: ryota,
  name: "sports shoes",
  slot: "footwear",
  category: "sports",
  description: "Durable sports shoes",
  status: 1
)

item4 = Item.new(
  user: ryota,
  name: "sports jacket",
  slot: "outer",
  category: "sports",
  description: "A warm sports jacket",
  status: 1
)

item5 = Item.new(
  user: ryota,
  name: "casual t-shirt",
  slot: "top",
  category: "casual",
  description: "A plain brown shirt",
  status: 1
)

item6 = Item.new(
  user: ryota,
  name: "polo t-shirt",
  slot: "top",
  category: "casual",
  description: "A navy blue polo shirt",
  status: 1
)

item7 = Item.new(
  user: ryota,
  name: "formal shirt",
  slot: "top",
  category: "formal",
  description: "A dark grey Zegna shirt",
  status: 1
)

item8 = Item.new(
  user: ryota,
  name: "formal shirt",
  slot: "top",
  category: "formal",
  description: "An offwhite Zegna linen shirt",
  status: 1
)

item9 = Item.new(
  user: ryota,
  name: "Jeans",
  slot: "bottom",
  category: "casual",
  description: "casual denim pants",
  status: 1
)

item10 = Item.new(
  user: ryota,
  name: "Linen Pants",
  slot: "bottom",
  category: "casual",
  description: "casual cream color linen pants",
  status: 1
)

item11 = Item.new(
  user: ryota,
  name: "Social Pants",
  slot: "bottom",
  category: "social",
  description: "formal dark grey pants",
  status: 1
)

item12 = Item.new(
  user: ryota,
  name: "Social Pants",
  slot: "bottom",
  category: "social",
  description: "formal light grey dress pants",
  status: 1
)

item13 = Item.new(
  user: ryota,
  name: "Casual Shoes",
  slot: "footwear",
  category: "casual",
  description: "white and black causal Onitsuka Tiger shoes",
  status: 1
)

item14 = Item.new(
  user: ryota,
  name: "Formal Shoes",
  slot: "footwear",
  category: "formal",
  description: "Black leather shoes",
  status: 1
)

item15 = Item.new(
  user: ryota,
  name: "Casual Loafer",
  slot: "footwear",
  category: "casual",
  description: "Brown suede Zegna loafers",
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

file5 = URI.open("https://www.theobsessor.com/content/images/2024/01/goods_422992_sub14-1.jpg")
item5.photo.attach(io: file5, filename: "#{item5.name}.png", content_type: "image/png")
item5.save

file6 = URI.open("https://static.lodenfrey.com/out/pictures/master/product/1/00700255-025_1.jpg")
item6.photo.attach(io: file6, filename: "#{item6.name}.png", content_type: "image/png")
item6.save

file7 = URI.open("https://productimage.zegna.com/is/image/zegna/601954A6-9MCZRM--F?wid=2250&hei=3000")
item7.photo.attach(io: file7, filename: "#{item7.name}.png", content_type: "image/png")
item7.save

file8 = URI.open("https://productimage.zegna.com/is/image/zegna/UCX31A6-SRO3-043-F?wid=2250&hei=3000")
item8.photo.attach(io: file8, filename: "#{item8.name}.png", content_type: "image/png")
item8.save

file9 = URI.open("https://www.westportbigandtall.com/cdn/shop/products/37147_STBL_Z_1000x.jpg?v=1769696217")
item9.photo.attach(io: file9, filename: "#{item9.name}.png", content_type: "image/png")
item9.save

file10 = URI.open("https://n.nordstrommedia.com/it/1ccfdd95-8aa5-441f-87e8-3f880894145e.jpeg?h=368&w=240&dpr=2")
item10.photo.attach(io: file10, filename: "#{item10.name}.png", content_type: "image/png")
item10.save

file11 = URI.open("https://cdn2.propercloth.com/pic_tccp/e5c4ad2fca14816702e193a8d16fa92e_size6.jpg")
item11.photo.attach(io: file11, filename: "#{item11.name}.png", content_type: "image/png")
item11.save

file12 = URI.open("https://www.bombayshirts.com/cdn/shop/files/Aurelia_800x.jpg?v=1727442801")
item12.photo.attach(io: file12, filename: "#{item12.name}.png", content_type: "image/png")
item12.save

file13 = URI.open("https://images.asics.com/is/image/asics/1183C429_100_SB_FR_GLB?qlt=80&wid=350&hei=300&bgc=255,255,255&resMode=bisharp")
item13.photo.attach(io: file13, filename: "#{item13.name}.png", content_type: "image/png")
item13.save

file14 = URI.open("https://www.zoomshoes.in/cdn/shop/files/28_2.jpg?v=1688447991&width=1200")
item14.photo.attach(io: file14, filename: "#{item14.name}.png", content_type: "image/png")
item14.save

file15 = URI.open("https://me.zegna.com/media/catalog/product/3/3/33638817-3_1.jpg")
item15.photo.attach(io: file15, filename: "#{item15.name}.png", content_type: "image/png")
item15.save

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

# this comment is just to make an edit

puts "#{User.count} users created"
puts "#{Item.count} items created"
puts "#{Outfit.count} outfits  created"
