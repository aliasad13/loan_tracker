class CreateLoanAdjustments < ActiveRecord::Migration[6.1]
  def change
    create_table :loan_adjustments do |t|
      t.references :loan, null: false, foreign_key: true
      t.decimal :previous_amount
      t.decimal :new_amount
      t.decimal :previous_interest_rate
      t.decimal :new_interest_rate

      t.timestamps
    end
  end
end
