# frozen_string_literal: true

require "dry/monads/do"

module Auctions
  module Actions
    class Finalize
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      class << self
        def call(auction_id:)
          new(auction_id).call
        end
      end

      def initialize(auction_id)
        @auction_id = auction_id
      end

      def call
        auction = yield fetch_auction
        closed_auction = yield close(auction)

        Success(Auctions::Api::Dto::Auction.from_active_record(closed_auction))
      end

      private

      attr_reader :auction_id

      def fetch_auction
        auction = Auctions::Models::Auction.find_by(id: auction_id)

        auction ? Success(auction) : Failure({ code: :auction_not_found })
      end

      def close(auction)
        if Time.now >= auction.finishes_at
          auction.close
          auction.save

          # create_order

          Success(auction)
        else
          Failure({ code: :auction_not_finished_yet })
        end
      end
    end
  end
end
