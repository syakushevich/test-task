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

        # @param shipping_params [Users::Api::DTO::ShippingParams] Params for new shipping address
        # @return [Dry::Monads::Result<Users::Api::DTO::ShippingAddress, Failure>] ShippingAddress as DTO in case of success,
        # or a Failure object
        def update_shipping_address(id, shipping_params)
          ::Users::Actions::UpdateShippingAddress.call(user_id: id, params: shipping_params)
        end
      end
    end
  end
end
