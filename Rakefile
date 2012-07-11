require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

task :help do

    puts "Available actions:"
    puts "    help  -- prints this help"
    puts "    test  -- runs the testcase"
    puts "    build -- builds the gem"

end

task :default => :help

task :build do

    system "gem build cdata.gemspec"

end