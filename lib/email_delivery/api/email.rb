# frozen_string_literal: true

module EmailDelivery
  module Api
    class Email
      def deliver(_email_address, _subject, _content)
        sleep(5)
      end
      class << self
        # @param email_address [String] Email address for the message
        # @param subject [String] Subject of the message
        # @param content [String] Body of the message
        def deliver(email_address, subject, content)
          ::EmailDelivery::Actions::Deliver.call(email_address: email_address, subject: subject, content: content)
        end
      end
    end
  end
end
