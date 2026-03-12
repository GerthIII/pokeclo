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

glen = User.create!(
  name: "Glen Gerth",
  email: "glen@gmail.com",
  password: "123123"
)

glen.profile_photo.attach(
  io: URI.open("https://res.cloudinary.com/dm1uny938/image/upload/v1773274251/Glen_m6f8bt.jpg"),
  filename: "Glen.jpeg",
  content_type: "image/jpeg"
)

# ITEMS

# Outers

item1 = Item.new(
  user: glen,
  name: "Black Utility Jacket",
  slot: "outer",
  category: "casual",
  description: "a black, zip-up utility jacket with a structured, technical aesthetic displayed against a neutral background. The design includes two prominent chest pockets with flap closures and a sharp, pointed collar that lends it a refined yet functional look. Its matte finish and clean silhouette suggest a versatile outerwear piece that bridges the gap between rugged workwear and modern streetwear.",
  status: 1
)

item2 = Item.new(
  user: glen,
  name: "Black Quilted Puffer Jacket",
  slot: "outer",
  category: "casual",
  description: "A black channel-quilted puffer jacket with a slightly structured moto-inspired silhouette, worn open by a male model over a bright red hoodie in an outdoor urban setting. The jacket features a bold asymmetric zip closure, a stand collar, multiple silver-tone zipper pockets across the chest and sides, and stitched quilting in a narrow vertical channel pattern that creates a sleek, non-bulky profile. The combination of technical quilting and edgy hardware gives this jacket a contemporary, street-ready aesthetic.",
  status: 1
)

item3 = Item.new(
  user: glen,
  name: "Light Jean Jacket",
  slot: "outer",
  category: "casual",
  description: "a classic light-wash denim jacket, which would be perfect for casual, layered outfits. It is made of sturdy, textured cotton denim in a soft, faded blue tone that gives it a well-worn, vintage look. The jacket has traditional styling with chest flap pockets that secure with shank buttons, along with a row of buttons down the front. The collar is a point collar, and the jacket is finished with prominent, contrast stitching along the seams for a timeless, rugged appearance.",
  status: 1
)

item4 = Item.new(
  user: glen,
  name: "Black Leather Jacket",
  slot: "outer",
  category: "casual",
  description: "classic black leather biker jacket serves as a bold fashion staple, featuring a sleek, semi-matte finish and a structured silhouette. The design is heavily detailed with polished silver hardware, including an asymmetrical front zipper, wide notched lapels with metallic snaps, and shoulder epaulets. Functional elements like the multiple zippered pockets and a small snap-flap coin pocket add both texture and utility to the piece. Finally, the look is anchored by a thick, integrated belt at the hem with a chunky metal buckle, reinforcing its iconic and rebellious aesthetic.",
  status: 1
)

file1 = URI.open("https://res.cloudinary.com/dm1uny938/image/upload/v1773272012/Black_Jacket_h2a9sr.png")
item1.photo.attach(io: file1, filename: "#{item1.name}.jpg", content_type: "image/jpeg")
item1.save # Black Utility Jacket

file2 = URI.open("https://res.cloudinary.com/dm1uny938/image/upload/v1773125970/61XUeKFhUqL._AC_UY1000__eaguoh.jpg")
item2.photo.attach(io: file2, filename: "#{item2.name}.jpg", content_type: "image/jpeg")
item2.save # Black Quilted Puffer Jacket

file3 = URI.open("https://res.cloudinary.com/dm1uny938/image/upload/v1773273631/13-2-jacket-transparent_j4lvxk.png")
item3.photo.attach(io: file3, filename: "#{item3.name}.jpg", content_type: "image/jpeg")
item3.save # Light Jean Jacket

file4 = URI.open("https://res.cloudinary.com/dm1uny938/image/upload/v1773312988/classic-black-leather-jacket-timeless-fashion-staple_191095-78120-Photoroom_mqq66l.png")
item4.photo.attach(io: file4, filename: "#{item4.name}.jpg", content_type: "image/jpeg")
item4.save # Black Leather Jacket

# Tops

