# frozen_string_literal: true

module Auctions
  module Api
    module Dto
      class Auction < Dry::Struct
        attribute :id, Types::Integer
        attribute :name, Types::String
        attribute :description, Types::String.optional.default(nil)
        attribute :creator_id, Types::Integer
        attribute :package_weight, Types::Float
        attribute :package_size_x, Types::Float
        attribute :package_size_y, Types::Float
        attribute :package_size_z, Types::Float
        attribute :finishes_at, Types::Time
        attribute :status, Types::String
        attribute :winner_id, Types::Integer.optional.default(nil)
      end
    end
  end
end
