# frozen_string_literal: true

require "dry/monads/do"

module Orders
  module Actions
    class Ship
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call, :fetch_shipping_address)

      class << self
        def call(**kwargs)
          new(**kwargs).call
        end
      end

      def initialize(order_id:)
        @order_id = order_id
      end

      def call
        order = yield fetch_order
        shipping_address = yield fetch_shipping_address(order)
        yield validate_complete_order(order)
        yield ship(order)

        Success(Orders::Api::DTO::ShippedOrder.new(shipping_params(order, shipping_address)))
      end

      private

      attr_reader :order_id

      def fetch_order
        order = Orders::Models::Order.find_by(id: order_id)

        order ? Success(order) : Failure({ code: :order_not_found })
      end

      def fetch_shipping_address(order)
        user = yield fetch_user(order)
        shipping_address = user.shipping_address

        shipping_address ? Success(shipping_address) : Failure({ code: :shipping_address_not_found })
      end
      
      def fetch_user(order)
        user = Users::Models::User.find_by_id(order.buyer_id)

        user ? Success(user) : Failure({ code: :user_not_found })
      end

      def validate_complete_order(order)
        if order.payment_method && order.shipping_method
          Success()
        else
          details = {
            payment_method: order.payment_method ? nil : ["is missing"],
            shipping_method: order.shipping_method ? nil : ["is missing"],
          }.compact

          Failure({ code: :order_not_shipped, details: details })
        end
      end

      def ship(order)
        order.status = "shipped"
        order.save

        if order.errors.empty?
          Success()
        else
          Failure({ code: :order_not_shipped, details: order.errors.to_hash })
        end
      end

      def shipping_params(order, shipping_address)
        order.order_params.merge(shipping_address.shipping_params)
      end
    end
  end
end
