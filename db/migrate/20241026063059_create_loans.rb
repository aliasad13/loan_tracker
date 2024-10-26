class CreateLoans < ActiveRecord::Migration[6.1]
  def change
    create_table :loans do |t|
      t.decimal :amount
      t.decimal :interest_rate
      t.string :state
      t.references :user, null: false, foreign_key: true
      t.decimal :total_amount_due

      t.timestamps
    end
  end
end
