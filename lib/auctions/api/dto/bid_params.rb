# frozen_string_literal: true

module Auctions
  module Api
    module DTO
      class BidParams < Dry::Struct
        attribute :bidder_id, Types::UUID
        attribute :auction_id, Types::UUID
        attribute :amount, Types::Float
      end
    end
  end
end
