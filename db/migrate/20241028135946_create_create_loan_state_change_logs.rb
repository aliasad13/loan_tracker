class CreateCreateLoanStateChangeLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :loan_state_change_logs do |t|
      t.references :loan
      t.string :state

      t.timestamps
    end
  end
end
