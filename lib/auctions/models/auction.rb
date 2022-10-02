# frozen_string_literal: true

module Auctions
  module Models
    class Auction < ActiveRecord::Base
      include Shared::Concerns::Uuid

      has_many :bids

      validates :status, inclusion: { in: Auctions::Api::DTO::Auction::Status.values }

      def dimensions
        package_size_x * package_size_y * package_size_z
      end
    end
  end
end
