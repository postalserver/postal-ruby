require 'postal/error'
require 'postal/header_set'
require 'postal/attachment'

module Postal
  class Message

    #
    # Find a specific messsage with the given scope
    #
    def self.find_with_scope(scope, id)
      api = scope.client.moonrope.messages.message(:id => id.to_i, :_expansions => scope.expansions)
      if api.success?
        Message.new(scope.client, api.data)
      elsif api.status == 'error' && api.data['code'] == 'MessageNotFound'
        raise MessageNotFound.new(id)
      else
        raise Error, "Couldn't load message from API (#{api.data})"
      end
    end

    #
    # If methods are called directly on the Message class, we likely want to see if we can
    # run them through the global client message scope.
    #
    def self.method_missing(name, *args, &block)
      if MessageScope.instance_methods(false).include?(name)
        Postal::Client.instance.messages.send(name, *args, &block)
      else
        super
      end
    end

    #
    # Initialize a new message object with the client and a set of initial attributes.
    #
    def initialize(client, attributes)
      @client = client
      @attributes = attributes
    end

    #
    # Return the message ID
    #
    def id
      @attributes['id']
    end

    #
    # Return the message token
    #
    def token
      @attributes['token']
    end

    #
    # Set a has of all the attributes from the API that should be exposed through
    # the Message class.
    #
    ATTRIBUTES = {
      :status => [:status, :status],
      :last_delivery_attempt => [:status, :last_delivery_attempt, :timestamp],
      :held? => [:status, :held, :boolean],
      :hold_expiry => [:status, :hold_expiry, :timestamp],
      :rcpt_to => [:details, :rcpt_to],
      :mail_from => [:details, :mail_from],
      :subject => [:details, :subject],
      :message_id => [:details, :message_id],
      :timestamp => [:details, :timestamp, :timestamp],
      :direction => [:details, :direction],
      :size => [:details, :size],
      :bounce? => [:details, :bounce, :boolean],
      :bounce_for_id => [:details, :bounce],
      :tag => [:details, :tag],
      :received_with_ssl? => [:details, :received_with_ssl, :boolean],
      :inspected? => [:inspection, :inspected, :boolean],
      :spam? => [:inspection, :spam, :boolean],
      :spam_score => [:inspection, :spam_score],
      :threat? => [:inspection, :thret, :boolean],
      :threat_details => [:inspection, :threat_details],
      :plain_body => [:plain_body],
      :html_body => [:html_body],
    }

    #
    # Catch calls to any of the default attributes for a message and return the
    # data however we'd like it
    #
    def method_missing(name, *args, &block)
      if mapping = ATTRIBUTES[name.to_sym]
        expansion, attribute, type = mapping
        value = from_expansion(expansion, attribute)
        case type
        when :timestamp
          value ? Time.at(value) : nil
        when :boolean
          value == 1
        else
          value
        end
      else
        super
      end
    end

    #
    # Return a set of headers which can be queried like a hash however looking up
    # values using [] will be case-insensitive.
    #
    def headers
      @headers ||= HeaderSet.new(from_expansion(:headers))
    end

    #
    # Return an array of attachment objects
    #
    def attachments
      @attachments ||= from_expansion(:attachments).map do |a|
        Attachment.new(a)
      end
    end

    #
    # Return the full raw message
    #
    def raw_message
      @raw_message ||= Base64.decode64(from_expansion(:raw_message))
    end

    private

    def from_expansion(expansion, attribute = nil, loaded = false)
      if @attributes.has_key?(expansion.to_s) || loaded
        attribute ? @attributes[expansion.to_s][attribute.to_s] : @attributes[expansion.to_s]
      else
        load_expansions(expansion)
        from_expansion(expansion, attribute, true)
      end
    end

    def load_expansions(*names)
      puts "\e[31mLoading expansion #{names}\e[0m"
      api = @client.moonrope.messages.message(:id => self.id, :_expansions => names)
      if api.success?
        names.each do |expansion_name|
          if api.data.has_key?(expansion_name.to_s)
            @attributes[expansion_name.to_s] = api.data[expansion_name.to_s]
          end
        end
      else
        raise Postal::Error, "Couldn't load expansion data (#{names.join(', ')}) for message ID '#{self.id}'"
      end
    end

  end
end
