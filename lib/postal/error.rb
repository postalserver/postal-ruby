module Postal

  #
  # A generic error that all errors will inherit from
  #
  class Error < StandardError
  end

  #
  # Raised when a message cannot be found by its ID
  #
  class MessageNotFound < Error
    def initialize(id)
      @id = id
    end

    def message
      "No message found matching ID '#{@id}'"
    end

    def to_s
      message
    end
  end

  #
  # Raised when a message cannot be found by its ID
  #
  class SendError < Error
    def initialize(code, error_message)
      @code = code
      @error_message = error_message
    end

    attr_reader :code
    attr_reader :error_message

    def message
      "[#{@code}] #{@error_message}"
    end

    def to_s
      message
    end
  end

end
