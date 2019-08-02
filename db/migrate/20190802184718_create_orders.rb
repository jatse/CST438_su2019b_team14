class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.integer :itemId, null: false
      t.string  :description, null: false
      t.integer :customerId, null: false
      t.decimal :price, percision: 15, scale: 2, null: false
      t.decimal :award, percision: 15, scale: 2, null: false
      t.decimal :total, percision: 15, scale: 2, null: false

      t.timestamps
    end
  end
end
