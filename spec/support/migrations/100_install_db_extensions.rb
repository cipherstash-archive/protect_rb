class InstallDbExtensions < ActiveRecord::Migration[RAILS_VERSION]
  def up
    CipherStash::Protect::DatabaseExtensions.install rescue nil
  end

  def down
    CipherStash::Protect::DatabaseExtensions.uninstall rescue nil
  end
end
