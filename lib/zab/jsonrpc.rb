require 'json'
require 'net/http'
require 'uri'

class Zab::Jsonrpc
  VERSION = '2.0' # json-rpc version

  def initialize(uri, logger: nil)
    @uri = uri
    @logger = logger
  end

  # @param [String] method is json-rpc method name.
  # @param [Any?] params is json-rpc parameters.
  # @param [Boolean] notification
  # @param [String|NilClass] auth is authorization token.
  def post(method, params, notification: false, auth: nil)
    request(build(method, params, notification: notification, auth: auth))
  end

  # @param [Hash{String => Any}] builded is result of 'build' method.
  # @return [Any?] return result of response
  def request(builded)
    uri = URI.parse(@uri)

    resp = do_req(uri, builded)

    return nil unless builded[:id] # when notification

    # Parse and error handling
    body = JSON.parse(resp.body)
    raise Error.new(body) if body['error']

    return body['result']
  end

  # XXX: エラー処理はこれでいい?
  # @example Return values.
  #   rpc.batch(
  #     rpc.build('a', 'A'),
  #     rpc.build('b', 'B', notification: true),
  #     rpc.build('c', 'Invalid Param'),
  #   ) # => [{value: 'response of A'}, nil, Jsonrpc::Error]
  # @param [Array<Hash>] buildeds is Array of result of 'build' method.
  # @return [Array<Any|Error|nil>]
  def batch(buildeds)
    uri = URI.parse(@uri)
    resp = do_req(uri, buildeds)
    body = JSON.parse(resp.body)

    result = []
    buildeds.each do |b|
      id = b[:id]
      a = body.find{|x|x['id'] == id}

      r =
        if a.nil?
          nil
        elsif a['error']
          Error.new(a)
        else
          a['result']
        end
      result.push(r)
    end
    return result
  end

  # @param [String] method is json-rpc method name.
  # @param [Any?] params is json-rpc parameters.
  # @param [Boolean] notification
  # @param [String|NilClass] auth is authorization token.
  def build(method, params, notification: false, auth: nil)
    res = {
      jsonrpc: VERSION,
      method:  method,
      params:  params,
      auth:    auth,
    }
    res[:id] = id_gen unless notification

    return res
  end


  private
  def id_gen
    return rand(10**12)
  end

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

    @logger.info("[Zab #{resp.code} #{sec}] #{msg_body}")
  end
end

require_relative 'jsonrpc/errors'
