class AddLastInterestCalculationAtToLoans < ActiveRecord::Migration[6.1]
  def change
    add_column :loans, :last_interest_calculation_at, :timestamp
  end
end
