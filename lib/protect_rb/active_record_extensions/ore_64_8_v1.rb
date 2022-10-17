module ProtectRB
  module ActiveRecordExtensions
    class ORE_64_8_V1_Type < ::ActiveRecord::Type::Value
      def type
        :ore_64_8_v1
      end
    end

    ActiveSupport.on_load(:active_record) do
      ActiveRecord::Type.register("ore_64_8_v1", ORE_64_8_V1_Type, override: true, adapter: :postgresql)
    end

    class ORE_64_8_V1
      # Just a placeholder for now
    end
  end
end
