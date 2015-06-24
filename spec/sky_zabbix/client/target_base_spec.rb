require 'spec_helper'

describe SkyZabbix::Client::TargetBase do
  describe '.new' do
    it 'should be abstract class' do
      expect{SkyZabbix::Client::TargetBase.new(
        ZABBIX_URL,
        SkyZabbix::Jsonrpc.new(ZABBIX_URL)
      )}.to raise_error
    end
  end
end

describe SkyZabbix::Client::User do
  let(:user){SkyZabbix::Client.new(ZABBIX_URL).user}

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

  describe 'get_id' do
    let(:params){{alias: ZABBIX_USER}}
    subject{user.get_id(params)}

    before do
      token = user.login(user: ZABBIX_USER, password: ZABBIX_PASS)
      # TODO: Refactor
      user.instance_variable_get(:@client).token = token
    end

    it {is_expected.to be_a String}
  end

  describe '#pk' do
    subject{user.pk}
    it {is_expected.to be_a String}
  end
end
