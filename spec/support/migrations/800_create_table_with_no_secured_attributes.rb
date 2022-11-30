class CreateTableWithNoSecuredAttributes < ActiveRecord::Migration[RAILS_VERSION]
  def change
    create_table :table_with_no_secured_attributes do |t|
      t.text :title
      t.integer :counter
      t.boolean :is_true
    end
  end
end
