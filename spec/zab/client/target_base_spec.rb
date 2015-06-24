require 'spec_helper'

describe Zab::Client::TargetBase do
  describe '.new' do
    it 'should be abstract class' do
      expect{Zab::Client::TargetBase.new(
        ZABBIX_URL,
        Zab::Jsonrpc.new(ZABBIX_URL)
      )}.to raise_error
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
