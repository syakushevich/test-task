# frozen_string_literal: true

require "dry/monads/do"

module Auctions
  module Actions
    class Create
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      class << self
        def call(**kwargs)
          new(**kwargs).call
        end
      end

      def initialize(params:)
        @params = params
      end

      def call
        auction = yield create_auction

        schedule_finalizing(auction)

        Success(Auctions::Api::DTO::Auction.new(auction.attributes.symbolize_keys))
      end

      private

      attr_reader :params

      def create_auction
        auction = Auctions::Models::Auction.create(params.to_h)

        if auction.errors.empty?
          Success(auction)
        else
          Failure({ code: :auction_not_created, details: auction.errors.to_hash })
        end
      end

      def schedule_finalizing(auction)
        Auctions::Jobs::FinalizeAuction.perform_at(auction.finishes_at, auction.id)
      end
    end
  end
end
