class Zab::Client::Resource
  # @return [String]
  def self._zbx_class
    return @class
  end


  def initialize(uri, client)
    @uri = uri
    @client = client
  end

  private
  def _query(method, params)
    raise "Should use method of sub class!" unless _zbx_class
    @client.post("#{_zbx_class}.#{method}", params)
  end

  def _build(method, params)
    raise "Should use method of sub class!" unless _zbx_class
    @client.build("#{_zbx_class}.#{method}", params)
  end

  # @return [String]
  def _zbx_class
    return self.class._zbx_class
  end
end
