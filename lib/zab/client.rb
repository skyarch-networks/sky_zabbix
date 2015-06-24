class Zab::Client
  def initialize(uri, client = nil, logger: nil)
    @uri = uri
    @client = client || Zab::Jsonrpc.new(@uri, logger: logger)
  end

  # @param [Array<Hash>] requests are Hash created by build_* method.
  def batch(*requests)
    return @client.batch(requests)
  end
end

require_relative 'client/resource'
require_relative 'client/resource_gen'
