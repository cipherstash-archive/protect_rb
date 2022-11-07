module ProtectRB
  module Model
    module PredicateBuilder
      # This intercepts the build call.
      # Updates the attribute to the searchable attribute field (e.g email_secure_search)
      # and ORE encrypts the value.
      def build(attribute, value, *args)
        search_attrs = table.send(:klass).protect_rb_search_attrs
        if search_attrs && !value.is_a?(ActiveRecord::StatementCache::Substitute)
          search_attr = search_attrs[attribute.name.to_sym]&.fetch(:searchable_attribute)

          if search_attr
            attribute = attribute.relation[search_attr]
            value = ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt(value)
          end
        end
        super(attribute, value, *args)
      end
    end
  end
end
