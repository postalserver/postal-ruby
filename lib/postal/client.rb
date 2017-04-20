require 'moonrope_client'
require 'postal/message_scope'
require 'postal/send_message'
require 'postal/send_raw_message'

module Postal
  class Client

    #
    # Create and cache a global instance of client based on the environment variables
    # which can be provided. In 90% of cases, Postal will be accessed through this.
    #
    def self.instance
      @instance ||= Client.new(Postal.config.host, Postal.config.server_key)
    end

    #
    # Initialize a new client with the host and API key
    #
    def initialize(host, server_key)
      @host = host
      @server_key = server_key
    end

    #
    # Provide a scope to access messages
    #
    def messages
      MessageScope.new(self)
    end

    #
    # Send a message
    #
    def send_message(&block)
      message = SendMessage.new(self)
      block.call(message)
      message.send!
    end

    #
    # Send a raw message
    #
    def send_raw_message(&block)
      message = SendRawMessage.new(self)
      block.call(message)
      message.send!
    end

    #
    # Return the backend moonrope instance for this client
    #
    def moonrope
      @moonrope ||= begin
        headers= {'X-Server-API-Key' => @server_key}
        MoonropeClient::Connection.new(@host, :headers => headers, :ssl => true)
      end
    end

  end
end
