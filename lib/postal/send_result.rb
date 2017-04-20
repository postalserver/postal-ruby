module Postal
  class SendResult

    def initialize(client, result)
      @client = client
      @result = result
    end

    def message_id
      @result['message_id']
    end

    def recipients
      @recipients ||= begin
        @result['messages'].each_with_object({}) do |(recipient, message_details), hash|
          hash[recipient.to_s.downcase] = Message.new(@client, message_details)
        end
      end
    end

    def [](recipient)
      recipients[recipient.to_s.downcase]
    end

    def size
      recipients.size
    end

  end
end
