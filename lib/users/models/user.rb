# frozen_string_literal: true

module Users
  module Models
    class User < ActiveRecord::Base
      include Shared::Concerns::Uuid

      has_one :shipping_address
    end
  end
end
