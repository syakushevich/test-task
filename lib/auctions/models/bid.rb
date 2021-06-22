# frozen_string_literal: true

module Auctions
  module Models
    class Bid < ActiveRecord::Base
      belongs_to :auction

      validates :amount, numericality: { greater_than: 0 }
    end
  end
end
