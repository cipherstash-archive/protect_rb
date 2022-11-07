require "active_support"
require_relative "./active_record_extensions/ore_64_8_v1"
require_relative "./database_extensions/postgresql"
require_relative "./model/dynamic_matchers"
require_relative "./model/predicate_builder"
require_relative "./model/query_methods"

if defined?(ActiveSupport.on_load)
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.include Protect::Model
    ActiveRecord::DynamicMatchers::Method.prepend(Protect::Model::DynamicMatchers)
    ActiveRecord::PredicateBuilder.prepend(Protect::Model::PredicateBuilder)
    ActiveRecord::Relation.prepend(Protect::Model::QueryMethods)

    require "active_record/connection_adapters/postgresql_adapter"

    ActiveRecord::Type.register(
      "ore_64_8_v1",
      Protect::ActiveRecordExtensions::ORE_64_8_V1_Type,
      override: true,
      adapter: :postgresql
    )

    ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend ::Protect::DatabaseExtensions::Postgresql::ConnectionAdapter
  end
end