item5 = Item.new(
  user: glen,
  name: "Cream Colored Shirt",
  slot: "top",
  category: "casual",
  description: "This cream-colored shirt features a refined, understated aesthetic that leans into a classic old money or minimalist style. It is crafted from a textured fabric, likely a linen or cotton blend, which gives the garment a rich, tactile appearance and a structured yet breathable feel. The design includes a sharp, standard collar and a clean button-down front, accented by subtle, tonal buttons that maintain its monochromatic look. With its relaxed fit and soft, off-white hue, this piece serves as a versatile wardrobe staple perfect for elevated casual wear or smart-casual layering.",
  status: 1
)

item6 = Item.new(
  user: glen,
  name: "Iron Maiden Shirt",
  slot: "top",
  category: "casual",
  description: "A classic Iron Maiden band tee features a bold and edgy aesthetic, centered around a large, vibrant graphic of the band's iconic mascot, Eddie. The artwork is intricately detailed, showcasing the character in a menacing pose against a dark, atmospheric background that captures the essence of heavy metal culture. Set on a high-quality black cotton fabric, the shirt provides a striking contrast that makes the colorful illustration and the bands signature logo pop. The garment is designed with a traditional crew neck and a relaxed fit, giving it an authentic vintage feel that is both comfortable and stylish. This t-shirt serves as a timeless piece of music memorabilia, perfect for fans looking to showcase their appreciation for the legendary band's legacy.",
  status: 1
)

item7 = Item.new(
  user: glen,
  name: "Circle Logo Tee",
  slot: "top",
  category: "casual",
  description: "A charcoal black graphic tee offers a modern, alternative aesthetic centered around a distinctive circular chest print. The design features a central black disc containing stylized, runic-inspired typography, surrounded by a textured, copper-colored ring that resembles aged metal or cork. Set against the faded, washed-out black fabric, the warm tones of the graphic provide a subtle yet eye-catching contrast. The shirt is constructed with a classic crew neck and a standard short-sleeve silhouette, suggesting a comfortable, everyday fit. Its minimalist approach to graphic design makes it a versatile piece that bridges the gap between band merchandise and contemporary streetwear.",
  status: 1
)

item8 = Item.new(
  user: glen,
  name: "White Long-Sleeve Shirt",
  slot: "top",
  category: "casual",
  description: "A crisp, white long-sleeved shirt laid flat against a minimalist gray background. The garment features a classic crew neck and ribbed cuffs, suggesting a comfortable, high-quality cotton or jersey blend. Its clean lines and bright, neutral tone make it a versatile staple piece, perfect for layering or wearing on its own for a minimalist look.",
  status: 1
)

item9 = Item.new(
  user: glen,
  name: "Black Long-Sleeved Shirt",
  slot: "outer",
  category: "casual",
  description: "a solid black long-sleeved shirt laid flat against a light gray backdrop. The garment is designed with a classic crew neckline and fitted cuffs, offering a sleek and cohesive monochromatic appearance. Its deep, uniform color and simple construction make it an essential foundational piece for a modern, understated wardrobe.",
  status: 1 # Move this to outer later
)

file5 = URI.open("https://res.cloudinary.com/dm1uny938/image/upload/v1773311914/cream-shirt_txej8k.jpg")
item5.photo.attach(io: file5, filename: "#{item5.name}.png", content_type: "image/png")
item5.save # Cream Colored Shirt

file6 = URI.open("https://res.cloudinary.com/dm1uny938/image/upload/v1773311918/iron-maiden-shirt_uzzfqg.jpg")
item6.photo.attach(io: file6, filename: "#{item6.name}.png", content_type: "image/png")
item6.save # Iron Maiden Shirt

file7 = URI.open("https://res.cloudinary.com/dm1uny938/image/upload/v1773271022/logo_tee_gvnhtr.png")
item7.photo.attach(io: file7, filename: "#{item7.name}.jpg", content_type: "image/jpeg")
item7.save # White Basic Tee

file8 = URI.open("https://res.cloudinary.com/dm1uny938/image/upload/v1773272024/white_longsleeve_vlzrbv.png")
item8.photo.attach(io: file8, filename: "#{item8.name}.jpg", content_type: "image/jpeg")
item8.save # White Long-Sleeve Shirt

