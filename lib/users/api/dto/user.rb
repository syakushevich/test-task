# frozen_string_literal: true

module Users
  module Api
    module DTO
      class User < Dry::Struct
        attribute :id, Types::Integer
        attribute :email, Types::String

        class << self
          def from_active_record(record)
            new(
              id: record.id,
              email: record.email
            )
          end
        end
      end
    end
  end
end
