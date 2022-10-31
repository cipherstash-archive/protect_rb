require "active_support/concern"

module ProtectRB
  module Model
    module CRUD
      extend ActiveSupport::Concern

      class_methods do
        def upsert_all(attributes, **options)
          super(protect_rb_map_attributes(attributes), **options)
        end

        def insert_all(attributes, **options)
          super(protect_rb_map_attributes(attributes), **options)
        end

        def insert_all!(attributes, **options)
          super(protect_rb_map_attributes(attributes), **options)
        end

        # Intercepts the order call to update any virtual attributes to use the
        # searchable attribute field.
        # Args are an array of Symbols for default ordering and a Hash for fields noted with a direction.
        # [:age_plaintext, {:last_login=>:asc, :email=>:asc}]
        def order(*args)
          search_attrs = self.instance_variable_get("@protect_rb_search_attrs")

          if search_attrs.nil?
            return super(args)
          end

          updated_args =
            args.map do |arg|
              case arg
              when Symbol
                search_attr = search_attrs[arg]
                if search_attr
                  search_attr.fetch(:searchable_attribute)
                else
                  arg
                end
              when Hash
                updated_hash = {}
                  arg.each do |field,direction|
                  search_attr = search_attrs[field]
                  if search_attr
                    updated_hash[search_attr.fetch(:searchable_attribute).to_sym] = direction
                  else
                    updated_hash[field] = direction
                  end
                end
                updated_hash
              else
                arg
              end
            end
          super(updated_args)
        end

        def protect_rb_map_attributes(records)
          return records unless records.is_a?(Array)

          records.map do |attributes|
            lockbox_attributes = self.lockbox_attributes

            lockbox_attributes.map do | key, hash|
              virtual_attribute = hash[:attribute].to_sym
              if protect_rb_search_attrs[virtual_attribute]

                lockbox_encrypted_attribute = hash[:encrypted_attribute]

                decrypted_lockbox_value = self.send("decrypt_#{lockbox_encrypted_attribute}", attributes[lockbox_encrypted_attribute])

                ore_encrypted_value = ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt(decrypted_lockbox_value)

                secure_search_field = protect_rb_search_attrs[virtual_attribute].fetch(:searchable_attribute)

                attributes[secure_search_field] = ore_encrypted_value
              end
            end
            attributes
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
        search_attrs = self.class.protect_rb_search_attrs

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
