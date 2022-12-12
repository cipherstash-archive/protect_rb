module CipherStash
  module Protect
    module ActiveRecordExtensions
      module PredicateBuilder
        include CipherStash::Protect::ActiveRecordExtensions

        # This intercepts the build call.
        # Updates the attribute to the searchable attribute field (e.g email_secure_search)
        # and ORE encrypts the value.
        def build(attribute, value, *args)
          klass = table.send(:klass)
          if klass \
            && klass.respond_to?(:is_protected?) \
            && klass.is_protected? \
            && !value.is_a?(ActiveRecord::StatementCache::Substitute)
          then
            search_attr = klass.protect_search_attrs[attribute.name.to_sym]&.fetch(:searchable_attribute)

            if search_attr
              attribute = attribute.relation[search_attr]

              if range_query?(value)
                value = encrypt_range(value)
              else
                value = ORE_64_8_V1.encrypt(value)
              end
            end
          end

          super(attribute, value, *args)
        end

        private
        def range_query?(value)
          value.kind_of?(Range)
        end

        def encrypt_range(value)
          if value.exclude_end?
            if value.begin == nil
              return value.begin...ORE_64_8_V1.encrypt(value.end)
            end
          end

          if value.begin == nil
            return Range.new(value.begin, ORE_64_8_V1.encrypt(value.end))
          end

          if value.end == nil
            return Range.new(ORE_64_8_V1.encrypt(value.begin), value.end)
          end
        end
      end
    end
  end
end
