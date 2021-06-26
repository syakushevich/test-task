# frozen_string_literal: true

module EmailDelivery
  module Actions
    class Deliver
      class << self
        def call(**kwargs)
          new(**kwargs).call
        end
      end

      def initialize(email_address:, subject:, variables:)
        @email_address = email_address
        @subject = subject
        @variables = variables
      end

      # Temporarily simulating an expensive email delivery action
      def call
        sleep(5)
      end

      private

      attr_reader :email_address, :subject, :variables
    end
  end
end
