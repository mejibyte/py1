class CreateListsProducts < ActiveRecord::Migration
  def self.up
    create_table (:lists_products, :id => false ) do |t|
      t.integer :list_id
      t.integer :product_id
    end

    add_index :lists_products, [:list_id, :product_id], :unique => true
  end

  def self.down
    drop_table :lists_products
  end
end
