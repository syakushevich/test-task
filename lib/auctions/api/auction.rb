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
      end
    end
  end
end
