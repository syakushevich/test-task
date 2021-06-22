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
        order = Orders::Models::Order.create(params.to_h)

        if order.errors.empty?
          Success(Orders::Api::Dto::Order.from_active_record(order))
        else
          Failure({ code: :order_not_created, details: order.errors.to_hash })
        end
      end

      private

      attr_reader :params
    end
  end
end
