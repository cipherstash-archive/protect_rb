require "active_support/concern"

module ProtectRB
  module Model
    module CRUD
      extend ActiveSupport::Concern

      class_methods do
        if ActiveRecord::VERSION::MAJOR >= 6
          def upsert_all(attributes, **options)
            super(map_attributes(attributes), **options)
          end

          def insert_all(attributes, **options)
            super(map_attributes(attributes), **options)
          end

          def insert_all!(attributes, **options)
            super(map_attributes(attributes), **options)
          end

          def update_all(attributes, **options)
            binding.pry
          end

          def map_attributes(records)
            return records unless records.is_a?(Array)

            records.map do |attributes|
              lockbox_attributes = self.lockbox_attributes

              lockbox_attributes.map do | key, hash|
                virtual_attribute = hash[:attribute].to_sym
                if @protect_rb_search_attrs[virtual_attribute]

                  lockbox_encrypted_attribute = hash[:encrypted_attribute]

                  decrypted_lockbox_value = self.send("decrypt_#{lockbox_encrypted_attribute}", attributes[hash[:encrypted_attribute]])

                  ore_encrypted_value = ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt(decrypted_lockbox_value)

                  secure_search_field = @protect_rb_search_attrs[virtual_attribute][:searchable_attribute]

                  attributes[secure_search_field] = ore_encrypted_value
                end
              end
              attributes
            end
          end
        end
      end

      def _create_record(*)
        protect_rb_sync
        super
      end

      def _update_record(*)
        protect_rb_sync
        super
      end


      def protect_rb_sync
        search_attrs = self.class.instance_variable_get("@protect_rb_search_attrs")

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
