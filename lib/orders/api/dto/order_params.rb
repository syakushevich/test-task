# frozen_string_literal: true

module Orders
  module Api
    module DTO
      class OrderParams < Dry::Struct
        attribute :auction_id, Types::UUID
        attribute :buyer_id, Types::UUID
        attribute :total_payment, Types::Decimal
      end
    end
  end
end
