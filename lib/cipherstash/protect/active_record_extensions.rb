require "active_support"
require_relative "./active_record_extensions/ore_64_8_v1"
require_relative "./active_record_extensions/uniqueness_validator"
require_relative "./database_extensions/postgresql"

# TODO: Move these into ActiveRecordExtensions as well for consistency's sake.
require_relative "./model/dynamic_matchers"
require_relative "./model/predicate_builder"
require_relative "./model/query_methods"

if defined?(ActiveSupport.on_load)
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.include CipherStash::Protect::Model

    ActiveRecord::DynamicMatchers::Method.prepend(CipherStash::Protect::Model::DynamicMatchers)
    ActiveRecord::PredicateBuilder.prepend(CipherStash::Protect::Model::PredicateBuilder)
    ActiveRecord::Relation.prepend(CipherStash::Protect::Model::QueryMethods)
    ActiveRecord::Validations::UniquenessValidator.prepend(CipherStash::Protect::ActiveRecordExtensions::UniquenessValidator)

    require "active_record/connection_adapters/postgresql_adapter"

    ActiveRecord::Type.register(
      "ore_64_8_v1",
      CipherStash::Protect::ActiveRecordExtensions::ORE_64_8_V1_Type,
      override: true,
      adapter: :postgresql
    )

    ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend(
      CipherStash::Protect::DatabaseExtensions::Postgresql::ConnectionAdapter
    )
  end
end
