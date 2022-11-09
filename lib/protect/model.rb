require "active_support/concern"
require_relative "./model/dsl"
require_relative "./model/crud"

module Protect
  module Model
    extend ActiveSupport::Concern
    include Protect::Model::DSL
    include Protect::Model::CRUD

    class_methods do
      def protect_search_attrs
        @protect_search_attrs ||= {}
      end

      def is_protected?
        protect_search_attrs.size > 0
      end
    end
  end
end
