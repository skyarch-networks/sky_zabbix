require 'spec_helper'

describe Zab::Jsonrpc do
  describe '#post' do
    let(:client){Zab::Jsonrpc.new(ZABBIX_URL)}
    let(:params){{user: ZABBIX_USER, password: ZABBIX_PASS}}
    let(:req){client.post('user.login', params)}

    it 'should be success' do
      req
    end
  end
end
