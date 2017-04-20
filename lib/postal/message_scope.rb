require 'postal/message'

module Postal
  class MessageScope

    attr_reader :client

    def initialize(client)
      @client = client
      @includes = []
    end

    #
    # Add includes to the scope
    #
    def includes(*includes)
      @includes.push(*includes)
      self
    end

    #
    # Return the current includes
    #
    def expansions
      if @includes.include?(:all)
        true
      else
        @includes.map(&:to_s)
      end
    end

    #
    # Find a given message by its ID
    #
    def find_by_id(id)
      Message.find_with_scope(self, id)
    end

  end
end
