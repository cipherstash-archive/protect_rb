require 'active_support'
require 'active_record'
require 'lockbox'
require 'securerandom'
require 'ore-rs'

require_relative './protect_rb/active_record_extensions'
require_relative './protect_rb/database_extensions'
require_relative './protect_rb/logger'
require_relative './protect_rb/model'

module ProtectRB
  class Error < StandardError; end

  def self.generate_key
    SecureRandom.hex(32)
  end
end
