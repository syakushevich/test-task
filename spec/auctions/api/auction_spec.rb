RSpec.describe Auctions::Api::Auction do
  describe ".create" do
    def prepare_auction_params(finishes_at: Time.now.utc + 1.day)
      Auctions::Api::Dto::AuctionParams.new(
        name: "Leonardo da Vinci's pencil",
        creator_id: 15,
        description: "An artifact from renaissance, used by the genius inventor and designer",
        package_weight: 0.05,
        package_size_x: 0.03,
        package_size_y: 0.005,
        package_size_z: 0.002,
        finishes_at: finishes_at
      )
    end

    context "when valid params given" do
      it "creates the auction" do
        auction_params = prepare_auction_params

        result = described_class.create(auction_params)

        expect(result).to be_success
        expect(result.value!.to_h).to match(
          auction_params.to_h.merge(
            id: kind_of(Integer),
            status: "open",
            winner_id: nil
          )
        )
      end
    end

    context "when finishes_at is in the past" do
      it "returns a failure" do
        auction_params = prepare_auction_params(finishes_at: Time.now - 1.day)

        result = described_class.create(auction_params)

        expect(result).to be_failure
        expect(result.failure).to eq(
          code: :auction_not_created,
          details: { finishes_at: ["must be in the future"] }
        )
      end
    end
  end

  describe ".place_bid" do
    context "when valid params given" do
      it "places a bid for an auction" do
        bid_params = Auctions::Api::Dto::BidParams.new(
          amount: 545.5,
          bidder_id: 31,
          auction_id: 75
        )

        result = described_class.place_bid(bid_params)

        expect(result).to be_success
        expect(result.value!.to_h).to match(
          bid_params.to_h.merge(
            id: kind_of(Integer)
          )
        )
      end
    end

    context "when 0 amount given" do
      it "returns a failure" do
        bid_params = Auctions::Api::Dto::BidParams.new(
          amount: 0.0,
          bidder_id: 31,
          auction_id: 75
        )

        result = described_class.place_bid(bid_params)

        expect(result).to be_failure
        expect(result.failure).to eq(
          code: :bid_not_created,
          details: { amount: ["must be greater than 0"] }
        )
      end
    end
  end

  describe ".finalize" do
    def prepare_auction_and_bids
      auction = Auctions::Models::Auction.create(
        name: "Leonardo da Vinci's pencil",
        creator_id: 15,
        package_weight: 0.05,
        package_size_x: 0.03,
        package_size_y: 0.005,
        package_size_z: 0.002,
        finishes_at: Time.now + 1.day
      )
      Auctions::Models::Bid.create(bidder_id: 231, auction_id: auction.id, amount: 30.0)
      Auctions::Models::Bid.create(bidder_id: 67, auction_id: auction.id, amount: 75.0)
      Auctions::Models::Bid.create(bidder_id: 142, auction_id: auction.id, amount: 43.5)

      auction
    end

    context "when auction can be finalized" do
      include ActiveSupport::Testing::TimeHelpers

      it "closes the auction and sets the winner_id to the highest bidder id" do
        auction = prepare_auction_and_bids

        travel_to(Time.now + 1.day + 1.minute) do
          result = described_class.finalize(auction.id)

          expect(result).to be_success
          expect(result.value!.to_h).to match(
            auction.attributes.symbolize_keys
              .except(:created_at, :updated_at)
              .merge(
                winner_id: 67,
                status: "closed"
              )
          )
        end
      end
    end

    context "when auction is not finished yet" do
      it "returns a failure" do
        auction = prepare_auction_and_bids

        result = described_class.finalize(auction.id)

        expect(result).to be_failure
        expect(result.failure).to eq(
          code: :auction_not_finished_yet
        )
      end
    end

    context "when auction does not exist" do
      it "returns a failure" do
        result = described_class.finalize(67)

        expect(result).to be_failure
        expect(result.failure).to eq(
          code: :auction_not_found
        )
      end
    end
  end
end
