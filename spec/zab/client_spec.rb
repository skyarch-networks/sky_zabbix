require 'spec_helper'

describe Zab::Client do
  let(:client){Zab::Client.new(ZABBIX_URL)}

  describe '.new' do
    it 'should not raise error' do
      client
    end
  end

  describe '#login' do
    let(:login){client.login(ZABBIX_USER, ZABBIX_PASS)}

    before{login}

    it 'should set token' do
      expect(client.instance_variable_get(:@client).token).to be_a String
    end

    it 'should be able to get users' do
      res = client.user.get()
      expect(res).to be_a Array
    end
  end

  describe '#logout' do
    let(:login){client.login(ZABBIX_USER, ZABBIX_PASS)}
    let(:logout){client.logout}

    before{login}

    it 'should unset token' do
      expect(client.instance_variable_get(:@client).token).to be_a String
      logout
      expect(client.instance_variable_get(:@client).token).to be_nil
    end

    it 'should not be able to get users' do
      logout
      expect{client.user.get()}.to raise_error Zab::Jsonrpc::Error
    end
  end

  describe '#batch' do
    let(:params){{user: ZABBIX_USER, password: ZABBIX_PASS}}
    let(:user){Zab::Client.new(ZABBIX_URL).user}
    let(:requests){[user.build_login(params), user.build_login(params)]}
    let(:batch){client.batch(*requests)}

    it 'should return response' do
      expect(batch.size).to eq requests.size
      batch.each do |resp|
        expect(resp).not_to be_nil
        expect(resp).not_to be_a Zab::Jsonrpc::Error
      end
    end
  end
end
