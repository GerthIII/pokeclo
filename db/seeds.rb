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

#updated ryota to have easier login
ryota = User.create!(
  name: "Ryota Hayakawa",
  email: "ryota@gmail.com",
  password: "123123"
)
ryota.profile_photo.attach(
  io: URI.open("https://res.cloudinary.com/dm1uny938/image/upload/v1773114147/Ryota_Base_dbgxbm.jpg"),
  filename: "ryota_profile.jpg",
  content_type: "image/jpeg"
)

item1 = Item.new(
  user: ryota,
  name: "sports shirt",
  slot: "top",
  category: "sports",
  description: "An Adidas x Oasis collaboration t-shirt, characterized by a vintage-inspired ringer style and a clean, off-white or cream color base. The shirt is a classic crewneck with short sleeves, featuring contrasting black ribbed material on the collar and the sleeve cuffs. Running down each shoulder and sleeve are the iconic Adidas three-stripe motifs in bold black. The front of the garment displays two distinct logos: on the right chest (viewer's left) is the traditional black Adidas Trefoil logo, while on the left chest (viewer's right) is a rectangular black patch containing the word oasis in its signature lowercase font. The design blends 1990s Britpop aesthetics with classic athletic heritage, offering a minimalist yet recognizable terrace-wear look.",
  status: 2
)

item2 = Item.new(
  user: ryota,
  name: "sports pants",
  slot: "bottom",
  category: "sports",
  description: "The second image displays a pair of black sporty joggers or track pants by the brand Hummel, featuring a relaxed, slightly tapered fit with elasticated ankle cuffs. The design is characterized by a prominent white chevron-style color-block panel that wraps around the lower legs, creating a bold geometric contrast. A small white Hummel bumblebee logo is embroidered on the upper left thigh, and the waistband appears to be elasticated for comfort, suggesting a functional yet stylish piece of activewear.",
  status: 1
)

item3 = Item.new(
  user: ryota,
  name: "sports shoes",
  slot: "footwear",
  category: "sports",
  description: "a technical Adidas athletic cleat, specifically designed for high-performance sports like baseball. It features a sleek white mesh upper for breathability, textured with a diamond-pattern overlay, and the three-stripe motif in a faded black pixelated print. The sole unit utilizes Lightstrike Pro cushioning for responsiveness and is equipped with metal spikes for maximum traction on turf or dirt.",
  status: 1
)

item4 = Item.new(
  user: ryota,
  name: "sports jacket",
  slot: "outer",
  category: "sports",
  description: "features a streamlined, functional design with a full-length front zipper. The garment is characterized by its ribbed stand-up collar in a contrasting cream or off-white interior, which adds a subtle pop of color to the deep teal-blue body. For branding, it includes a tonal diamond-shaped patch on the left chest and the SOPH logo printed on the right. The construction utilizes raglan sleeves for increased mobility, while two discreet, vertical zippered pockets are integrated into the side seams for secure storage. With its clean lines and technical aesthetic, this piece bridges the gap between high-performance sportswear and modern urban streetwear.",
  status: 2
)

item5 = Item.new(
  user: ryota,
  name: "casual t-shirt",
  slot: "top",
  category: "casual",
  description: "a clean, studio-style product shot of a short-sleeved, crewneck T-shirt from the Uniqlo U collection. The shirt is a deep, earthy olive-brown or dark taupe color and is displayed flat against a neutral light-gray background. It features a classic, slightly relaxed fit with a thick, ribbed neckline and structured sleeves. In the upper-left corner, the Uniqlo logo is paired with the U branding, indicating it is part of the line designed by Christophe Lemaire.",
  status: 1
)

