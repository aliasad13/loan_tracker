class CreateLoanAdjustments < ActiveRecord::Migration[6.1]
  def change
    create_table :loan_adjustments do |t|
      t.references :loan, null: false, foreign_key: true
      t.decimal :previous_amount, precision: 15, scale: 2
      t.decimal :new_amount, precision: 15, scale: 2
      t.decimal :previous_interest_rate, precision: 6, scale: 4
      t.decimal :new_interest_rate, precision: 6, scale: 4

      t.timestamps
    end
  end
end