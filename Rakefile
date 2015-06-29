require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'open3'
require 'json'

require_relative 'lib/sky_zabbix/version'

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
    File.write('lib/sky_zabbix/methods.json', JSON.pretty_generate(JSON.parse(out)))
  end
end

namespace :release do
  desc "Release all version"
  task :all do |task, args|
    exec = -> (cmd) {
      print '> '; puts cmd.join(' ')
      system(*cmd)
    }

    versions = %w[2.2 2.4]
    path = ENV['PATH_ZABBIX']

    versions.each do |v|
      Dir.chdir(path) do
        latest_tag = `git tag`.split("\n").select{|x|x =~ /^#{Regexp.escape(v)}/}.sort{|a, b|a[/\.(\d+)$/, 1].to_i <=> b[/\.(\d+)$/, 1].to_i}.last
        exec.(%W[git checkout #{latest_tag}])
      end
      Rake::Task['generate:methods'].execute
      Rake::Task['build'].execute
    end
    pkgs = Dir.glob(File.join(File.expand_path('../pkg/', __FILE__), "sky_zabbix-*#{SkyZabbix::LIB_VERSION}.gem"))
    pkgs.each do |p|
      exec.(%W[gem push #{p}])
    end
  end
end
