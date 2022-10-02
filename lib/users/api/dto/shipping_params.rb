# frozen_string_literal: true

module Users
  module Api
    module DTO
      class ShippingParams < Dry::Struct
        attribute :city, Types::String
        attribute :zip, Types::String
        attribute :street_address, Types::String
      end
    end
  end
end
