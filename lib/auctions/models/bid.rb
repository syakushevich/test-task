# frozen_string_literal: true

module Auctions
  module Models
    class Bid < ActiveRecord::Base
      self.implicit_order_column = :created_at

      belongs_to :auction

      validates :amount, numericality: { greater_than: 0 }
    end
  end
end
