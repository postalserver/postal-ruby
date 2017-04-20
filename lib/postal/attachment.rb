require 'base64'

module Postal
  class Attachment

    def initialize(attributes)
      @attributes = attributes
    end

    def filename
      @attributes['filename']
    end

    def content_type
      @attributes['content_type']
    end

    def size
      @attributes['size']
    end

    def hash
      @attributes['hash']
    end

    def data
      @data ||= Base64.decode64(@attributes['data'])
    end

  end
end
