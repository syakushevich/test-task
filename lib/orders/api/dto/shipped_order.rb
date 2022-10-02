# frozen_string_literal: true

module Orders
  module Api
    module DTO
      class ShippedOrder < Dry::Struct
        attribute :id, Types::UUID
        attribute :auction_id, Types::UUID
        attribute :buyer_id, Types::UUID
        attribute :reference_number, Types::String
        attribute :total_payment, Types::Decimal
        attribute :total_order_price, Types::Decimal.optional.default(nil)
        attribute :shipping_method, Types::String.optional.default(nil)
        attribute :payment_method, Types::String.optional.default(nil)
        attribute :status, Orders::Api::DTO::Order::Status
        attribute :city, Types::String
        attribute :zip, Types::String
        attribute :street_address, Types::String
      end
    end
  end
end
