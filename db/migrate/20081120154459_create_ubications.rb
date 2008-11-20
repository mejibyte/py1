class CreateUbications < ActiveRecord::Migration
  def self.up
    create_table :ubications do |t|
      t.string :name
      t.integer :x
      t.integer :y

      t.timestamps
    end

    add_column :products, :ubication_id, :integer
    remove_column :products, :ubication
  end

  def self.down
    drop_table :ubications
    remove_column :product, :ubication_id
    add_column :products, :ubication, :string
  end
end
