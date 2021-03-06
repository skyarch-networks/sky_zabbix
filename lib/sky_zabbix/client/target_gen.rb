require 'json'

methods = JSON.parse(File.read(File.expand_path('../../methods.json', __FILE__)), symbolize_names: true)[:methods]

methods.each do |name, v|
  class_name = name[0].upcase + name[1..-1] # host => Host

  # Generate Class
  SkyZabbix::Client.const_set(class_name, Class.new(SkyZabbix::Client::TargetBase) do |klass|
    @class = name

    # TODO: getOptions
    v[:methods].each do |method|
      # Generate query method.
      # Example: user.login()
      # @param [Any] params
      # @return [Any] return query response.
      define_method(method) do |params={}|
        _query(method, params)
      end

      # Generate build method. For batch request
      # Example: user.build_login()
      # @param [Any] params
      # @return [Hash{}] return query response.
      # @return [Hash{Symbol => Any}]
      define_method("build_#{method}") do |params={}|
        _build(method, params)
      end
    end

    # primary key
    define_method(:pk) do
      return v[:pk]
    end

    # Generate getter method.
    # Example: client.user
    SkyZabbix::Client.__send__(:define_method, name) do
      klass.new(@url, @client)
    end
  end)
end
