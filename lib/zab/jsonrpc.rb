require 'json'
require 'net/http'
require 'uri'

class Zab::Jsonrpc
  VERSION = '2.0' # json-rpc version

  def initialize(uri)
    @uri = uri
  end

  def post(method, params, id: true)
    uri = URI.parse(@uri)
    req = Net::HTTP::Post.new(uri.path)
    req['Content-Type'] = 'application/json-rpc'
    req.body = JSON.generate(body(method, params, id: id))

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    resp = http.request(req)
    body = JSON.parse(resp.body)
    case resp
    when Net::HTTPSuccess
      raise Error.new(body) if body['error']
      return body['result']
    else
      raise Error.new(body)
    end
  end


  private

  def body(method, params, id: true, auth: nil)
    res = {
      jsonrpc: VERSION,
      method:  method,
      params:  params,
      auth:    auth,
    }
    res['id'] = id_gen if id

    return res
  end

  def id_gen
    return rand(10**12)
  end
end

require_relative 'jsonrpc/errors'
