class AddNewestMonthToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :newest_month, :date
    add_column :users, :oldest_month, :date
  end
end
