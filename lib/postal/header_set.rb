module Postal
  class HeaderSet

    def initialize(headers)
      @headers = headers
    end

    def [](name)
      @headers[name.to_s.downcase]
    end

    def has_key?(key)
      @headers.has_key?(name.to_s.downcase)
    end

    def method_missing(*args, &block)
      @headers.send(*args, &block)
    end

  end
end
