# frozen_string_literal: true

module Auctions
  module Jobs
    class FinalizeAuction
      include Sidekiq::Worker

      def perform(auction_id)
        ::Auctions::Actions::Finalize.call(auction_id: auction_id)
      end
    end
  end
end
