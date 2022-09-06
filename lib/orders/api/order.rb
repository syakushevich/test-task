# frozen_string_literal: true

module Orders
  module Api
    class Order
      class << self
        # @param order_params [Orders::Api::DTO::OrderParams] Params for new order
        # @return [Dry::Monads::Result<Orders::Api::DTO::Order, Failure>] Order as DTO in case of success,
        # or a Failure object
        def create(order_params)
          ::Orders::Actions::Create.call(params: order_params)
        end

        # @param order_id [UUID] Id of the order to update
        # @param value [String] Shipping method
        # @return [Dry::Monads::Result<Orders::Api::DTO::Order, Failure>] Order as DTO in case of success,
        # or a Failure object
        def update_shipping_method(order_id, value)
          ::Orders::Actions::Update.call(order_id: order_id, shipping_method: value)
        end

        # @param order_id [UUID] Id of the order to update
        # @param value [String] Payment method
        # @return [Dry::Monads::Result<Orders::Api::DTO::Order, Failure>] Order as DTO in case of success,
        # or a Failure object
        def update_payment_method(order_id, value)
          ::Orders::Actions::Update.call(order_id: order_id, payment_method: value)
        end

        # @param order_id [UUID] Id of the order to update
        # @return [Dry::Monads::Result<Orders::Api::DTO::Order, Failure>] Order as DTO in case of success,
        # or a Failure object
        def ship(order_id)
          ::Orders::Actions::Ship.call(order_id: order_id)
        end
      end
    end
  end
end
