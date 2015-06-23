require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'open3'
require 'json'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :generate do
  desc "Generate list of method"
  task :methods do |task, args|
    out, err, status = Open3.capture3("php", "build.php")
    unless status.success?
      puts err
      exit(1)
    end
    File.write('lib/zab/methods.json', JSON.pretty_generate(JSON.parse(out)))
  end
end
