class CreateUsersTableForUniquenessTesting < ActiveRecord::Migration[(ENV["RAILS_VERSION"] || "7.0").to_f]
  def change
    create_table :users_for_uniqueness_testing do |t|
      t.text :example_index_ciphertext
      t.column :example_index_secure_search, :ore_64_8_v1
      t.index :example_index_secure_search,
        name: "example_index_secure_search_unique",
        unique: true
    end
  end
end
