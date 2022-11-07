require "bundler/setup"
require 'rspec/expectations'
require "active_record"
require "protect"
require "lockbox"
require "debug"
require "pry"
require "database_cleaner"

include Protect::ActiveRecordExtensions

ENV["LOCKBOX_MASTER_KEY"] = Lockbox.generate_key
ENV["CS_PROTECT_KEY"] = Protect.generate_key

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
  config.run_all_when_everything_filtered = true

  config.backtrace_inclusion_patterns = [
    /\/lib\/protect/,
    /\/spec\/protect/,
  ]
  config.backtrace_exclusion_patterns = [
    /\/lib\d*\/ruby\//,
    /\/gems\//,
    /\/bin\//,
    /\/lib\/rspec\/(core|expectations|matchers|mocks)/,
    /\/vendor\/bundler/,
  ]

  # Everything in spec/protect/ is a :type => :db spec unless marked
  # otherwise, eg.
  #   RSpec.describe "tests", type: :extensions_test do
  config.define_derived_metadata(
    file_path: Regexp.new('/spec/protect/')
  ) do |metadata|
    metadata[:type] = :db if metadata[:type].nil?
  end

  ### Extension-related tests ###
  config.before(:all, type: :extensions_test) do
    establish_connection(
      database: 'protect_test_alt'
    )
  end

  ### Regular :db tests ###
  config.before(:all, type: :db) do
    establish_connection(
      database: 'protect_test'
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