item6 = Item.new(
  user: ryota,
  name: "polo t-shirt",
  slot: "top",
  category: "casual",
  description: "a classic navy blue short-sleeved polo shirt by Polo Ralph Lauren, set against a solid white background. The garment is made from a textured pique cotton fabric and features a two-button placket with white buttons, a ribbed collar, and matching ribbed armbands. A small, vibrant red embroidered pony logo is positioned on the left chest, providing a sharp contrast to the dark blue material. Inside the neckline, the brand's signature blue and gold label is visible, identifying the piece as part of their Custom Slim Fit line.",
  status: 1
)

item7 = Item.new(
  user: ryota,
  name: "formal shirt",
  slot: "top",
  category: "formal",
  description: "a long-sleeved dress shirt by Zegna, displayed flat against a neutral, light-gray gradient background. The shirt is a deep, muted charcoal or dark navy hue and features a clean, minimalist design with a hidden button placket that creates a seamless vertical line down the center. It is constructed with a structured spread collar and standard button cuffs. A small, dark brand label is visible on the inside of the collar, emphasizing the garment's high-end, tailored aesthetic.",
  status: 2
)

item8 = Item.new(
  user: ryota,
  name: "formal shirt",
  slot: "top",
  category: "formal",
  description: "a high-quality, long-sleeved button-down shirt from the luxury Italian fashion house ZEGNA, presented against a clean, neutral gray background. The shirt is a light off-white or cream color, crafted from a textured fabric—likely linen or a linen-silk blend—which gives it a sophisticated yet relaxed quiet luxury aesthetic. It features a sharp spread collar, a classic front placket with subtly shimmering buttons, and a straight hemline designed to be worn either tucked or untucked. The overall composition is minimalist and elegant, highlighting the fine craftsmanship and natural drape of the garment.",
  status: 1
)

item9 = Item.new(
  user: ryota,
  name: "Jeans",
  slot: "bottom",
  category: "casual",
  description: "a pair of classic Levi Strauss & Co. blue jeans, presented in a folded flat-lay position against a clean white background. The denim has a medium-to-dark blue wash with subtle fading and vertical grain texture, suggesting a comfortable, broken-in feel. Key brand identifiers are visible, including the iconic tan Two Horse leather patch on the rear waistband and the signature Arcuate stitching on the back pocket. The construction details include contrasting orange topstitching, copper-tone rivets on the front coin and hip pockets, and a sturdy belt loop system, all characteristic of traditional American workwear-inspired style.",
  status: 1
)

item10 = Item.new(
  user: ryota,
  name: "Linen Pants",
  slot: "bottom",
  category: "casual",
  description: "a pair of light-colored, relaxed-fit trousers worn by a model, conveying a breezy and casual aesthetic. These pants appear to be made from a textured, lightweight fabric like linen, characterized by a soft grey or oatmeal heathered tone. A notable design element is the comfortable, elasticized waistband featuring a single-button closure and a hidden drawstring or zip fly. The trousers have a straight-leg cut that tapers slightly toward the hem, which is finished with a subtle cuff, making them an ideal choice for warm-weather styling.",
  status: 1
)

item11 = Item.new(
  user: ryota,
  name: "Social Pants",
  slot: "bottom",
  category: "social",
  description: "a refined example of classic menswear, featuring a charcoal grey or deep anthracite hue with a subtle, high-quality wool texture. They are designed with a tailored, slim-straight fit that includes a sharp permanent crease running down the center of each leg for a crisp, professional silhouette. Notably, the waistband is a belt-loop-free design, utilizing sophisticated side adjusters with metal buckles to provide a clean, streamlined look around the hips. The styling is further elevated by an extended button-tab closure at the waist and discreet slanted side pockets, making them an ideal choice for a modern business or smart casual wardrobe.",
  status: 1
)

item12 = Item.new(
  user: ryota,
  name: "Social Pants",
  slot: "bottom",
  category: "social",
  description: "These trousers feature a classic Glen check pattern in shades of light grey with subtle yellow or tan over-checking, offering a sophisticated, vintage-inspired aesthetic. The design is defined by a high-rise waistband that lacks belt loops, opting instead for buckled side adjusters and a long, clean extended button-tab closure for a bespoke look. Adding to the traditional silhouette are prominent double pleats at the front, which create a more voluminous, comfortable drape through the thigh before tapering down to a sharp, permanent center crease.",
  status: 1
)

