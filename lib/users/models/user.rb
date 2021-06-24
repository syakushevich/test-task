# frozen_string_literal: true

module Users
  module Models
    class User < ActiveRecord::Base
      self.implicit_order_column = :created_at
    end
  end
end
