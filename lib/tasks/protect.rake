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

    info = <<~EOF
      Add the below keys to your rails credentials file:

        lockbox:
          master_key: '#{lockbox_key}'
        protect:
          cs_protect_key: '#{protect_key}'

      or
      
      add the following environment variables:
      
        LOCKBOX_MASTER_KEY=#{lockbox_key}
        CS_PROTECT_KEY=#{protect_key}
    EOF

    info.split("\n").each {|line| Protect::Logger.info(line) }
  end
end
