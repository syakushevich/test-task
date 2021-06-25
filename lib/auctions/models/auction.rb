# frozen_string_literal: true

module Auctions
  module Models
    class Auction < ActiveRecord::Base
      include Shared::Concerns::Uuid

      has_many :bids

      validates :status, inclusion: { in: Auctions::Api::DTO::Auction::Status.values }
    end
  end
end
