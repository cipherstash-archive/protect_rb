module Protect
  module Model
    module DynamicMatchers
      def valid?
        attribute_names.all? { |name| model.columns_hash[name] || model.reflect_on_aggregation(name.to_sym) || search_attrs?(name.to_sym) }
      end

      def search_attrs?(name)
        model.is_protected? && model.protect_search_attrs[name]
      end
    end
  end
end
