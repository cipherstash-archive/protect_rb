class CreateTableWithNoSecuredAttributes < ActiveRecord::Migration[(ENV["RAILS_VERSION"] || "7.0").to_f]
  def change
    create_table :table_with_no_secured_attributes do |t|
      t.text :title
      t.integer :counter
      t.boolean :is_true
    end
  end
end
