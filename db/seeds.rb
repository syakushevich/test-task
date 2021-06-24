emails = %w(
  admin@auctionary.com
  user1@gmail.com
  user2@trafalgar.com
)

emails.each do |email|
  Users::Models::User.create!(email: email)
end

admin = Users::Models::User.find_by(email: "admin@auctionary.com")
user1 = Users::Models::User.find_by(email: "user1@gmail.com")
user2 = Users::Models::User.find_by(email: "user2@trafalgar.com")

auction1 = Auctions::Models::Auction.create(
  name: "Leonardo da Vinci's pencil",
  creator_id: admin.id,
  description: "An artifact from renaissance, used by the genius inventor and designer",
  package_weight: 0.05,
  package_size_x: 0.03,
  package_size_y: 0.005,
  package_size_z: 0.002,
  finishes_at: Time.now + 5.days
)

Auctions::Models::Bid.create(
  auction_id: auction1.id,
  bidder_id: user1.id,
  amount: 505.0
)

Auctions::Models::Bid.create(
  auction_id: auction1.id,
  bidder_id: user2.id,
  amount: 1460.0
)

Auctions::Models::Bid.create(
  auction_id: auction1.id,
  bidder_id: user1.id,
  amount: 2678.0
)

Orders::Models::Order.create(
  auction_id: auction1.id,
  total_payment: 2678.0
)

auction2 = Auctions::Models::Auction.create(
  name: "Tom Hanks's bicycle",
  creator_id: admin.id,
  description: "Tom Hanks used to ride it to the Forrest Gump set",
  package_weight: 15.0,
  package_size_x: 1.5,
  package_size_y: 1.2,
  package_size_z: 0.5,
  finishes_at: Time.now + 14.days
)

Auctions::Models::Bid.create(
  auction_id: auction2.id,
  bidder_id: user2.id,
  amount: 7320.0
)

Auctions::Models::Bid.create(
  auction_id: auction2.id,
  bidder_id: user1.id,
  amount: 23_000.0
)

Auctions::Models::Bid.create(
  auction_id: auction2.id,
  bidder_id: user2.id,
  amount: 35_000.0
)

Orders::Models::Order.create(
  auction_id: auction2.id,
  total_payment: 35_000.0
)
