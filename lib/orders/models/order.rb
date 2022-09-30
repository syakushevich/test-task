# frozen_string_literal: true

module Orders
  module Models
    class Order < ActiveRecord::Base
      require 'net/http'
      include Shared::Concerns::Uuid

      validates :reference_number, presence: true
      validates :total_payment, numericality: { greater_than: 0 }
      validates :shipping_method, length: { minimum: 1, allow_nil: true }
      validates :payment_method, length: { minimum: 1, allow_nil: true }
      validates :status, inclusion: { in: Orders::Api::DTO::Order::Status.values }

      belongs_to :auction, class_name: 'Auctions::Models::Auction'

      def order_params
        attributes.merge(total_order_price: total_order_price).symbolize_keys
      end

      private

      def total_order_price
        total_payment + shipping_cost
      end

      def shipping_cost
        return send(Orders::Api::DTO::Order::ShippingMethods[shipping_method]) if shipping_method
        0
      end

      def fedyx
        auction.package_weight.ceil * 2
      end

      def upz
        auction.dimensions * JSON.parse(Net::HTTP.get(URI('https://api.chucknorris.io/jokes/random')))['value'].length
      end
    end
  end
end
