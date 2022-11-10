class CreateMigrationUsersTable < ActiveRecord::Migration[(ENV["RAILS_VERSION"] || "7.0").to_f]
  def change
    create_table :migration_users do |t|
      t.text :email
      t.text :email_ciphertext

      t.column :email_secure_search, :ore_64_8_v1
    end
  end
end
