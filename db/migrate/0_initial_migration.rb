class InitialMigration < ActiveRecord::Migration[6.1]
  def change
    enable_extension "pgcrypto"

    create_table :users, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :email, null: false

      t.timestamps
    end

    create_table :auctions, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :name
      t.string :description
      t.string :status
      t.float :package_weight
      t.float :package_size_x
      t.float :package_size_y
      t.float :package_size_z
      t.references :creator, null: false, type: :uuid
      t.references :winner, type: :uuid
      t.datetime :finishes_at

      t.timestamps
    end

    create_table :bids, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :bidder, type: :uuid
      t.references :auction, type: :uuid
      t.money :amount

      t.timestamps
    end

    create_table :orders, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :auction, type: :uuid
      t.money :total_payment
      t.string :shipping_method
      t.string :payment_method
      t.string :status

      t.timestamps
    end
  end
end
