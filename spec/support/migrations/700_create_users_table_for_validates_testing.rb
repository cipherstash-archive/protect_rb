class CreateUsersTableForValidatesTesting < ActiveRecord::Migration[(ENV["RAILS_VERSION"] || "7.0").to_f]
  def change
    create_table :users_for_validates_testing do |t|
      t.text :email_ciphertext
      t.column :email_secure_search, :ore_64_8_v1
    end
  end
end
