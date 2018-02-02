class CreateBusinesses < ActiveRecord::Migration[5.1]
  def change
    create_table :businesses do |t|
      t.string :name
      t.string :org_id
      t.string :desc1
      t.string :desc2

      t.timestamps
    end
  end
end
