require 'json'
require 'net/http'
require 'uri'

class Zab::Jsonrpc
  VERSION = '2.0' # json-rpc version

  def initialize(uri)
    @uri = uri
  end

  def post(method, params, notification: false)
    request(build(method, params, notification: notification))
  end

  # @param [Hash{String => Any}] builded is result of 'build' method.
  # @return [Any?] return response['result']
  def request(builded)
    uri = URI.parse(@uri)

    req  = req_gen(uri, builded)
    resp = do_req(uri, req)

    # Parse and error handling
    body = JSON.parse(resp.body)
    raise Error.new(body) if body['error']

    return body['result']
  end

  # XXX: エラー処理はこれでいい?
  # TODO: notification がある場合、直感に反する返り方をすると思う。idを見て返したい
  # @param [Array<Hash>] buildeds is Array of result of 'build' method.
  # @return [Array<Any|Error>]
  def batch(buildeds)
    uri = URI.parse(@uri)
    req  = req_gen(uri, buildeds)
    resp = do_req(uri, req)
    body = JSON.parse(resp.body)
    body.map do |r|
      if r['error']
        Error.new(r)
      else
        r['result']
      end
    end
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

  def req_gen(uri, body)
    req = Net::HTTP::Post.new(uri.path)
    req['Content-Type'] = 'application/json-rpc'
    req.body = JSON.generate(body)
    return req
  end

  def do_req(uri, req)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    resp = http.request(req) # TODO: ここでのエラーハンドリング
    unless resp.is_a? Net::HTTPSuccess
      raise Error(resp.body)
    end
    return resp
  end
end

require_relative 'jsonrpc/errors'
