# frozen_string_literal: true

module Auctions
  module Jobs
    class FinalizeAuction
      include Sidekiq::Worker

      def perform(auction_id)
        ::Auctions::Api::Auction.finalize(auction_id)
      end
    end
  end
end
