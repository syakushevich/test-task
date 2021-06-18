# frozen_string_literal: true

module Users
  module Api
    class User
      class << self
        # @param params [Integer] Id of the user to get
        # @return [Dry::Monads::Result<Users::Api::DTO::User, Failure User as Dto in case of success, or a Failure object
        def get_by_id(id)
          ::Users::Actions::GetById.call(id)
        end
      end
    end
  end
end
