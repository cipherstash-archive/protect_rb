require 'active_support'
require 'active_record'
require 'lockbox'
require 'securerandom'
require 'ore-rs'
require 'progress_bar'

require_relative './protect/active_record_extensions'
require_relative './protect/database_extensions'
require_relative './protect/logger'
require_relative './protect/model'
require_relative './protect/railtie' if defined?(Rails::Railtie)

module Protect
  class Error < StandardError; end

  if ActiveRecord::VERSION::MAJOR < 6
    raise Protect::Error, "Protect supports ActiveRecord versions >= 6"
  end

  def self.generate_key
    SecureRandom.hex(32)
  end

  def self.encrypt(model)
    # TODO: Raise an error if model is not protected
    if model.is_protected?
      bar = ProgressBar.new(model.count)

      # Silence warnings is added here to suppress Lockbox warning messages relating
      # to the presence of unencrypted plaintext fields.
      # When running this method we are aware that there are unencrypted fields.
      # Although this will silence all warnings, for now the improvement in UX
      # is favoured.
      silence_warnings do
          model.find_in_batches do |group|
          group.each do |record|
            record.attributes.each do |attr, val|
              unless attr =~ /_ciphertext$/ || attr =~ /_secure_search$/
                record.send("#{attr}=", val)
              end
            end
            record.save!(validate: false)
            bar.increment! 1
          end
        end
      end
    end
  end
end
