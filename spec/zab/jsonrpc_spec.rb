require 'spec_helper'

describe Zab::Jsonrpc do
  describe '#post' do
    let(:client){Zab::Jsonrpc.new(ZABBIX_URL)}
    let(:params){{user: ZABBIX_USER, password: ZABBIX_PASS}}
    let(:req){client.post('user.login', params)}

    it 'should be success' do
      req
    end

    context 'when invalid method' do
      let(:req){client.post('hogehoge.fugafdafs', params)}

      it 'should raise error' do
        expect{req}.to raise_error(Zab::Jsonrpc::Error)
      end
    end
  end
end
