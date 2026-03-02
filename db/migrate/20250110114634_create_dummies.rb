class CreateDummies < ActiveRecord::Migration[6.1]
  def change
    create_table :dummies do |t|
      t.string :name
      t.integer :age
      t.datetime :born_at

      t.timestamps
    end
  end
end
