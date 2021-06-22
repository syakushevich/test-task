# frozen_string_literal: true

module Orders
  module Models
    class Order < ActiveRecord::Base
      before_create :set_initial_status

      validates :total_payment, numericality: { greater_than: 0 }
      validates :shipping_method, length: { minimum: 1, allow_nil: true }
      validates :payment_method, length: { minimum: 1, allow_nil: true }

      def ship
        self.status = "shipped"
      end

      private

      def set_initial_status
        self.status = "draft"
      end
    end
  end
end
