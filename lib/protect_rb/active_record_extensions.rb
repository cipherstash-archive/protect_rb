require 'active_support'
require_relative './active_record_extensions/ore_64_8_v1'

if defined?(ActiveSupport.on_load)
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Type.register(
      "ore_64_8_v1",
      ProtectRB::ActiveRecordExtensions::ORE_64_8_V1_Type,
      override: true,
      adapter: :postgresql
    )
  end
end