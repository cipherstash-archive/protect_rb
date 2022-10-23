require "bundler/setup"
require 'rspec/expectations'
require "active_record"
require "protect_rb"
require "lockbox"
require "pry"
require "database_cleaner"

ENV["LOCKBOX_MASTER_KEY"] = Lockbox.generate_key
ENV["CS_PROTECT_KEY"] = ProtectRB.generate_key

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  host: 'localhost',
  username: ENV["PGUSER"] || nil,
  password: ENV["PGPASSWORD"] || nil,
  database: ENV["PGDATABASE"] || 'protect_rb_test'
)

RSpec.configure do |config|
  config.full_backtrace = ENV.key?("RSPEC_FULL_BACKTRACE")

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)

    ActiveRecord::MigrationContext.new(File.join("spec", "support", "migrations"), ActiveRecord::SchemaMigration).migrate

    Dir["./spec/support/models/*.rb"].each {|file| require  file }
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
