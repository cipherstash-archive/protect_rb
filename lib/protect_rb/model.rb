require "active_support/concern"
require_relative "./model/dsl"
require_relative "./model/crud"

module ProtectRB
  module Model
    extend ActiveSupport::Concern
    include ProtectRB::Model::DSL
    include ProtectRB::Model::CRUD

    class_methods do
      def is_protected?
        @protect_rb_search_attrs.size > 0
      end

      def protect_rb_search_attrs
        @protect_rb_search_attrs
      end
    end
  end
end
