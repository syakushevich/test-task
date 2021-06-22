# frozen_string_literal: true

module Auctions
  module Api
    class Auction
      class << self
        # @param auction_params [Auctions::Api::DTO::AuctionParams] Params for new auction
        # @return [Dry::Monads::Result<Auctions::Api::DTO::Auction, Failure>] Auction as Dto in case of success,
        # or a Failure object
        def create(auction_params)
          ::Auctions::Actions::Create.call(params: auction_params)
        end

        # @param bid_params [Auctions::Api::DTO::BidParams] Params for the new bid
        # @return [Dry::Monads::Result<Auctions::Api::DTO::Bid, Failure>] Bid as Dto in case of success,
        # or a Failure object
        def place_bid(bid_params)
          ::Auctions::Actions::CreateBid.call(params: bid_params)
        end
      end
    end
  end
end
