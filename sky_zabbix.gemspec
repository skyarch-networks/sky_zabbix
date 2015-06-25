# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sky_zabbix/version'

Gem::Specification.new do |spec|
  spec.name          = "sky_zabbix"
  spec.version       = SkyZabbix::VERSION
  spec.authors       = ["Skyarch Networks Inc."]
  spec.email         = [] # TODO
  spec.licenses      = ['MIT']

  spec.summary       = %q{Zabbix API Wrapper}
  spec.description   = %q{Zabbix API Wrapper}
  spec.homepage      = "https://github.com/skyarch-networks/sky_zabbix"


  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.0.0'

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "yard"
end