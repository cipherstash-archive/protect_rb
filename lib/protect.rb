require 'active_support'
require 'active_record'
require 'lockbox'
require 'securerandom'
require 'ore-rs'

require_relative './protect/active_record_extensions'
require_relative './protect/database_extensions'
require_relative './protect/logger'
require_relative './protect/model'

module Protect
  class Error < StandardError; end

  if ActiveRecord::VERSION::MAJOR < 6
    raise Protect::Error, "Protect supports ActiveRecord versions >= 6"
  end

  def self.generate_key
    SecureRandom.hex(32)
  end
end
