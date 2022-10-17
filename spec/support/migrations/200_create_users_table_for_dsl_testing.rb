class CreateUsersTableForDslTesting < ActiveRecord::Migration[7.0]
  def change
    create_table :users_for_dsl_testing do |t|
      t.text :email_ciphertext
      t.text :full_name_ciphertext
      t.text :bio_ciphertext
      t.text :dob_ciphertext

      t.column :dob_secure_search, :ore_64_8_v1
      t.column :full_name_secure_search, :ore_64_8_v1

      # Used to assert that a custom column name can be used
      t.text :updated_at_ciphertext, type: :date
      t.column :updated_at_searchable, :ore_64_8_v1

      # Used to assert an error message is generated
      t.column :email_secure_search, :text

      # Used to assert an error message is generated
      t.text :unencrypted_data_ciphertext
    end
  end
end