item13 = Item.new(
  user: ryota,
  name: "Casual Shoes",
  slot: "footwear",
  category: "casual",
  description: "low-top, athletic sneakers featuring a classic white leather upper contrasted by bold black decorative stripes on the sides. The design includes a traditional lace-up closure with white laces and a distinctive gum-colored rubber outsole that provides a vintage, indoor-sport aesthetic. For branding, a black and white Onitsuka Tiger logo is visible on the tongue, while the heel counter is finished with a black leather overlay. The overall silhouette is slim and streamlined, characteristic of heritage racing or training footwear.",
  status: 1
)

item14 = Item.new(
  user: ryota,
  name: "Formal Shoes",
  slot: "footwear",
  category: "formal",
  description: "a classic, polished black leather derby shoe, blending traditional formal elements with subtle modern detailing. The shoe features an open-lacing system, which gives it a slightly more versatile profile than a standard Oxford, and is crafted from a smooth, matte-finish leather. A distinctive touch is the brogue-style perforation—specifically a decorative medallion on the rounded toe and a delicate wing pattern along the side—adding a layer of sophistication without being overly ornate. With its slim black sole, low heel, and thin waxed laces, this shoe is a refined choice for business-professional attire or semi-formal occasions.",
  status: 1
)

item15 = Item.new(
  user: ryota,
  name: "Casual Loafer",
  slot: "footwear",
  category: "casual",
  description: "these Zegna penny loafers are crafted in a rich, warm tan suede that offers a soft, matte texture. The design features a classic moc-toe construction with visible tonal stitching that defines the apron, while a traditional leather saddle strap with a signature slit rests across the vamp. The interior is lined with a smooth, lighter-colored leather and showcases the ZEGNA logo embossed on the footbed. With their streamlined silhouette and lack of structured hardware, these shoes represent a sophisticated quiet luxury aesthetic, making them ideal for elevated casual or summer-business ensembles.",
  status: 1
)
item16 = Item.new(
  user: ryota,
  name: "White Basic Tee",
  slot: "top",
  category: "casual",
  description: "A clean, minimalist white crew-neck t-shirt photographed on a male model against a blurred background of shelves with terracotta potted plants. The shirt is a classic short-sleeved cut in bright, crisp white cotton with no branding or graphic, featuring a ribbed crew neckline and a comfortable, slightly relaxed fit. The quintessential wardrobe staple — a blank canvas that complements virtually any bottom or outerwear layer.",
  status: 1
)

item17 = Item.new(
  user: ryota,
  name: "White Crewneck Sweatshirt",
  slot: "top",
  category: "casual",
  description: "A classic white fleece crewneck sweatshirt presented in a flat-lay arrangement on a light grey surface, styled alongside a pair of grey jeans and white canvas low-top sneakers. The sweatshirt features a relaxed boxy fit, a thick ribbed crew neckline, matching ribbed cuffs and a wide ribbed hem band, and a soft brushed interior for warmth. The blank, unbranded design makes it a versatile layering piece suited to streetwear and relaxed weekend dressing.",
  status: 1
)

item18 = Item.new(
  user: ryota,
  name: "Rust Bomber Jacket",
  slot: "outer",
  category: "casual",
  description: "A warm rust or burnt sienna-colored nylon bomber jacket suspended from a simple white plastic hanger against a neutral grey wall. The jacket follows the classic MA-1 silhouette with a full-length front zipper, ribbed elastic collar, cuffs, and waistband in a matching tonal finish. A secondary zipper pocket is stitched onto the left sleeve, and there are two discreet welt pockets set into the lower front. The smooth, slightly lustrous fabric gives the jacket an elevated streetwear sensibility.",
  status: 1
)

