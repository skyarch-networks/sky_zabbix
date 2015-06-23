require 'spec_helper'

describe Zab::Jsonrpc do
  let(:client){Zab::Jsonrpc.new(ZABBIX_URL)}

  describe '#post' do
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

  describe '#batch' do
    let(:buildeds){[
      client.build('user.login', {user: ZABBIX_USER, password: ZABBIX_PASS}),
      client.build('user.login', {user: ZABBIX_USER, password: ZABBIX_PASS}),
      client.build('user.login', {user: ZABBIX_USER, password: ZABBIX_PASS}, notification: true),
    ]}

    let(:batch){client.batch(buildeds)}

    it 'should be Array' do
      expect(batch).to be_a Array

      expect(batch.size).to eq buildeds.size
    end
  end

  describe '#build' do
    let(:method){'foo'}
    let(:params){['bar']}

    let(:build){client.build(method, params, notification: notification)}

    context 'when notification' do
      let(:notification){true}

      it 'should not have id' do
        expect(build).to be_a Hash
        expect(build[:id]).to be_nil
      end
    end

    context 'when not notification' do
      let(:notification){false}

      it 'should have id' do
        expect(build).to be_a Hash
        expect(build[:id]).not_to be nil
      end
    end
  end
end
