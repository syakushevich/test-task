# frozen_string_literal: true

module Auctions
  module Models
    class Auction < ActiveRecord::Base
      has_many :bids

      before_create :set_initial_status

      validate :validate_finishes_in_future, on: :create

      def close
        self.status = "closed"
        self.winner_id = bids.where("amount = (:max)", max: bids.select("max(amount)")).first.bidder_id
      end

      private

      def set_initial_status
        self.status = "open"
      end

      def validate_finishes_in_future
        return unless finishes_at < Time.now

        errors.add(:finishes_at, "must be in the future")
      end
    end
  end
end