file9 = URI.open("https://res.cloudinary.com/dm1uny938/image/upload/v1773272044/black_longsleeve_b0fzwb.png")
item9.photo.attach(io: file9, filename: "#{item9.name}.jpg", content_type: "image/jpeg")
item9.save # Black Long-Sleeved Shirt. Move this to outer later.

# Bottoms

item10 = Item.new(
  user: glen,
  name: "Jeans",
  slot: "bottom",
  category: "casual",
  description: "a pair of classic Levi Strauss & Co. blue jeans, presented in a folded flat-lay position against a clean white background. The denim has a medium-to-dark blue wash with subtle fading and vertical grain texture, suggesting a comfortable, broken-in feel. Key brand identifiers are visible, including the iconic tan Two Horse leather patch on the rear waistband and the signature Arcuate stitching on the back pocket. The construction details include contrasting orange topstitching, copper-tone rivets on the front coin and hip pockets, and a sturdy belt loop system, all characteristic of traditional American workwear-inspired style.",
  status: 1
)

item11 = Item.new(
  user: glen,
  name: "Dark Wash Denim Jeans",
  slot: "bottom",
  category: "casual",
  description: "a pair of dark wash denim jeans laid flat against a neutral gray background. The jeans feature a classic five-pocket design with visible orange contrast stitching and metallic rivets at the stress points. The fabric has a deep indigo hue with subtle fading along the thighs, suggesting a slightly broken-in look while maintaining a clean, structured aesthetic.",
  status: 1
)

item12 = Item.new(
  user: glen,
  name: "Jet-Black Trousers",
  slot: "bottom",
  category: "casual",
  description: "a pair of sleek, jet-black trousers presented against a solid light-gray backdrop. The pants feature a modern, slim-tapered cut with a smooth fabric finish that gives them a versatile, semi-formal appearance. Details like the clean waistband and structured seams suggest a polished design suitable for both professional settings and elevated casual wear.",
  status: 1
)

item13 = Item.new(
  user: glen,
  name: "Dark Indigo Raw Denim",
  slot: "bottom",
  category: "casual",
  description: "A pair of Acne Studios dark indigo raw selvedge denim jeans presented in a flat-lay product shot on a white, slightly wrinkled linen surface. The jeans are characterized by a very deep, almost charcoal-navy wash that retains the rigid, stiff quality of unwashed denim. Key details include copper rivets at the pocket corners, a minimalist Acne Studios leather tab at the rear waistband, a slightly tapered straight-leg silhouette, and a low-rise waist. These jeans reward wear and develop personalized fades over time.",
  status: 1
)

file10 = URI.open("https://www.westportbigandtall.com/cdn/shop/products/37147_STBL_Z_1000x.jpg?v=1769696217")
item10.photo.attach(io: file10, filename: "#{item10.name}.png", content_type: "image/png")
item10.save # Jeans

file11 = URI.open("https://res.cloudinary.com/dm1uny938/image/upload/v1773271998/dark_blue_jeans_s14grc.png")
item11.photo.attach(io: file11, filename: "#{item11.name}.png", content_type: "image/png")
item11.save # Dark Wash Denim Jeans

file12 = URI.open("https://res.cloudinary.com/dm1uny938/image/upload/v1773272038/black_pants_swmr7l.png")
item12.photo.attach(io: file12, filename: "#{item12.name}.png", content_type: "image/png")
item12.save # Jet-Black Trousers

file13 = URI.open("https://res.cloudinary.com/dm1uny938/image/upload/v1773313482/wys0a5oxl8evbe82l5qulqguvpls-Photoroom_adjxmn.png")
item13.photo.attach(io: file13, filename: "#{item13.name}.jpg", content_type: "image/jpeg")
item13.save # Dark Indigo Raw Denim

# Footwear

item14 = Item.new(
  user: glen,
  name: "Casual Shoes",
  slot: "footwear",
  category: "casual",
  description: "low-top, athletic sneakers featuring a classic white leather upper contrasted by bold black decorative stripes on the sides. The design includes a traditional lace-up closure with white laces and a distinctive gum-colored rubber outsole that provides a vintage, indoor-sport aesthetic. For branding, a black and white Onitsuka Tiger logo is visible on the tongue, while the heel counter is finished with a black leather overlay. The overall silhouette is slim and streamlined, characteristic of heritage racing or training footwear.",
  status: 1
)

