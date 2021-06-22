# frozen_string_literal: true

module Auctions
  module Api
    module Dto
      class BidParams < Dry::Struct
        attribute :bidder_id, Types::Integer
        attribute :auction_id, Types::Integer
        attribute :amount, Types::Float
      end
    end
  end
end