item19 = Item.new(
  user: ryota,
  name: "Black Quilted Puffer Jacket",
  slot: "outer",
  category: "casual",
  description: "A black channel-quilted puffer jacket with a slightly structured moto-inspired silhouette, worn open by a male model over a bright red hoodie in an outdoor urban setting. The jacket features a bold asymmetric zip closure, a stand collar, multiple silver-tone zipper pockets across the chest and sides, and stitched quilting in a narrow vertical channel pattern that creates a sleek, non-bulky profile. The combination of technical quilting and edgy hardware gives this jacket a contemporary, street-ready aesthetic.",
  status: 1
)

item20 = Item.new(
  user: ryota,
  name: "Tan Casual Blazer",
  slot: "outer",
  category: "social",
  description: "A tailored tan or khaki single-breasted sport coat captured in a styled flat-lay alongside a light blue floral-print dress shirt, dark navy selvedge jeans, and dark brown brogue wingtip oxfords. The blazer features a notch lapel, two-button front closure, a breast pocket finished with a blue and white gingham pocket square, and functional sleeve buttons. The structured shoulder and clean drape make this ideal for social outings or elevated everyday smart-casual wear.",
  status: 1
)

item21 = Item.new(
  user: ryota,
  name: "Navy Wool Overcoat",
  slot: "outer",
  category: "formal",
  description: "A selection of heavy-weight wool and fleece outerwear displayed on ring hangers outside an artisan boutique. The centerpiece is a deep navy blue wool fleece coat featuring a thick oversized ribbed collar, a single-breasted button closure, and a long silhouette that falls past the hip. Flanking it are heathered grey and deep orange-red counterparts, all sharing the same plush, substantial fabric that promises exceptional warmth and an understated, heritage-tinged formality.",
  status: 1
)

item22 = Item.new(
  user: ryota,
  name: "Black Levi's Jeans",
  slot: "bottom",
  category: "casual",
  description: "A clean solid black pair of Levi's Jeans — fanned out against a dark background and showcases the classic five-pocket construction with contrasting orange topstitching, copper rivets at the stress points, a Levi's red tab on the right back pocket, and a black-finished Two Horse leather patch at the rear waistband. A versatile and timeless wardrobe foundation built for everyday wear.",
  status: 1
)

item23 = Item.new(
  user: ryota,
  name: "Dark Indigo Raw Denim",
  slot: "bottom",
  category: "casual",
  description: "A pair of Acne Studios dark indigo raw selvedge denim jeans presented in a flat-lay product shot on a white, slightly wrinkled linen surface. The jeans are characterized by a very deep, almost charcoal-navy wash that retains the rigid, stiff quality of unwashed denim. Key details include copper rivets at the pocket corners, a minimalist Acne Studios leather tab at the rear waistband, a slightly tapered straight-leg silhouette, and a low-rise waist. These jeans reward wear and develop personalized fades over time.",
  status: 1
)

item24 = Item.new(
  user: ryota,
  name: "Black Pleated Chinos",
  slot: "bottom",
  category: "social",
  description: "A pair of slim-cut black pleated chino trousers worn by a male model standing against a deep emerald-green studio background. The trousers feature a single forward pleat at each leg, a clean flat front panel, a standard waistband with multiple belt loops, and a tapered leg that narrows toward the ankle for a refined silhouette. The solid black fabric has a slight sheen suggesting a cotton-twill blend, bridging the gap between smart casual and relaxed social dressing.",
  status: 1
)

item25 = Item.new(
  user: ryota,
  name: "Brown Corduroy Trousers",
  slot: "bottom",
  category: "casual",
  description: "A pair of deep espresso-brown fine-wale corduroy trousers worn by a male model against a neutral grey studio background. The trousers are cut in a relaxed straight fit with a high-rise waistband, single-button closure, a flat front enhanced by the corduroy's vertical ridges, and discreet slanted side pockets. The rich, warm brown tone is highlighted by the way the fine ribs catch the light, lending tactile depth to an otherwise clean, unfussy silhouette. Styled here with a blue dress shirt and dark suede boat shoes.",
  status: 1
)

