require 'json'

module SkyZabbix
  v = JSON.parse(File.read(File.expand_path('../methods.json', __FILE__)), symbolize_names: true)[:version]
  VERSION = v + ".0.1.0"
end
