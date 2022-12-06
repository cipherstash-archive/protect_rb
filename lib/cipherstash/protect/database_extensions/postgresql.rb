module Protect
	module DatabaseExtensions
    module Postgresql
      module ConnectionAdapter
        def initialize_type_map(m = type_map)
          m.register_type "ore_64_8_v1", Protect::ActiveRecordExtensions::ORE_64_8_V1_Type.new
          super
        end
      end
    end
  end
end
