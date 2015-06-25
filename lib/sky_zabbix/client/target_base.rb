# @abstract
class SkyZabbix::Client::TargetBase
  # @return [String]
  def self._zbx_class
    return @class
  end


  # @param [String] uri is URI of Zabbix Server.
  # @param [SkyZabbix::Jsonrpc] client
  def initialize(uri, client)
    raise "Should use method of sub class!" unless _zbx_class
    @uri = uri
    @client = client
  end

  # @param [Hash] filter
  # @return [String|nil] ID of filtered first ID.
  def get_id(filter)
    params = {
      filter: filter,
      output: 'extend',
    }
    obj = _query('get', params).first
    return nil unless obj
    return obj[pk]
  end

  private
  # @param [String] method is method name. ex) get, create, delete ...
  # @param [Any] params is parameters.
  def _query(method, params)
    raise "Should use method of sub class!" unless _zbx_class
    @client.post("#{_zbx_class}.#{method}", params)
  end

  # @param [String] method is method name. ex) get, create, delete ...
  # @param [Any] params is parameters.
  def _build(method, params)
    raise "Should use method of sub class!" unless _zbx_class
    @client.build("#{_zbx_class}.#{method}", params)
  end

  # @return [String]
  def _zbx_class
    return self.class._zbx_class
  end
end
