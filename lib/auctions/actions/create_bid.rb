# frozen_string_literal: true

module Auctions
  module Actions
    class CreateBid
      include Dry::Monads[:result]

      class << self
        def call(params:)
          new(params).call
        end
      end

      def initialize(params)
        @params = params
      end

      def call
        bid = Auctions::Models::Bid.create(params.to_h)

        if bid.errors.empty?
          Success(Auctions::Api::Dto::Bid.from_active_record(bid))
        else
          Failure({ code: :bid_not_created, details: bid.errors.to_hash })
        end
      end

      private

      attr_reader :params
    end
  end
end
