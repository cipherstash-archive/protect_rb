class CreateUsersTableForUniquenessTesting < ActiveRecord::Migration[RAILS_VERSION]
  def change
    create_table :users_for_uniqueness_testing do |t|
      t.text :example_index_ciphertext
      t.column :example_index_secure_search, :ore_64_8_v1, array: true
      t.index :example_index_secure_search,
        name: "example_index_secure_search_unique",
        unique: true

      t.text :example_validation_ciphertext
      t.column :example_validation_secure_search, :ore_64_8_v1, array: true
    end
  end
end
