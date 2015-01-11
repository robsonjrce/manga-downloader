dir = File.dirname(__FILE__)

require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["#{dir}/test/**/*_test.rb"]
  # t.warning = true
  t.verbose = true
end
