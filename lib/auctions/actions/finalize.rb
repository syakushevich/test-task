# frozen_string_literal: true

require "dry/monads/do"

module Auctions
  module Actions
    class Finalize
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)
      include AuctionDependencies[:create_order]

      class << self
        def call(**kwargs)
          new(**kwargs).call
        end
      end

      def initialize(auction_id:, create_order:)
        @auction_id = auction_id
        @create_order = create_order
      end

      def call
        auction = yield fetch_auction

        ActiveRecord::Base.transaction do
          auction = yield close(auction)
          yield create_order.call(order_params(auction))
          order = yield fetch_order

          EmailDelivery::Api::Email.deliver_to_winner(yield(Users::Api::User.get_by_id(auction.winner_id)).email, 
                                                      reference_number: order.reference_number, 
                                                      total_payment: order.total_payment)

          Users::Models::User.where(id: lost_bidders(auction)).each do |bidder|
            EmailDelivery::Api::Email.deliver_to_bidder(bidder.email, total_payment: order.total_payment)
          end
        end


        Success(Auctions::Api::DTO::Auction.new(auction.attributes.symbolize_keys))
      end

      private

      attr_reader :auction_id, :create_order

      def fetch_auction
        auction = Auctions::Models::Auction.find_by(id: auction_id)

        auction ? Success(auction) : Failure({ code: :auction_not_found })
      end

      def fetch_order
        order = Orders::Models::Order.find_by(auction_id: auction_id)

        order ? Success(order) : Failure({ code: :order_not_found })
      end

      def close(auction)
        if Time.now >= auction.finishes_at
          auction.status = "closed"
          auction.winner_id = highest_bidder(auction)
          auction.save

          auction.errors.empty? ? Success(auction) : Failure(failure_details(auction))
        else
          Failure({ code: :auction_not_finished_yet })
        end
      end

      def failure_details(auction)
        { code: :auction_not_finalized, details: auction.errors.to_hash }
      end

      def order_params(auction)
        {
          auction_id: auction.id,
          buyer_id: auction.winner_id,
          total_payment: auction.bids.find_by(bidder_id: auction.winner_id).amount
        }
      end

      def highest_bidder(auction)
        auction.bids.order("amount desc").first.bidder_id
      end

      def lost_bidders(auction)
        auction.bids.order("amount desc").offset(1).distinct.pluck(:bidder_id)
      end
    end
  end
end
