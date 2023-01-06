require "active_support"
require "active_record"
require "securerandom"
require "progress_bar"

require_relative "./protect/active_record_extensions"
require_relative "./protect/analysis"
require_relative "./protect/database_extensions"
require_relative "./protect/logger"
require_relative "./protect/model"
require_relative "./protect/query"
require_relative "./protect/railtie" if defined?(Rails::Railtie)

module CipherStash
  module Protect
    class Error < StandardError; end

    if ActiveRecord::VERSION::MAJOR < 6
      raise CipherStash::Protect::Error, "Protect supports ActiveRecord versions >= 6"
    end

    def self.generate_key
      SecureRandom.hex(32)
    end

    def self.encrypt(model)
      if respond_to?(:silence_warnings)
        # Silence warnings is added here to suppress Lockbox warning messages relating
        # to the presence of unencrypted plaintext fields.
        # When running this method we are aware that there are unencrypted fields.
        # Although this will silence all warnings, for now the improvement in UX
        # is favoured.
        silence_warnings { encrypt_model(model) }
      else
        encrypt_model(model)
      end
    end

    private

    def self.encrypt_model(model)
      raise CipherStash::Protect::Error, "Nothing to encrypt in #{model}" unless model.is_protected?

      bar = ProgressBar.new(model.count)
      model.find_in_batches do |group|
        group.each do |record|
          record.attributes.each do |attr, val|
            unless attr =~ /_ciphertext$/ || attr =~ /_secure_search$/
              record.send("#{attr}=", val)
            end
          end
          record.save!(validate: false)
          bar.increment! 1
        end
      end
    end
  end
end

if defined?(ActiveSupport.on_load)
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.include CipherStash::Protect::Model

    ActiveRecord::DynamicMatchers::Method.prepend(CipherStash::Protect::ActiveRecordExtensions::DynamicMatchers)
    ActiveRecord::PredicateBuilder.prepend(CipherStash::Protect::ActiveRecordExtensions::PredicateBuilder)
    ActiveRecord::Relation.prepend(CipherStash::Protect::ActiveRecordExtensions::QueryMethods)
    ActiveRecord::Validations::UniquenessValidator.prepend(CipherStash::Protect::ActiveRecordExtensions::UniquenessValidator)

    require "active_record/connection_adapters/postgresql_adapter"

    ActiveRecord::Type.register(
      "ore_64_8_v1",
      CipherStash::Protect::ActiveRecordExtensions::ORE_64_8_V1_Type,
      override: true,
      adapter: :postgresql
    )

    ActiveRecord::Type.register(
      "ore_64_8_v1_text",
      CipherStash::Protect::ActiveRecordExtensions::ORE_64_8_V1_Text_Type,
      override: true,
      adapter: :postgresql
    )

    ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend(
      CipherStash::Protect::DatabaseExtensions::Postgresql::ConnectionAdapter
    )
  end
end
