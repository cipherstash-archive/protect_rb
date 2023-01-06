class CreateMigrationUsersTable < ActiveRecord::Migration[RAILS_VERSION]
  def change
    create_table :migration_users do |t|
      t.text :email
      t.text :email_ciphertext

      t.column :email_secure_search, :ore_64_8_v1, array: true
    end
  end
end
