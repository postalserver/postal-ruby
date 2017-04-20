require 'postal/client'
require 'postal/config'

module Postal

  def self.config
    @config ||= Config.new
  end

  def self.configure(&block)
    block.call(config)
  end

  def self.send_message(&block)
    Postal::Client.instance.send_message(&block)
  end

  def self.send_raw_message(&block)
    Postal::Client.instance.send_raw_message(&block)
  end

end
