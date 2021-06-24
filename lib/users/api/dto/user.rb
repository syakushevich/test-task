# frozen_string_literal: true

module Users
  module Api
    module Dto
      class User < Dry::Struct
        attribute :id, Types::Integer
        attribute :email, Types::String
      end
    end
  end
end
