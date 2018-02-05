class User < ApplicationRecord
  has_many :transactions

  def matched_transactions
    Transaction.where(user: self).where.not(business_id: nil).where.not(business_id: 1).where(date: self.oldest_month..self.newest_month)


    #between two dates.
  end

  def unmatched_transactions
    Transaction.where(user: self).where(business_id: 1).where(date: self.oldest_month..self.newest_month)
  end

  #### - oldest date is Date.parse("November 2017")
  ## newest is Date.parse("November 2017").end_of_month

end
