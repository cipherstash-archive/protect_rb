require "bundler/setup"
require 'rspec/expectations'
require "active_record"
require "protect_rb"
require "lockbox"
require "debug"
require "pry"
require "database_cleaner"

include ProtectRB::ActiveRecordExtensions

ENV["LOCKBOX_MASTER_KEY"] = Lockbox.generate_key
ENV["CS_PROTECT_KEY"] = ProtectRB.generate_key

def establish_connection(**attrs)
  ActiveRecord::Base.establish_connection(
    {
      adapter: 'postgresql',
      host: ENV["PGHOST"] || 'localhost',
      username: ENV["PGUSER"] || nil,
      password: ENV["PGPASSWORD"] || nil,
    }.merge(attrs)
  )
end

RSpec.configure do |config|
  config.full_backtrace = ENV.key?("RSPEC_FULL_BACKTRACE")

  # Everything in spec/protect_rb/ is a :type => :db spec unless marked
  # otherwise, eg.
  #   RSpec.describe "tests", type: :extensions_test do
  config.define_derived_metadata(
    file_path: Regexp.new('/spec/protect_rb/')
  ) do |metadata|
    metadata[:type] = :db if metadata[:type].nil?
  end

  ### Extension-related tests ###
  config.before(:all, type: :extensions_test) do
    establish_connection(
      database: 'protect_rb_test_alt'
    )
  end

  ### Regular :db tests ###
  config.before(:all, type: :db) do
    establish_connection(
      database: 'protect_rb_test'
    )

    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)

    ActiveRecord::MigrationContext.new(File.join("spec", "support", "migrations"), ActiveRecord::SchemaMigration).migrate

    Dir["./spec/support/models/*.rb"].each {|file| require  file }
  end

  config.around(:each, type: :db) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  ### Misc configuration ###
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
