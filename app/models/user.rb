class User < ApplicationRecord
  has_many :transactions
  has_many :businesses, -> { distinct }, through: :transactions
  has_secure_password

  def matched_transactions
    Transaction.where(user: self).where.not(business_id: nil).where.not(business_id: 1).where(date: self.oldest_month..self.newest_month)


    #between two dates.
  end

  def unmatched_transactions
    Transaction.where(user: self).where(business_id: 1).where(date: self.oldest_month..self.newest_month)
  end

  def total_analyzed_transactions
    Transaction.where(user: self).where.not(business_id: nil).where(date: self.oldest_month..self.newest_month)
  end

  def percent_matched
    num = self.matched_transactions.length.to_f / self.total_analyzed_transactions.length.to_f
    num.round(2)
  end

  def next_month_to_analyze
    self.remaining_months_to_analyze > 0 ? self.oldest_month.prev_month : nil
  end

  def remaining_months_to_analyze
    date1 = self.transactions.order(date: :asc).first.date.beginning_of_month
    date2 = self.oldest_month
    remaining_months = (date2.year * 12 + date2.month) - (date1.year * 12 + date1.month)
  end

  def oldest_transaction_month
    self.transactions.order(date: :asc).first.date.beginning_of_month
  end

  def months_analyzed
    date1 = self.oldest_month
    date2 = self.newest_month
    remaining_months = (date2.year * 12 + date2.month) - (date1.year * 12 + date1.month) + 1
  end
  #### - oldest date is Date.parse("November 2017")
  ## newest is Date.parse("November 2017").end_of_month

end
