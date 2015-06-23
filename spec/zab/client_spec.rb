require 'spec_helper'

describe Zab::Client do
  let(:client){Zab::Client.new(ZABBIX_URL)}

  describe '.new' do
    it 'should not raise error' do
      client
    end
  end

  describe '#query' do
    # TODO
  end
end

describe Zab::Client::User do
  let(:user){Zab::Client.new(ZABBIX_URL).user}

  describe '#login' do
    it 'should be success' do
      resp = user.login(user: ZABBIX_USER, password: ZABBIX_PASS)
      expect(resp).to be_a Net::HTTPSuccess
    end
  end
end
