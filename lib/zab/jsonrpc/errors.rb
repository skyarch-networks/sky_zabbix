class Zab::Jsonrpc::Error < StandardError
  def initialize(body)
    @error = body['error']
    msg = "#{@error['message']} #{@error['data']}"
    super(msg)
  end
  attr_reader :error

  class ParseError     < self; end # Invalid JSON was received by the server. An error occurred on the server while parsing the JSON text.
  class InvalidRequest < self; end # The JSON sent is not a valid Request object.
  class MethodNotFound < self; end # The method does not exist / is not available.
  class InvalidParams  < self; end # Invalid method parameter(s).
  class InternalError  < self; end # Internal JSON-RPC error.
  class ServerError    < self; end # Reserved for implementation-defined server-errors.

  def self.create(body)
    klass =
      case body['code']
      when -32700;         ParseError
      when -32600;         InvalidRequest
      when -32601;         MethodNotFound
      when -32602;         InvalidParams
      when -32603;         InternalError
      when -32099..-32000; ServerError
      else;                self
      end
    klass.new(body)
  end
end
