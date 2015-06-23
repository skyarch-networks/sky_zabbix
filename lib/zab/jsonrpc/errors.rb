class Zab::Jsonrpc
  class Error < StandardError
    def initialize(body)
      @error = body['error']
      super(@error['message'])
    end
    attr_reader :error
  end
end
