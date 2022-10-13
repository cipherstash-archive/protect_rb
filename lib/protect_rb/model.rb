require "active_support/concern"
require_relative "./model/dsl"
require_relative "./model/crud"

module ActiveProtect
  module Model
    extend ActiveSupport::Concern
    include ProtectRB::Model::DSL
    include ProtectRB::Model::CRUD
  end
end

