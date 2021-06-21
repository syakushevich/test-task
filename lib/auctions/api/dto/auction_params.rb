# frozen_string_literal: true

module Auctions
  module Api
    module Dto
      class AuctionParams < Dry::Struct
        attribute :name, Types::String
        attribute :description, Types::String.optional.default(nil)
        attribute :creator_id, Types::Integer
        attribute :package_weight, Types::Float
        attribute :package_size_x, Types::Float
        attribute :package_size_y, Types::Float
        attribute :package_size_z, Types::Float
        attribute :finishes_at, Types::Time
      end
    end
  end
end
