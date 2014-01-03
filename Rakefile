

$: << File.join( File.dirname(__FILE__), "lib" )
require 'milk_cap/rtm/base'

require 'rubygems'
require 'rake'


#
# TEST

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :default => :spec


#
# CLEAN

require 'rake/clean'
CLEAN.include('pkg', 'tmp', 'html')


#
# GEM

require 'jeweler'

Jeweler::Tasks.new do |gem|

  gem.version = MilkCap::RTM::VERSION
  gem.name = 'milk_cap'
  gem.summary = 'Yet another RememberTheMilk wrapper, successor to rufus-rtm.'

  gem.description = %{
    Yet another RememberTheMilk wrapper, successor to rufus-rtm.
  }
  gem.email = 'jeff.leverenz@gmail.com'
  gem.homepage = 'http://github.com/jleverenz/milk_cap/'
  gem.authors = [ 'John Mettraux', 'Jeff Leverenz' ]
  gem.licenses = 'MIT'

  gem.files.exclude 'spec/**'

  gem.add_development_dependency 'yard', '>= 0'
  gem.add_development_dependency 'rspec', '~> 2.14'
end
Jeweler::GemcutterTasks.new


#
# DOC

begin

  require 'yard'

  YARD::Rake::YardocTask.new do |doc|
    doc.options = [
      '-o', 'html/milk_cap', '--title',
      "milk_cap #{MilkCap::RTM::VERSION}"
    ]
  end

rescue LoadError

  task :yard do
    abort "YARD is not available : sudo gem install yard"
  end
end
