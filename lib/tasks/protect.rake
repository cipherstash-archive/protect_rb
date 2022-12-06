require_relative '../cipherstash/protect'

namespace :protect do
  desc "Encrypt plaintext fields marked as secure search to encrypted columns"
  task :encrypt, [:model] => :environment do |_task, args|
    if args[:model].nil?
      raise CipherStash::Protect::Error
    end

    model = args[:model].constantize

    CipherStash::Protect.encrypt(model)
  end

  desc "Generate local keys to use with Protect"
  task :generate_keys do
    lockbox_key = Lockbox.generate_key
    protect_key = CipherStash::Protect.generate_key

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

    info.split("\n").each {|line| CipherStash::Protect::Logger.info(line) }
  end
end
