class AddBusinessIdToTransaction < ActiveRecord::Migration[5.1]
  def change
    add_reference :transactions, :business, foreign_key: true
  end
end
