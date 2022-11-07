require "active_support/concern"

module Protect
  module Model
    module CRUD
      extend ActiveSupport::Concern

      class_methods do
        def upsert_all(attributes, **options)
          super(protect_map_attributes(attributes), **options)
        end

        def insert_all(attributes, **options)
          super(protect_map_attributes(attributes), **options)
        end

        def insert_all!(attributes, **options)
          super(protect_map_attributes(attributes), **options)
        end

        def protect_map_attributes(records)
          return records unless records.is_a?(Array)

          records.map do |attributes|
            lockbox_attributes = self.lockbox_attributes

            lockbox_attributes.map do | key, hash|
              virtual_attribute = hash[:attribute].to_sym
              if protect_search_attrs[virtual_attribute]

                lockbox_encrypted_attribute = hash[:encrypted_attribute]

                decrypted_lockbox_value = self.send("decrypt_#{lockbox_encrypted_attribute}", attributes[lockbox_encrypted_attribute])

                ore_encrypted_value = Protect::ActiveRecordExtensions::ORE_64_8_V1.encrypt(decrypted_lockbox_value)

                secure_search_field = protect_search_attrs[virtual_attribute].fetch(:searchable_attribute)

                attributes[secure_search_field] = ore_encrypted_value
              end
            end
            attributes
          end
        end
      end

      def _create_record(*)
        protect_sync
        super
      end

      def _update_record(*)
        protect_sync
        super
      end


      def protect_sync
        search_attrs = self.class.protect_search_attrs

        if search_attrs.kind_of?(Hash) && !search_attrs.empty?
          search_attrs.each do |virt_attr, metadata|

            searchable_attr = metadata[:searchable_attribute]

            self.send("#{searchable_attr}=", self.send(virt_attr))
          end
        end
      end
    end
  end
end
