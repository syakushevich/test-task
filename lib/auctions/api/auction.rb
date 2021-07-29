# frozen_string_literal: true

module Auctions
  module Api
    class Auction
      class << self
        # @param auction_params [Auctions::Api::DTO::AuctionParams] Params for new auction
        # @return [Dry::Monads::Result<Auctions::Api::DTO::Auction, Failure>] Auction as DTO in case of success,
        # or a Failure object
        def create(auction_params)
          ::Auctions::Actions::Create.call(params: auction_params)
        end

        # @param bid_params [Auctions::Api::DTO::BidParams] Params for the new bid
        # @return [Dry::Monads::Result<Auctions::Api::DTO::Bid, Failure>] Bid as DTO in case of success,
        # or a Failure object
        def place_bid(bid_params)
          ::Auctions::Actions::CreateBid.call(params: bid_params)
        end

        # @param auction_id [UUID] Id of the auction to finalize
        # @return [Dry::Monads::Result<Auctions::Api::DTO::Auction, Failure>] Auction with the winner_id as DTO
        # in case of success, or a Failure object
        def finalize(auction_id)
          ::Auctions::Actions::Finalize.call(auction_id: auction_id)
        end
      end
    end
  end
end
