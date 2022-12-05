class CreateUsersTableForDslTesting < ActiveRecord::Migration[RAILS_VERSION]
  def change
    create_table :users_for_dsl_testing do |t|
      t.text :email_ciphertext
      t.text :full_name_ciphertext
      t.text :bio_ciphertext
      t.text :dob_ciphertext

      t.column :dob_secure_search, :ore_64_8_v1
      t.column :full_name_secure_search, :ore_64_8_v1
      t.column :full_name_secure_text_search, :integer, limit: 2, array: true

      # Used to assert that a custom column name can be used
      t.text :updated_at_ciphertext, type: :date
      t.column :updated_at_searchable, :ore_64_8_v1

      # Used to assert an error message is generated
      t.column :email_secure_search, :text
      t.column :email_secure_text_search, :text
      t.column :verified_secure_text_search, :boolean
    end
  end
end
