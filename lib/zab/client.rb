class Zab::Client
  @class = nil # Should override by sub class.

  def self.zbx_class
    return @class
  end

  def zbx_class
    return self.class.zbx_class
  end

  def initialize(uri, client = nil)
    @uri = uri
    @client = client || Zab::Jsonrpc.new(@uri)
  end

  private
  def query(method, params)
    raise "Should use method of sub class!" unless zbx_class
    @client.post("#{zbx_class}.#{method}", params)
  end

  def build(method, params)
    raise "Should use method of sub class!" unless zbx_class
    @client.build("#{zbx_class}.#{method}", params)
  end
end

require_relative 'client/generate'
