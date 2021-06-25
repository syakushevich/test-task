# frozen_string_literal: true

module Orders
  module Models
    class Order < ActiveRecord::Base
      include Shared::Concerns::Uuid

      validates :reference_number, presence: true
      validates :total_payment, numericality: { greater_than: 0 }
      validates :shipping_method, length: { minimum: 1, allow_nil: true }
      validates :payment_method, length: { minimum: 1, allow_nil: true }
      validates :status, inclusion: { in: Orders::Api::DTO::Order::Status.values }
    end
  end
end
