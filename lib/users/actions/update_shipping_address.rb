# frozen_string_literal: true

require "dry/monads/do"

module Users
  module Actions
    class UpdateShippingAddress
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      class << self
        def call(**kwargs)
          new(**kwargs).call
        end
      end

      def initialize(user_id:, params:)
        @user_id = user_id
        @params = params
      end

      def call
        user = yield fetch_user
        shipping_address = yield update_shipping_address(user)

        Success(Users::Api::DTO::ShippingAddress.new(shipping_address.attributes.symbolize_keys))
      end

      private

      def fetch_user
        user = Users::Models::User.find_by(id: user_id)

        user ? Success(user) : Failure({ code: :user_not_found })
      end

      def update_shipping_address(user)
        shipping_address = Users::Models::ShippingAddress.find_or_initialize_by(user_id: user.id)
        shipping_address.assign_attributes(city: params[:city], 
                                           zip: params[:zip], 
                                           street_address: params[:street_address])
        shipping_address.save

        if shipping_address.errors.empty?
          Success(shipping_address)
        else
          Failure({ code: :shipping_address_not_valid, details: shipping_address.errors.to_hash })
        end
      end

      attr_reader :user_id, :params
    end
  end
end
