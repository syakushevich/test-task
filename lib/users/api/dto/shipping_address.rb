# frozen_string_literal: true

module Users
  module Api
    module DTO
      class ShippingAddress < Dry::Struct
        attribute :id, Types::UUID
        attribute :user_id, Types::UUID
        attribute :city, Types::String
        attribute :zip, Types::String
        attribute :street_address, Types::String
      end
    end
  end
end
