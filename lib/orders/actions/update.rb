# frozen_string_literal: true

require "dry/monads/do"

module Orders
  module Actions
    class Update
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      class << self
        def call(**kwargs)
          new(**kwargs).call
        end
      end

      def initialize(order_id:, shipping_method: nil, payment_method: nil)
        @order_id = order_id
        @shipping_method = shipping_method
        @payment_method = payment_method
      end

      def call
        order = yield fetch_order
        yield update(order)

        Success(Orders::Api::Dto::Order.from_active_record(order))
      end

      private

      attr_reader :order_id, :shipping_method, :payment_method

      def fetch_order
        order = Orders::Models::Order.find_by(id: order_id)

        order ? Success(order) : Failure({ code: :order_not_found })
      end

      def update(order)
        order.update(update_params)

        if order.errors.empty?
          Success(order)
        else
          Failure({ code: :order_not_updated, details: order.errors.to_hash })
        end
      end

      def update_params
        {
          shipping_method: shipping_method,
          payment_method: payment_method
        }.compact
      end
    end
  end
end
