require 'active_support'
require_relative './protect_rb/active_record_extensions'
require_relative './protect_rb/database_extensions'
require_relative './protect_rb/logger'
require_relative './protect_rb/model'

module ProtectRB
  class Error < StandardError; end
end
