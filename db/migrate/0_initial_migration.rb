class InitialMigration < ActiveRecord::Migration[6.1]
  def change
    create_table :users, id: :string do |t|
      t.string :email, null: false

      t.timestamps
    end

    create_table :auctions, id: :string do |t|
      t.string :name
      t.string :description
      t.string :status
      t.float :package_weight
      t.float :package_size_x
      t.float :package_size_y
      t.float :package_size_z
      t.references :creator, null: false, type: :string
      t.references :winner, type: :string
      t.datetime :finishes_at

      t.timestamps
    end

    create_table :bids, id: :string do |t|
      t.references :bidder, type: :string
      t.references :auction, type: :string
      t.decimal :amount, precision: 10, scale: 2

      t.timestamps
    end

    create_table :orders, id: :string do |t|
      t.string :reference_number
      t.references :auction, type: :string
      t.references :buyer, type: :string
      t.decimal :total_payment, precision: 10, scale: 2
      t.string :shipping_method
      t.string :payment_method
      t.string :status

      t.timestamps
    end
  end
end
