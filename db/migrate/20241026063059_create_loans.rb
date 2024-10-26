class CreateLoans < ActiveRecord::Migration[6.1]
  def change
    create_table :loans do |t|
      t.decimal :amount, precision: 15, scale: 2
      t.decimal :interest_rate, precision: 6, scale: 4
      t.string :state
      t.references :user, null: false, foreign_key: true
      t.decimal :total_amount_due, precision: 15, scale: 2

      t.timestamps
    end
  end
end

# precision 6 can hold upto 99.9999, after . comes scale