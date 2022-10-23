class CreateUsersTableForCrudTesting < ActiveRecord::Migration[(ENV["RAILS_VERSION"] || "7.0").to_f]
  def change
    create_table :users_for_crud_testing do |t|
      t.text :email_ciphertext
      t.text :dob_ciphertext
      t.text :last_login_ciphertext
      t.text :age_ciphertext
      t.text :verified_ciphertext
      t.text :latitude_ciphertext

      t.column :email_secure_search, :ore_64_8_v1
      t.column :dob_secure_search, :ore_64_8_v1
      t.column :last_login_secure_search, :ore_64_8_v1
      t.column :age_secure_search, :ore_64_8_v1
      t.column :verified_secure_search, :ore_64_8_v1
      t.column :latitude_secure_search, :ore_64_8_v1
    end
  end
end
