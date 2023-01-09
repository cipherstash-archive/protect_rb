module CipherStash
  module Protect
    module ActiveRecordExtensions
      module UniquenessValidator
        def validate_each(record, attribute, value)
          return super(record, attribute, value) unless record.class.respond_to?(:protect_search_attrs)

          protect_attr = record.class.protect_search_attrs[attribute.to_sym]
          if protect_attr
            virt_attr_val = record.read_attribute_for_validation(protect_attr[:lockbox_attribute][:attribute])
            if virt_attr_val.instance_of?(String)
              value = CipherStash::Protect::ActiveRecordExtensions::ORE_64_8_V1_Text.encrypt(virt_attr_val)
            else
              value = CipherStash::Protect::ActiveRecordExtensions::ORE_64_8_V1.encrypt(virt_attr_val)
            end
          end
          super(record, attribute, value)
        end

        # Change the attribute name here instead of in validate_each above for a
        # better error message
        def build_relation(klass, attribute, value)
          return super(klass, attribute, value) unless klass.respond_to?(:protect_search_attrs)

          protect_attr = klass.protect_search_attrs[attribute.to_sym]
          if protect_attr
            attribute = protect_attr[:searchable_attribute]
          end
          super(klass, attribute, value)
        end
      end
    end
  end
end
