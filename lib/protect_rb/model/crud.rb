require "active_support/concern"

module ProtectRB
  module Model
    module CRUD
      extend ActiveSupport::Concern

      class_methods do
        def upsert_all(attributes, **options)
          binding.pry
          super(map_attributes(attributes), **options)
        end

        def insert_all(attributes, **options)
          super(map_attributes(attributes), **options)
        end

        def insert_all!(attributes, **options)
          super(map_attributes(attributes), **options)
        end

        def map_attributes(records)
          return records unless records.is_a?(Array)

          records.map do |attributes|
            # Get value by decrypting self.decrypt_dob_ciphertext()
            # self.send("decrypt_dob_ciphertext", "zBUkEVi5O8zk9oydMqHc4TysgIwkKznKjeCShwnr5zsVz1xDRFs=")
            binding.pry

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
