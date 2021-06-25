# frozen_string_literal: true

module Shared
  module Concerns
    module Uuid
      extend ActiveSupport::Concern

      included do
        self.implicit_order_column = :created_at

        before_create :generate_uuid

        def generate_uuid
          self.id = SecureRandom.uuid
        end
      end
    end
  end
end
