require_relative '../protect'

namespace :protect do
  desc "Encrypt plaintext fields marked as secure search to encrypted columns"
  task :encrypt, [:model] => :environment do |_task, args|
    if args[:model].nil?
      raise Protect::Error
    end

    model = args[:model].constantize

    Protect.encrypt(model)
  end

  desc "Generate keys for Lockbox and protect"
  task :generate_keys do
    lockbox_key = Lockbox.generate_key
    protect_key = Protect.generate_key

    Protect::Logger.info("")
    Protect::Logger.info("")
    Protect::Logger.info("Add the below keys to your rails credentials file:")
    Protect::Logger.info("")
    Protect::Logger.info("")
    Protect::Logger.info("lockbox:")
    Protect::Logger.info("  master_key: '#{lockbox_key}'")
    Protect::Logger.info("")
    Protect::Logger.info("protect:")
    Protect::Logger.info("  cs_protect_key: '#{protect_key}'")
    Protect::Logger.info("")
    Protect::Logger.info("")
    Protect::Logger.info("or")
    Protect::Logger.info("")
    Protect::Logger.info("add the following environment variables:")
    Protect::Logger.info("")
    Protect::Logger.info("LOCKBOX_MASTER_KEY=#{lockbox_key}")
    Protect::Logger.info("")
    Protect::Logger.info("CS_PROTECT_KEY=#{protect_key}")
    Protect::Logger.info("")
    Protect::Logger.info("")
    Protect::Logger.info("")
  end
end
