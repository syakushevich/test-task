# frozen_string_literal: true

module Auctions
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
        auction = Auctions::Models::Auction.create(params.to_h)

        if auction.errors.empty?
          Success(Auctions::Api::Dto::Auction.from_active_record(auction))
        else
          Failure({ code: :auction_not_created, details: auction.errors.to_hash })
        end
      end

      private

      attr_reader :params
    end
  end
end
