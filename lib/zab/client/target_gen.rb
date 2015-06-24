require 'json'

methods = JSON.parse(File.read(File.expand_path('../../methods.json', __FILE__)), symbolize_names: true)

methods.each do |name, v|
  class_name = name[0].upcase + name[1..-1] # host => Host

  # Generate Class
  Zab::Client.const_set(class_name, Class.new(Zab::Client::TargetBase) do |klass|
    @class = name

    # TODO: getOptions
    v[:methods].each do |method|
      # Generate query method.
      # Example: user.login()
      define_method(method) do |params={}|
        _query(method, params)
      end

      # Generate build method. For batch request
      # Example: user.build_login()
      define_method("build_#{method}") do |params={}|
        _build(method, params)
      end
    end

    # Generate getter method.
    # Example: client.user
    Zab::Client.__send__(:define_method, name) do
      klass.new(@url, @client)
    end
  end)
end
