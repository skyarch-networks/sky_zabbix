class SkyZabbix::Jsonrpc::Error < StandardError
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

  class BatchError < StandardError
    # @param [Array<Error>] errors is list of error.
    # @param [Array<Any>] result is list of response.
    def initialize(errors, result)
      @errors = errors
      @result = result
    end
    attr_reader :errors, :result

    # @return [String] error message
    def message
      return errors.map(&:message).join(', ')
    end

    # @param [Array<Hash<String => Any>] body is response body.
    # @return [Boolean]
    def self.error?(body)
      return body.any?{|x|x['error']}
    end
  end
end
