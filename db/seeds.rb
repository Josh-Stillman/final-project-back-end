# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Date.strptime("6/15/2012", '%m/%d/%Y')
require 'activerecord-import'
require 'csv'


Transaction.destroy_all
User.create(name: "Josh")

columns = [:date, :description, :original, :amount, :category, :user_id]
values = []
# i = 1

CSV.foreach('./db/transactions.csv', headers: true) do |row|
  # if i == 11
  #   break
  # end
  # i += 1

  unless row[4] == "credit"
    row_date = Date.strptime(row[0], '%m/%d/%Y')
    row_array = [row_date, row[1], row[2], row[3].to_f, row[5], 1]
    values << row_array
  end



end

Transaction.import columns, values, :validate => false
