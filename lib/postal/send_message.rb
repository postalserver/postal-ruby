require 'base64'
require 'postal/send_result'

module Postal
  class SendMessage

    def initialize(client)
      @client = client
      @attributes = {}
    end

    def send!
      api = @client.moonrope.request(:send, :message, @attributes)
      if api.success?
        SendResult.new(@client, api.data)
      elsif api.status == 'error'
        raise SendError.new(api.data['code'], api.data['message'])
      else
        raise Error, "Couldn't send message"
      end
    end

    def from(address)
      @attributes[:from] = address
    end

    def sender(address)
      @attributes[:sender] = address
    end

    def to(*addresses)
      @attributes[:to] ||= []
      @attributes[:to] += addresses
    end

    def cc(*addresses)
      @attributes[:cc] ||= []
      @attributes[:cc] += addresses
    end

    def bcc(*addresses)
      @attributes[:bcc] ||= []
      @attributes[:bcc] += addresses
    end

    def subject(subject)
      @attributes[:subject] = subject
    end

    def tag(tag)
      @attributes[:tag] = tag
    end

    def reply_to(reply_to)
      @attributes[:reply_to] = reply_to
    end

    def plain_body(content)
      @attributes[:plain_body] = content
    end

    def html_body(content)
      @attributes[:html_body] = content
    end

    def header(key, value)
      @attributes[:headers] ||= {}
      @attributes[:headers][key.to_s] = value
    end

    def attach(filename, content_type, data)
      @attributes[:attachments] ||= []
      @attributes[:attachments] << {
        :name => filename,
        :content_type => content_type,
        :data => Base64.encode64(data)
      }
    end

  end
end
