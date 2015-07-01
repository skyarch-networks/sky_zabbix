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
    File.write('lib/sky_zabbix/methods.json', JSON.pretty_generate(JSON.parse(out)))
  end
end

namespace :release do
  desc "Release all version"
  task :all do |task, args|
    exec = -> (cmd) {
      print '> '; puts cmd.join(' ')
      r = system(*cmd)
      unless r
        raise "#{cmd} exit with #{$?}"
      end
    }

    get_env = -> (name) {
      v = ENV[name]
      raise "#{name} environment variable should be set!" unless v
      return v
    }

    versions = %w[2.2 2.4]
    path        = get_env.('PATH_ZABBIX')
    lib_version = get_env.('LIB_VERSION')

    # check git status
    unless `git status --short`.empty?
      raise "Should commit some changes."
    end

    # Update version
    v_path = File.expand_path('../lib/sky_zabbix/version.rb', __FILE__)
    f = File.read(v_path)
    f[/^\s+LIB_VERSION = "([\d.]+)"$/, 1] = lib_version
    File.write(v_path, f)

    # version up commit and add tag and push.
    exec.(%W[git commit -am "Bump\ up\ version to #{lib_version}"])
    exec.(%W[git tag v#{lib_version}])
    exec.(%w[git push])
    exec.(%W[git push origin v#{lib_version}])

    # build gems
    versions.each do |v|
      Dir.chdir(path) do
        latest_tag = `git tag`.split("\n").select{|x|x =~ /^#{Regexp.escape(v)}/}.sort{|a, b|a[/\.(\d+)$/, 1].to_i <=> b[/\.(\d+)$/, 1].to_i}.last
        exec.(%W[git checkout #{latest_tag}])
      end
      Rake::Task['generate:methods'].execute
      Rake::Task['build'].execute
    end

    pkgs = Dir.glob(File.join(File.expand_path('../pkg/', __FILE__), "sky_zabbix-*#{lib_version}.gem"))
    # Push gems
    pkgs.each do |p|
      exec.(%W[gem push #{p}])
    end
  end
end
