require 'json'

module SkyZabbix
  LIB_VERSION = "0.1.2"
  ZABBIX_VERSION = JSON.parse(File.read(File.expand_path('../methods.json', __FILE__)), symbolize_names: true)[:version]
  VERSION = ZABBIX_VERSION + '.' + LIB_VERSION
end
