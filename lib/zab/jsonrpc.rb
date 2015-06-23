require 'json'
require 'net/http'
require 'uri'

class Zab::Jsonrpc
  VERSION = '2.0' # json-rpc version
  class Error < StandardError
    def initialize(body)
      @error = JSON.parse(body)['error']
      super(@error['message'])
    end
    attr_reader :error
  end

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
    # TODO: parse
    case resp
    when Net::HTTPSuccess
      return JSON.parse(resp.body)['result']
    else
      raise Error.new(resp.body)
    end
  end

  private

  def body(method, params, id: true)
    res = {
      jsonrpc: VERSION,
      method:  method,
      params:  params,
      auth: nil,
    }
    res['id'] = id_gen if id

    return res
  end

  def id_gen
    return rand(10**12)
  end
end
