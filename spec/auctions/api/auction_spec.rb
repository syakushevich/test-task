RSpec.describe Auctions::Api::Auction do
  describe ".create" do
    context "when valid params given" do
      it "creates the auction" do
        auction_params = Auctions::Api::Dto::AuctionParams.new(
          name: "Leonardo da Vinci's pencil",
          description: "An artifact from renaissance, used by the genius inventor and designer",
          package_weight: 0.05,
          package_size_x: 0.03,
          package_size_y: 0.005,
          package_size_z: 0.002,
          finishes_at: DateTime.now + 1.day
        )

        result = described_class.create(auction_params)

        expect(result).to be_success
        expect(result.value!).to eq({})
      end
    end
  end
end
