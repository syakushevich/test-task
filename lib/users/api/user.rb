# frozen_string_literal: true

module Users
  module Api
    class User
      class << self
        # @param id [UUID] Id of the user to get
        # @return [Dry::Monads::Result<Users::Api::DTO::User, Failure>] User as DTO in case of success,
        # or a Failure object
        def get_by_id(id)
          ::Users::Actions::GetById.call(user_id: id)
        end
      end
    end
  end
end
