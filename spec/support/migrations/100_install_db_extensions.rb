class InstallDbExtensions < ActiveRecord::Migration[(ENV["RAILS_VERSION"] || "7.0").to_f]
  def up
    ProtectRB::DatabaseExtensions.install rescue nil
  end

  def down
    ProtectRB::DatabaseExtensions.uninstall rescue nil
  end
end