item26 = Item.new(
  user: ryota,
  name: "Nike Air Force 1 x Carhartt",
  slot: "footwear",
  category: "casual",
  description: "A Nike Air Force 1 Low from the collaborative capsule with Carhartt WIP, photographed on a draped background of golden corduroy fabric. The sneaker features a tan/brown canvas upper referencing Carhartt's iconic duck canvas workwear, a tonal brown Swoosh, a Carhartt WIP logo woven patch at the heel tab with orange interior lining, bronze-tone eyelets, and a white Air unit midsole with a lightly gum-tinted outsole. A limited-edition collision of workwear heritage and sneaker culture.",
  status: 1
)

item27 = Item.new(
  user: ryota,
  name: "New Balance 247 Olive",
  slot: "footwear",
  category: "sports",
  description: "A New Balance 247 athletic sneaker in an olive green or army surplus colorway, photographed floating against a blurred brick wall background. The upper combines a breathable mesh base with smooth synthetic leather overlays, dominated by a bold embossed black N logo on the lateral side panel. The shoe rides on a white RevLite foam midsole for cushioned everyday comfort, finished with a black rubber outsole for grip. Its modern, streamlined silhouette and muted military-inspired color make it a versatile sports-casual option.",
  status: 1
)

item28 = Item.new(
  user: ryota,
  name: "Cognac Leather Derbies",
  slot: "footwear",
  category: "formal",
  description: "A close-up studio shot of a pair of warm cognac or tan-brown leather derby shoes, showcasing texture and craftsmanship in fine detail. The shoes feature an open lacing system with matching tan leather laces, a cap-toe construction in smooth calfskin contrasting with a pebbled grain leather vamp, a low block heel, and a structured silhouette with a rounded-almond toe. The rich chestnut coloring and fine detailing make these shoes an elegant yet approachable option for business-casual and formal occasions.",
  status: 1
)

item29 = Item.new(
  user: ryota,
  name: "Black Chelsea Boots",
  slot: "footwear",
  category: "social",
  description: "A pair of sleek black leather Chelsea boots photographed in a clean three-quarter studio shot against a white background. The boots are crafted from smooth, subtly pebbled full-grain black leather with a slightly matte finish. True to the Chelsea silhouette, they feature a single elasticated gusset on the side for easy on-and-off, a rear loop pull tab in coordinating black, a rounded almond toe, and a low stacked block heel. A powder-blue suede lining is visible at the collar, providing a refined contrast detail. A wardrobe essential that transitions from smart casual to semi-formal settings.",
  status: 1
)

