require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "w800rf32-receiver"
    gem.summary = %Q{library for serial communication with w800rf32 X10 RF receiver}
    gem.description = %Q{This library provides functionality to communicate with the
W800RF32 receiver by WGL & Associates. The author of this library is not associated
with WGL}
    gem.email = "phulst@sbcglobal.net"
    gem.homepage = "http://github.com/phulst/w800rf32-receiver"
    gem.authors = ["Peter Hulst"]
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    gem.add_dependency('serialport', '>= 1.0.4')
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "w800rf32-receiver #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
