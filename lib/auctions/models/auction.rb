# frozen_string_literal: true

module Auctions
  module Models
    class Auction < ActiveRecord::Base
      include Shared::Concerns::Uuid

      has_many :bids

      before_validation :set_initial_status

      validates :status, inclusion: { in: Auctions::Api::DTO::Auction::Status.values }
      validate :validate_finishes_in_future, on: :create

      def close
        self.status = "closed"
      end

      private

      def set_initial_status
        self.status ||= "open"
      end

      def validate_finishes_in_future
        return unless finishes_at < Time.now

        errors.add(:finishes_at, "must be in the future")
      end
    end
  end
end
