# frozen_string_literal: true

module Users
  module Actions
    class GetById
      include Dry::Monads[:result]

      class << self
        def call(**kwargs)
          new(**kwargs).call
        end
      end

      def initialize(user_id:)
        @user_id = user_id
      end

      def call
        user = Users::Models::User.find_by(id: user_id)

        if user
          Success(Users::Api::Dto::User.from_active_record(user))
        else
          Failure({ code: :user_not_found })
        end
      end

      private

      attr_reader :user_id
    end
  end
end
