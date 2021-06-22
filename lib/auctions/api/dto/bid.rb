# frozen_string_literal: true

module Auctions
  module Api
    module Dto
      class Bid < Dry::Struct
        attribute :id, Types::Integer
        attribute :bidder_id, Types::Integer
        attribute :auction_id, Types::Integer
        attribute :amount, Types::Float

        class << self
          def from_active_record(record)
            new(record.attributes.symbolize_keys)
          end
        end
      end
    end
  end
end
