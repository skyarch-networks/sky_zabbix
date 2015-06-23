require 'json'

methods = JSON.parse(File.read(File.expand_path('../../methods.json', __FILE__)), symbolize_names: true)

methods.each do |name, v|
  class_name = name[0].upcase + name[1..-1] # host => Host

  Zab::Client.const_set(class_name, Class.new(Zab::Client) do |klass|
    @class = name

    # TODO: getOptions
    v[:methods].each do |method|
      define_method(method) do |params|
        query(method, params)
      end
    end

    Zab::Client.__send__(:define_method, name) do 
      klass.new(@url, @client)
    end
  end)
end
