# frozen_string_literal: true

module Auctions
  module Models
    class Bid < ActiveRecord::Base
      include Shared::Concerns::Uuid

      belongs_to :auction

      validates :amount, numericality: { greater_than: 0 }
    end
  end
end
