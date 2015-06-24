$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pry'
require 'sky_zabbix'

ZABBIX_URL  = ENV["ZABBIX_URL"]
ZABBIX_USER = ENV["ZABBIX_USER"]
ZABBIX_PASS = ENV["ZABBIX_PASS"]

unless ZABBIX_URL && ZABBIX_USER && ZABBIX_PASS
  raise("Should set ZABBIX_URL, ZABBIX_USER and ZABBIX_PASS environment variables.")
end


RSpec.configure do |config|
end
