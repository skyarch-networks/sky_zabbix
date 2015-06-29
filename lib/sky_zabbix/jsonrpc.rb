require 'json'
require 'net/http'
require 'uri'

class SkyZabbix::Jsonrpc
  VERSION = '2.0' # json-rpc version

  def initialize(uri, logger: nil)
    @uri = uri
    @logger = logger
  end

  attr_accessor :token

  # Send normal request.
  # @param [String] method is json-rpc method name.
  # @param [Any?] params is json-rpc parameters.
  # @param [Boolean] notification
  def post(method, params, notification: false)
    request(build(method, params, notification: notification))
  end

  # Send batch request.
  # @example Return values.
  #   rpc.batch(
  #     rpc.build('a', 'A'),
  #     rpc.build('b', 'B', notification: true),
  #     rpc.build('c', 'C'),
  #   ) # => [{value: 'response of A'}, nil, {value: 'response of A'}]
  # @example Raise error.
  #   rpc.batch(
  #     rpc.build('a', 'A'),
  #     rpc.build('b', 'B', notification: true),
  #     rpc.build('c', 'Invalid Params'),
  #   ) # => Error::BatchError.
  #   #  Can get response of 'a' from ex.result
  # @param [Array<Hash>] buildeds is Array of result of 'build' method.
  # @return [Array<Any|nil>]
  # @raise [Error::BatchError]
  def batch(buildeds)
    uri = URI.parse(@uri)
    resp = do_req(uri, buildeds)
    body = JSON.parse(resp.body)

    result = []
    errors = []
    buildeds.each do |b|
      id = b[:id]
      a = body.find{|x|x['id'] == id}

      r =
        if a.nil?
          nil
        elsif a['error']
          errors.push(Error.new(a))
          nil
        else
          a['result']
        end
      result.push(r)
    end

    unless errors.empty?
      raise Error::BatchError.new(errors, result)
    end
    return result
  end

  # @param [String] method is json-rpc method name.
  # @param [Any?] params is json-rpc parameters.
  # @param [Boolean] notification
  # @return [Hash{Symbol => Any}]
  def build(method, params, notification: false)
    res = {
      jsonrpc: VERSION,
      method:  method,
      params:  params,
      auth:    @token,
    }
    res[:id] = id_gen unless notification

    return res
  end


  private

  # @param [Hash{String => Any}] builded is result of 'build' method.
  # @return [Any?] return result of response
  def request(builded)
    uri = URI.parse(@uri)

    resp = do_req(uri, builded)

    return nil unless builded[:id] # when notification

    # Parse and error handling
    body = JSON.parse(resp.body)
    raise Error.create(body) if body['error']

    return body['result']
  end

  # @return [Integer] random ID.
  def id_gen
    return rand(10**12)
  end

  # @param [URI::HTTP] uri is a URI of Zabbix Server.
  # @param [Hash|Array] body is a request body.
  def do_req(uri, body)
    start_time = Time.now # for logging

    # Create request
    req = Net::HTTP::Post.new(uri.path)
    req['Content-Type'] = 'application/json-rpc'
    req.body = JSON.generate(body)

    # Do HTTP Request
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    resp = http.request(req) # TODO: ここでのエラーハンドリング
    unless resp.is_a? Net::HTTPSuccess
      raise Error(resp.body)
    end
    return resp

  ensure
    logging_request(start_time, body, resp)
  end

  # TODO: log level
  # @param [Time] start_time
  # @param [Hash|Array] body is request body.
  # @param [Net::HTTPResponse] resp
  def logging_request(start_time, body, resp)
    return unless @logger

    sec = Time.now - start_time
    msg_body =
      if body.is_a? Array # when batch
        y = body.map{|x| "#{x[:method]}(#{x[:params]})"}
        "Batch Request [#{y.join(', ')}]"
      else
        "#{body[:method]}(#{body[:params]})"
      end

    @logger.info("[SkyZabbix #{resp.code} #{sec}] #{msg_body}")
  end
end

require_relative 'jsonrpc/errors'
