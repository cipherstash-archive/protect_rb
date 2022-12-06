module CipherStash
  module Protect
    module Model
      module DynamicMatchers
        def valid?
          attribute_names.all? { |name|
            model.columns_hash[name] ||
            model.reflect_on_aggregation(name.to_sym) ||
            model.protect_search_attrs[name.to_sym]
          }
        end
      end
    end
  end
end
