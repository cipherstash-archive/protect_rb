class InstallDbExtensions < ActiveRecord::Migration[RAILS_VERSION]
  def up
    Protect::DatabaseExtensions.install rescue nil
  end

  def down
    Protect::DatabaseExtensions.uninstall rescue nil
  end
end
