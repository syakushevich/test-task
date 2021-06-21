# frozen_string_literal: true

module EmailDelivery
  module Actions
    class Deliver
      class << self
        def call(email_address:, subject:, content:)
          new(email_address, subject, content).call
        end
      end

      def initialize(email_address, subject, content)
        @email_address = email_address
        @subject = subject
        @content = content
      end

      # Temporarily simulating an expensive email delivery action
      def call
        sleep(5)
      end

      private

      attr_reader :email_address, :subject, :content
    end
  end
end
