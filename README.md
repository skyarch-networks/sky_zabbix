# SkyZabbix

SkyZabbix is a Zabbix API Wrapper written by Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
# If you use Zabbix 2.2
gem 'sky_zabbix', '~> 2.2.0'
# If you use Zabbix 2.4
gem 'sky_zabbix', '~> 2.4.0'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sky_zabbix

## Version Policy

sky_zabbix version is composed of two parts.

The first two digits is a Zabbix version.
The last three digits is a Library version.

Library version conforms to [Semantic Versioning](http://semver.org/).

For example.

- If version is `2.4.0.1.0`
- Zabbix version is `2.4`
- Library version is `0.1.0`

## Supported Zabbix Version

2.2 or later.

## Usage

### Initialize client and Authenticate

```ruby
require 'sky_zabbix'

zabbix_url  = 'http://zabbix.example.com/zabbix/api_jsonrpc.php'
zabbix_user = 'admin'
zabbix_pass = 'zabbix'

client = SkyZabbix::Client.new(zabbix_url)
client.login(zabbix_user, zabbix_pass)
```

### Basic Usage

```ruby
client.host.get()
# => [{"hostid" => "10000"}, {"hostid" => "10001"}, ...]

client.host.create(
  host: "HostName",
  interfaces: [{
    type: 1,
    main: 1,
    ip: "192.0.2.1",
    dns: "hoge.example.com",
    port: 10050,
    useip: 0
  }],
  groups: [
    groupid: "1",
  ]
)
# => {"hostids"=>["10119"]}
# and Created a new host to zabbix.
```

### Batch Request

```ruby
requests = []
requests.push client.host.build_get()
requests.push client.user.build_get()
requests.push client.hostgroup.build_get()
host_resp, user_resp, hostgroup_resp = cleint.batch(*requests)
```

## Development

### Building

Required PHP.

Get [Zabbix](https://github.com/zabbix/zabbix) source code.

```sh
cd ~
get clone https://github.com/zabbix/zabbix
```

Generate list of API method as JSON.

```sh
export PATH_ZABBIX=~/zabbix/frontends/php/
rake generate:methods
```

Build gem.

```sh
rake build
```

### Testing

```sh
export ZABBIX_URL='http://zabbix.example.com/zabbix/api_jsonrpc.php'
export ZABBIX_USER='admin'
ZABBIX_PASS='zabbix'
rake spec
```

## Contributing

1. Fork it ( https://github.com/skyarch-networks/sky_zabbix/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
