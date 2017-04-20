module Postal
  class Config

    def host
      @host || ENV['POSTAL_HOST'] || raise(Error, "Host has not been configured. Set it using the `Postal.configure` block or use `POSTAL_HOST` environment variable.")
    end
    attr_writer :host

    def server_key
      @server_key || ENV['POSTAL_KEY'] || raise(Error, "Server key has not been configured. Set it using the `Postal.configure` block or use `POSTAL_KEY` environment variable.")
    end
    attr_writer :server_key

  end
end
