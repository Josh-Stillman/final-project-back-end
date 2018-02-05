class CreateCycles < ActiveRecord::Migration[5.1]
  def change
    create_table :cycles do |t|
      t.string :year
      t.integer :total
      t.integer :dem_amount
      t.integer :rep_amount
      t.integer :dem_pct
      t.integer :rep_pct
      t.belongs_to :business, foreign_key: true

      t.timestamps
    end
  end
end
