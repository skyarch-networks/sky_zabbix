# TargetBase is a Base Class for target of Zabbix API method.
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

  # Returns list of filtered primary key.
  # @param [Hash] filter
  # @return [Array<String>] List of ID
  def get_ids(filter)
    params = {
      filter: filter,
      output: 'extend',
    }
    return _query('get', params).map{|x|x[pk]}
  end

  # Return filtered primary key of founded first.
  # @param [Hash] filter
  # @return [Array<String>] ID of founded first.
  def get_id(filter)
    return get_ids(filter).first
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
  # @return [Hash{Symbol => Any}]
  def _build(method, params)
    raise "Should use method of sub class!" unless _zbx_class
    @client.build("#{_zbx_class}.#{method}", params)
  end

  # @return [String]
  def _zbx_class
    return self.class._zbx_class
  end

  # @abstract
  def pk
    raise 'Should override pk method!'
  end
end
