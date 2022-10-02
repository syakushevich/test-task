# frozen_string_literal: true

module Users
  module Models
    class ShippingAddress < ActiveRecord::Base
      include Shared::Concerns::Uuid

      validates :city, presence: true
      validates :zip, presence: true
      validates :street_address, presence: true

      belongs_to :user

      def shipping_params
        { city: city, zip: zip, street_address: street_address }
      end
    end
  end
end
