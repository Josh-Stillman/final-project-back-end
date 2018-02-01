class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.date :date
      t.string :description
      t.string :original
      t.float :amount
      t.string :category

      t.timestamps
    end
  end
end
