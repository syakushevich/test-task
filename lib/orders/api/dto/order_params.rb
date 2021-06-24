# frozen_string_literal: true

module Orders
  module Api
    module Dto
      class OrderParams < Dry::Struct
        attribute :auction_id, Types::UUID
        attribute :total_payment, Types::Float
      end
    end
  end
end
