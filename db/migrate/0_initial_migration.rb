class InitialMigration < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :email, null: false

      t.timestamps
    end

    create_table :auctions do |t|
      t.string :name
      t.string :description
      t.string :status
      t.float :package_weight
      t.float :package_size_x
      t.float :package_size_y
      t.float :package_size_z
      t.references :creator, null: false
      t.references :winner
      t.datetime :finishes_at

      t.timestamps
    end

    create_table :bids do |t|
      t.references :bidder
      t.references :auction
      t.money :amount

      t.timestamps
    end

    create_table :orders do |t|
      t.references :auction
      t.money :total_payment
      t.string :shipping_method
      t.string :payment_method
      t.string :status

      t.timestamps
    end
  end
end
