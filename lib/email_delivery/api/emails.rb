# frozen_string_literal: true

module EmailDelivery
  module Api
    class Emails
      def deliver(_email_address, _subject, _content)
        sleep(5)
      end
    end
  end
end
