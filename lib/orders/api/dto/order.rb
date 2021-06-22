# frozen_string_literal: true

module Orders
  module Api
    module Dto
      class Order < Dry::Struct
        attribute :id, Types::Integer
        attribute :auction_id, Types::Integer
        attribute :total_payment, Types::Decimal | Types::Float
        attribute :shipping_method, Types::String.optional.default(nil)
        attribute :payment_method, Types::String.optional.default(nil)
        attribute :status, Types::String

        class << self
          def from_active_record(record)
            new(record.attributes.symbolize_keys)
          end
        end
      end
    end
  end
end
