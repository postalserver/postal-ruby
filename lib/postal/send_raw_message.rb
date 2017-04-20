require 'base64'
require 'postal/send_result'

module Postal
  class SendRawMessage

    def initialize(client)
      @client = client
      @attributes = {}
    end

    def send!
      api = @client.moonrope.request(:send, :raw, @attributes)
      if api.success?
        SendResult.new(@client, api.data)
      elsif api.status == 'error'
        raise SendError.new(api.data['code'], api.data['message'])
      else
        raise Error, "Couldn't send message"
      end
    end

    def mail_from(address)
      @attributes[:mail_from] = address
    end

    def rcpt_to(*addresses)
      @attributes[:rcpt_to] ||= []
      @attributes[:rcpt_to] += addresses
    end

    def data(data)
      @attributes[:data] = Base64.encode64(data)
    end

  end
end