item15 = Item.new(
  user: glen,
  name: "Formal Shoes",
  slot: "footwear",
  category: "formal",
  description: "a classic, polished black leather derby shoe, blending traditional formal elements with subtle modern detailing. The shoe features an open-lacing system, which gives it a slightly more versatile profile than a standard Oxford, and is crafted from a smooth, matte-finish leather. A distinctive touch is the brogue-style perforation—specifically a decorative medallion on the rounded toe and a delicate wing pattern along the side—adding a layer of sophistication without being overly ornate. With its slim black sole, low heel, and thin waxed laces, this shoe is a refined choice for business-professional attire or semi-formal occasions.",
  status: 1
)

item16 = Item.new(
  user: glen,
  name: "Black Timberland Boots",
  slot: "footwear",
  category: "casual",
  description: "classic 6-inch waterproof boots from Timberland, presented in a sleek, all-black nubuck leather finish. The design features a high-top silhouette with a padded leather collar for ankle comfort and a tonal lace-up closure with metallic eyelets. A rugged, lugged rubber outsole provides substantial traction, while the iconic tree logo is subtly embossed on the lateral heel and tongue. This monochromatic aesthetic offers a versatile, urban edge to a traditionally utilitarian work boot.",
  status: 1
)

item17 = Item.new(
  user: glen,
  name: "Black Converse Allstars",
  slot: "footwear",
  category: "casual",
  description: "classic Converse Chuck Taylor All Star high-tops, featuring a sleek triple black colorway that covers everything from the canvas upper to the rubber foxing. The design maintains its iconic silhouette while incorporating tonal elements, including black laces and a darkened version of the signature circular ankle patch. Silver-toned metal eyelets provide a subtle contrast against the dark fabric, leading up to a pull tab at the heel for easier entry. With their vulcanized rubber sole and timeless aesthetic, these sneakers offer a versatile, edgy alternative to the standard white-soled version.",
  status: 1
)

item18 = Item.new(
  user: glen,
  name: "Black Chelsea Boots",
  slot: "footwear",
  category: "social",
  description: "A pair of sleek black leather Chelsea boots photographed in a clean three-quarter studio shot against a white background. The boots are crafted from smooth, subtly pebbled full-grain black leather with a slightly matte finish. True to the Chelsea silhouette, they feature a single elasticated gusset on the side for easy on-and-off, a rear loop pull tab in coordinating black, a rounded almond toe, and a low stacked block heel. A powder-blue suede lining is visible at the collar, providing a refined contrast detail. A wardrobe essential that transitions from smart casual to semi-formal settings.",
  status: 1
)

file14 = URI.open("https://images.asics.com/is/image/asics/1183C429_100_SB_FR_GLB?qlt=80&wid=350&hei=300&bgc=255,255,255&resMode=bisharp")
item14.photo.attach(io: file14, filename: "#{item14.name}.png", content_type: "image/png")
item14.save # Casual Shoes

file15 = URI.open("https://www.zoomshoes.in/cdn/shop/files/28_2.jpg?v=1688447991&width=1200")
item15.photo.attach(io: file15, filename: "#{item15.name}.png", content_type: "image/png")
item15.save # Formal Shoes

file16 = URI.open("https://res.cloudinary.com/dm1uny938/image/upload/v1773312730/black_tims-Photoroom_a9nyh9.png")
item16.photo.attach(io: file16, filename: "#{item16.name}.png", content_type: "image/png")
item16.save # Black Timberland Boots

file17 = URI.open("https://res.cloudinary.com/dm1uny938/image/upload/v1773312734/black_converse_allstars-Photoroom_z0zwew.png")
item17.photo.attach(io: file17, filename: "#{item17.name}.png", content_type: "image/png")
item17.save # Black Converse Allstars

file18 = URI.open("https://www.zoomshoes.in/cdn/shop/products/8_1_926d35d2-3c0f-4370-9927-f59b03a6efe5.jpg?v=1682153369")
item18.photo.attach(io: file18, filename: "#{item18.name}.jpg", content_type: "image/jpeg")
item18.save # Black Chelsea Boots

puts "#{User.count} users created"
puts "#{Item.count} items created"
