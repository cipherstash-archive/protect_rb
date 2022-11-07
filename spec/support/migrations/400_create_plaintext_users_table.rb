class CreatePlaintextUsersTable < ActiveRecord::Migration[(ENV["RAILS_VERSION"] || "7.0").to_f]
  def change
    create_table :plaintext_users do |t|
      t.text :email_plaintext
      t.integer :age_plaintext
      t.text :dob_ciphertext
      t.text :last_login_ciphertext
      t.text :verified_ciphertext
      t.text :latitude_ciphertext

      t.column :dob_secure_search, :ore_64_8_v1
      t.column :last_login_secure_search, :ore_64_8_v1
      t.column :verified_secure_search, :ore_64_8_v1
      t.column :latitude_secure_search, :ore_64_8_v1
    end
  end
end
