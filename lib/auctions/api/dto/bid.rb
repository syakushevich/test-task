# frozen_string_literal: true

module Auctions
  module Api
    module DTO
      class Bid < Dry::Struct
        attribute :id, Types::UUID
        attribute :bidder_id, Types::UUID
        attribute :auction_id, Types::UUID
        attribute :amount, Types::Decimal
      end
    end
  end
end
