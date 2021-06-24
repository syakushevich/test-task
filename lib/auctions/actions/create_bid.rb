# frozen_string_literal: true

require "dry/monads/do"

module Auctions
  module Actions
    class CreateBid
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      class << self
        def call(**kwargs)
          new(**kwargs).call
        end
      end

      def initialize(params:)
        @params = params
      end

      def call
        auction = yield fetch_auction
        yield validate_bid_is_higher(auction)
        bid = yield create_bid

        Success(Auctions::Api::DTO::Bid.new(bid.attributes.symbolize_keys))
      end

      private

      attr_reader :params

      def fetch_auction
        auction = Auctions::Models::Auction.find_by(id: params[:auction_id])

        auction ? Success(auction) : Failure({ code: :auction_not_found })
      end

      def validate_bid_is_higher(auction)
        if auction.bids.empty? || params[:amount] > auction.bids.last.amount
          Success()
        else
          Failure({ code: :bid_not_created, details: { amount: ["must be higher than the last bid"]} })
        end
      end

      def create_bid
        bid = Auctions::Models::Bid.create(params.to_h)

        if bid.errors.empty?
          Success(bid)
        else
          Failure({ code: :bid_not_created, details: bid.errors.to_hash })
        end
      end
    end
  end
end
