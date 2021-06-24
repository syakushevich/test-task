# frozen_string_literal: true

module Users
  module Api
    module Dto
      class User < Dry::Struct
        attribute :id, Types::UUID
        attribute :email, Types::String
      end
    end
  end
end
