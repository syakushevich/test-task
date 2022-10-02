class AddShippingAddressMigration < ActiveRecord::Migration[6.1]
  def change
    create_table :shipping_addresses, id: :string do |t|
      t.string :city
      t.string :zip
      t.string :street_address
      t.references :user, null: false, type: :string

      t.timestamps
    end
  end
end
