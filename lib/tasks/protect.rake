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
end
