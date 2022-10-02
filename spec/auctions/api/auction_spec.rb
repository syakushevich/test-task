RSpec.describe Auctions::Api::Auction do
  require 'faker'

  describe ".create" do
    def prepare_auction_params(finishes_at: Time.now.utc + 1.day)
      Auctions::Api::DTO::AuctionParams.new(
        name: "Leonardo da Vinci's pencil",
        creator_id: "e155fe2c-c588-4320-8acf-a1ff0d82190b",
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
            id: kind_of(String),
            status: "open",
            winner_id: nil
          )
        )
      end

      it "schedules a background job to finalize auction" do
        auction_params = prepare_auction_params

        result = described_class.create(auction_params)

        expect(Auctions::Jobs::FinalizeAuction).to have_enqueued_sidekiq_job(result.value!.id)
          .at(auction_params.finishes_at)
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
    def prepare_auction
      Auctions::Models::Auction.create(
        id: "f458b10c-99e1-42ec-abda-77d0b9917936",
        name: "Leonardo da Vinci's pencil",
        creator_id: "e155fe2c-c588-4320-8acf-a1ff0d82190b",
        description: "An artifact from renaissance, used by the genius inventor and designer",
        package_weight: 0.05,
        package_size_x: 0.03,
        package_size_y: 0.005,
        package_size_z: 0.002,
        finishes_at: Time.now + 1.day,
        status: "open"
      )
    end

    context "when valid params given" do
      it "places a bid for an auction" do
        auction = prepare_auction
        bid_params = Auctions::Api::DTO::BidParams.new(
          amount: BigDecimal("545.5"),
          bidder_id: "2eca52ab-6710-4261-8c75-9574b2d22689",
          auction_id: auction.id
        )

        result = described_class.place_bid(bid_params)

        expect(result).to be_success
        expect(result.value!.to_h).to match(
          bid_params.to_h.merge(
            id: kind_of(String)
          )
        )
      end
    end

    context "when 0 amount given" do
      it "returns a failure" do
        auction = prepare_auction
        bid_params = Auctions::Api::DTO::BidParams.new(
          amount: BigDecimal("0.0"),
          bidder_id: "2eca52ab-6710-4261-8c75-9574b2d22689",
          auction_id: auction.id
        )

        result = described_class.place_bid(bid_params)

        expect(result).to be_failure
        expect(result.failure).to eq(
          code: :bid_not_created,
          details: { amount: ["must be greater than 0"] }
        )
      end
    end

    context "when bid is not higher from the last bid" do
      it "returns a failure" do
        auction = prepare_auction
        bid_params = Auctions::Api::DTO::BidParams.new(
          amount: BigDecimal("500.0"),
          bidder_id: "2eca52ab-6710-4261-8c75-9574b2d22689",
          auction_id: auction.id
        )
        described_class.place_bid(bid_params)

        result = described_class.place_bid(bid_params)

        expect(result).to be_failure
        expect(result.failure).to eq(
          code: :bid_not_created,
          details: { amount: ["must be higher than the last bid"] }
        )
      end
    end

    context "when auction does not exist" do
      it "returns a failure" do
        bid_params = Auctions::Api::DTO::BidParams.new(
          amount: BigDecimal("500.0"),
          bidder_id: "2eca52ab-6710-4261-8c75-9574b2d22689",
          auction_id: "f458b10c-99e1-42ec-abda-77d0b9917936"
        )
        described_class.place_bid(bid_params)

        result = described_class.place_bid(bid_params)

        expect(result).to be_failure
        expect(result.failure).to eq(
          code: :auction_not_found
        )
      end
    end
  end

  describe ".finalize" do
    let(:winner) { Users::Models::User.create(email: Faker::Internet.email) }

    def prepare_auction_and_bids(winner_id = SecureRandom.uuid)
      auction = Auctions::Models::Auction.create(
        name: "Leonardo da Vinci's pencil",
        creator_id: "e155fe2c-c588-4320-8acf-a1ff0d82190b",
        package_weight: 0.05,
        package_size_x: 0.03,
        package_size_y: 0.005,
        package_size_z: 0.002,
        finishes_at: Time.now + 1.day,
        status: "open"
      )
      user_1 = Users::Models::User.create(email: Faker::Internet.email)
      user_2 = Users::Models::User.create(email: Faker::Internet.email)
      Auctions::Models::Bid.create(bidder_id: user_1.id, auction_id: auction.id, amount: BigDecimal("30.0"))
      Auctions::Models::Bid.create(bidder_id: user_2.id, auction_id: auction.id, amount: BigDecimal("43.5"))
      Auctions::Models::Bid.create(bidder_id: winner.id, auction_id: auction.id, amount: BigDecimal("75.0"))

      auction
    end

    context "when auction can be finalized" do
      include ActiveSupport::Testing::TimeHelpers

      it "closes the auction and sets the winner_id to the highest bidder id" do
        auction = prepare_auction_and_bids(winner.id)

        travel_to(Time.now + 1.day + 1.minute) do
          result = described_class.finalize(auction.id)

          expect(result).to be_success
          expect(result.value!.to_h).to match(
            auction.attributes.symbolize_keys
              .except(:created_at, :updated_at)
              .merge(
                winner_id: winner.id,
                status: "closed",
                finishes_at: kind_of(Time)
              )
          )
        end
      end

      it "creates an order" do
        auction = prepare_auction_and_bids(winner.id)

        travel_to(Time.now + 1.day + 1.minute) do
          create_order_method = AuctionDependencies.container.resolve(:create_order)

          expect(create_order_method).to receive(:call).with(
            auction_id: auction.id,
            buyer_id: winner.id,
            total_payment: BigDecimal("75.0")
          ).and_return(Dry::Monads::Result::Success.new(""))

          described_class.finalize(auction.id)
        end
      end

      it "sends emails to all parties" do
        auction = prepare_auction_and_bids(winner.id)
        travel_to(Time.now + 1.day + 1.minute) do
          expect(EmailDelivery::Api::Email).to receive(:deliver_to_winner).and_return(Dry::Monads::Result::Success.new(""))
          expect(EmailDelivery::Api::Email).to receive(:deliver_to_bidder).twice.and_return(Dry::Monads::Result::Success.new(""))
          described_class.finalize(auction.id)
        end
      end
    end

    context "when auction is not finished yet" do
      it "returns a failure" do
        auction = prepare_auction_and_bids(winner.id)

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

    context "when error on creating_order" do
      include ActiveSupport::Testing::TimeHelpers

      it "returns a failure and does not close the auction" do
        auction = prepare_auction_and_bids(winner.id)

        travel_to(Time.now + 1.day + 1.minute) do
          create_order_method = AuctionDependencies.container.resolve(:create_order)

          expect(create_order_method).to receive(:call).with(
            auction_id: auction.id,
            buyer_id: winner.id,
            total_payment: BigDecimal("75.0")
          ).and_return(Dry::Monads::Failure({ code: :order_disordered }))

          result = described_class.finalize(auction.id)

          expect(result).to be_failure
          expect(result.failure).to eq(
            code: :order_disordered
          )
          expect(auction.reload.status).to eq("open")
        end
      end
    end
  end
end
