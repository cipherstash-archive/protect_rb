require 'open3'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec => 'db:create')

namespace :db do
  databases = [
    "protect_test",
    "protect_test_alt",
  ]

  def db_exists?(db)
    out, status = Open3.capture2e("psql -l | grep -q '#{db}'")
    status.success?
  end

  desc "Drop the database"
  task :drop do
    databases.each do |db|
      puts format("Dropping %s database...", db)
      out, status = Open3.capture2e("dropdb", "--if-exists", db)
      puts out unless out.empty?
      puts "... Failed. (#{status})" unless status.success?
    end
  end

  desc "Create the database"
  task :create do
    databases.each do |db|
      if not db_exists?(db)
        puts format("Creating %s database...", db)
        out, status = Open3.capture2e("createdb", db)
        puts out unless out.empty?
        puts "... Failed. (#{status})" unless status.success?
      end
    end
  end

  task :setup => :create
end

task :default => :spec
