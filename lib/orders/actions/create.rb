# frozen_string_literal: true

module Orders
  module Actions
    class Create
      include Dry::Monads[:result]

      class << self
        def call(**kwargs)
          new(**kwargs).call
        end
      end

      def initialize(params:)
        @params = params
      end

      def call
        order = Orders::Models::Order.create(order_params)

        if order.errors.empty?
          Success(Orders::Api::DTO::Order.new(order.order_params))
        else
          Failure({ code: :order_not_created, details: order.errors.to_hash })
        end
      end

      private

      attr_reader :params

      def order_params
        params.to_h.merge(
          status: "draft",
          reference_number: generate_reference_number
        )
      end

      def generate_reference_number
        "#{Time.now.strftime("%y%m%d")}_#{SecureRandom.hex[..10]}"
      end
    end
  end
end
