class Zab::Client

  # @param [String] uri is URI of Zabbix Server API endpoint.
  # @param [Logger] logger is a Logger.
  # @example initialize
  #   z = Zab::Client.new('http://example.com/zabbix/api_jsonrpc.php')
  def initialize(uri, logger: nil)
    @uri = uri
    @client = Zab::Jsonrpc.new(@uri, logger: logger)
  end

  # @param [String] user is Zabbix user name.
  # @param [String] pass is Zabbix password.
  def login(user, pass)
    @client.token = self.user.login(user: user, password: pass)
  end

  # @param [Array<Hash>] requests are Hash created by build_* method.
  def batch(*requests)
    return @client.batch(requests)
  end
end

require_relative 'client/resource'
require_relative 'client/resource_gen'
