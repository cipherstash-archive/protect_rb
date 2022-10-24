require "active_support/concern"

module ProtectRB
  module Model
    module CRUD

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
