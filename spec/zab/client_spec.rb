require 'spec_helper'

describe Zab::Client do
  let(:client){Zab::Client.new(ZABBIX_URL)}

  describe '.new' do
    it 'should not raise error' do
      client
    end
  end

  describe '#query' do
    #TODO
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

describe Zab::Client::User do
  let(:user){Zab::Client.new(ZABBIX_URL).user}

  describe '#login' do
    it 'should be success' do
      resp = user.login(user: ZABBIX_USER, password: ZABBIX_PASS)
      expect(resp).to be_a String
    end
  end

  describe '#build_login' do
    let(:params){{user: ZABBIX_USER, password: ZABBIX_PASS}}
    it 'should be hash' do
      resp = user.build_login(params)
      expect(resp).to be_a Hash
      expect(resp[:method]).to eq "user.login"
      expect(resp[:params]).to eq params
    end
  end
end
