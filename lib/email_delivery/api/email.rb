# frozen_string_literal: true

module EmailDelivery
  module Api
    class Email
      class << self
        # @param email_address [String] Email address for the message
        # @param subject [String] Subject of the message
        # @param variables [Hash] Variables to be used in the template (f.e. name, shipping_address)
        def deliver(email_address, subject, variables)
          ::EmailDelivery::Actions::Deliver.call(email_address: email_address, subject: subject, variables: variables)
        end
      end
    end
  end
end
