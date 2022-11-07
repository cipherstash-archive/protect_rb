class InstallDbExtensions < ActiveRecord::Migration[(ENV["RAILS_VERSION"] || "7.0").to_f]
  def up
    Protect::DatabaseExtensions.install rescue nil
  end

  def down
    Protect::DatabaseExtensions.uninstall rescue nil
  end
end