item30 = Item.new(
  user: ryota,
  name: "Black Cap-Toe Derby",
  slot: "footwear",
  category: "formal",
  description: "An extreme close-up of a black leather cap-toe derby shoe, showcasing the craftsmanship in fine detail. The shoe features a pebbled tumbled-grain leather upper transitioning into a smooth, polished cap-toe extension at the toe box, an open lacing system with flat black laces threaded through four pairs of silver-tone metal eyelets, and a thick black rubber outsole. The bold texture contrast between the grainy upper and the smooth cap-toe gives this practical, long-lasting formal shoe a modern, slightly rugged character.",
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

file16 = URI.open("https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=80")
item16.photo.attach(io: file16, filename: "#{item16.name}.jpg", content_type: "image/jpeg")
item16.save

file17 = URI.open("https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?auto=format&fit=crop&w=800&q=80")
item17.photo.attach(io: file17, filename: "#{item17.name}.jpg", content_type: "image/jpeg")
item17.save

file18 = URI.open("https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&w=800&q=80")
item18.photo.attach(io: file18, filename: "#{item18.name}.jpg", content_type: "image/jpeg")
item18.save

file19 = URI.open("https://res.cloudinary.com/dm1uny938/image/upload/v1773125970/61XUeKFhUqL._AC_UY1000__eaguoh.jpg")
item19.photo.attach(io: file19, filename: "#{item19.name}.jpg", content_type: "image/jpeg")
item19.save

file20 = URI.open("https://res.cloudinary.com/dm1uny938/image/upload/v1773125820/71qNDKpZglL._AC_UY1000__mudsvu.jpg")
item20.photo.attach(io: file20, filename: "#{item20.name}.jpg", content_type: "image/jpeg")
item20.save

file21 = URI.open("https://res.cloudinary.com/dm1uny938/image/upload/v1773125676/740_NAV_FRT_jh855b.jpg")
item21.photo.attach(io: file21, filename: "#{item21.name}.jpg", content_type: "image/jpeg")
item21.save

file22 = URI.open("https://res.cloudinary.com/dm1uny938/image/upload/v1773126060/sgmsqlocr1kbkuakkltd_nd3m9a.jpg")
item22.photo.attach(io: file22, filename: "#{item22.name}.jpg", content_type: "image/jpeg")
item22.save

file23 = URI.open("https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&w=800&q=80")
item23.photo.attach(io: file23, filename: "#{item23.name}.jpg", content_type: "image/jpeg")
item23.save

file24 = URI.open("https://www.zoomshoes.in/cdn/shop/files/L-50_BROWN_2.jpg?v=1726898204")
item24.photo.attach(io: file24, filename: "#{item24.name}.jpg", content_type: "image/jpeg")
item24.save

file25 = URI.open("https://www.zoomshoes.in/cdn/shop/files/2641BLACK_1.jpg?v=1721818550")
item25.photo.attach(io: file25, filename: "#{item25.name}.jpg", content_type: "image/jpeg")
item25.save

file26 = URI.open("https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=800&q=80")
item26.photo.attach(io: file26, filename: "#{item26.name}.jpg", content_type: "image/jpeg")
item26.save

file27 = URI.open("https://images.unsplash.com/photo-1539185441755-769473a23570?auto=format&fit=crop&w=800&q=80")
item27.photo.attach(io: file27, filename: "#{item27.name}.jpg", content_type: "image/jpeg")
item27.save

file28 = URI.open("https://images.unsplash.com/photo-1614252235316-8c857d38b5f4?auto=format&fit=crop&w=800&q=80")
item28.photo.attach(io: file28, filename: "#{item28.name}.jpg", content_type: "image/jpeg")
item28.save

file29 = URI.open("https://www.zoomshoes.in/cdn/shop/products/8_1_926d35d2-3c0f-4370-9927-f59b03a6efe5.jpg?v=1682153369")
item29.photo.attach(io: file29, filename: "#{item29.name}.jpg", content_type: "image/jpeg")
item29.save

file30 = URI.open("https://www.zoomshoes.in/cdn/shop/files/D047BLACK_1.jpg?v=1732610876")
item30.photo.attach(io: file30, filename: "#{item30.name}.jpg", content_type: "image/jpeg")
item30.save


outfit = Outfit.create!(
  user: ryota,
  name: "festival outfit",
  description: "When you're at a festival and wanna stay cool while showing your furusato pride.",
  status: 1
)

OutfitItem.create!(
  item_id: item5.id,
  outfit_id: outfit.id,
  slot: item2.slot
)

OutfitItem.create!(
  item_id: item10.id,
  outfit_id: outfit.id,
  slot: item10.slot
)

OutfitItem.create!(
  item_id: item15.id,
  outfit_id: outfit.id,
  slot: item15.slot
)

OutfitItem.create!(
  item_id: item4.id,
  outfit_id: outfit.id,
  slot: item4.slot
)
# Message.create!(
#   outfit_id: outfit.id,
#   role: "user",
#   content: "Please create me an outfit that I can wear to the fire festival"
# )

# this comment is just to make an edit

puts "#{User.count} users created"
puts "#{Item.count} items created"
puts "#{Outfit.count} outfits  created"
