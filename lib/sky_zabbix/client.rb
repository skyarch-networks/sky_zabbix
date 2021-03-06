# @example
#   z = SkyZabbix::Client.new('http://example.com/zabbix/api_jsonrpc.php')
#   z.login('admin', 'zabbix')
#   z.host.get
class SkyZabbix::Client

  # @param [String] uri is URI of Zabbix Server API endpoint.
  # @param [Logger] logger is a Logger.
  def initialize(uri, logger: nil)
    @uri = uri
    @client = SkyZabbix::Jsonrpc.new(@uri, logger: logger)
  end

  # Login to Zabbix Server.
  # @param [String] user is Zabbix user name.
  # @param [String] pass is Zabbix password.
  def login(user, pass)
    @client.token = self.user.login(user: user, password: pass)
  end

  # Logout from Zabbix Server.
  def logout
    self.user.logout()
    @client.token = nil
  end

  # Send Batch Request.
  # @param [Array<Hash>] requests are Hash created by build_* method.
  def batch(*requests)
    return @client.batch(requests)
  end
end

require_relative 'client/target_base'
require_relative 'client/target_gen'
