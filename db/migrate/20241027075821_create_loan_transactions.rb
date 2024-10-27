class CreateLoanTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :loan_transactions do |t|
      t.references :loan, null: false, foreign_key: true
      t.decimal :transaction_amount, precision: 15, scale: 2

      t.timestamps
    end
  end
end
