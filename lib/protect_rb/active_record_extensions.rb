require "active_support"
require_relative "./active_record_extensions/ore_64_8_v1"
require_relative "./database_extensions/postgresql"
require_relative "./model/dynamic_matchers"
require_relative "./model/predicate_builder"

if defined?(ActiveSupport.on_load)
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.include ProtectRB::Model
    ActiveRecord::DynamicMatchers::Method.prepend(ProtectRB::Model::DynamicMatchers)
    ActiveRecord::PredicateBuilder.prepend(ProtectRB::Model::PredicateBuilder)

    require "active_record/connection_adapters/postgresql_adapter"

    ActiveRecord::Type.register(
      "ore_64_8_v1",
      ProtectRB::ActiveRecordExtensions::ORE_64_8_V1_Type,
      override: true,
      adapter: :postgresql
    )

    ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend ::ProtectRB::DatabaseExtensions::Postgresql::ConnectionAdapter
  end
end
