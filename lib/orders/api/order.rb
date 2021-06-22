# frozen_string_literal: true

module Orders
  module Api
    class Order
      class << self
        # @param order_params [Orders::Api::DTO::OrderParams] Params for new order
        # @return [Dry::Monads::Result<Orders::Api::DTO::Order, Failure>] Order as Dto in case of success,
        # or a Failure object
        def create(order_params)
          ::Orders::Actions::Create.call(params: order_params)
        end
      end
    end
  end
end
