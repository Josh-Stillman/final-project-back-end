class User < ApplicationRecord
  has_many :transactions
  has_many :businesses, -> { distinct }, through: :transactions

  validates :name, uniqueness: true, presence: true
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
    if self.transactions != []
      self.remaining_months_to_analyze > 0 ? self.oldest_month.prev_month.strftime("%B, %Y") : nil
    end
  end

  def remaining_months_to_analyze
    if self.transactions != []
      date1 = self.transactions.order(date: :asc).first.date.beginning_of_month
      date2 = self.oldest_month
      remaining_months = (date2.year * 12 + date2.month) - (date1.year * 12 + date1.month)
    end
  end

  def oldest_transaction_month
    if self.transactions != []
      self.transactions.order(date: :asc).first.date.beginning_of_month
    end

  end

  def months_analyzed
    if self.transactions != []
      date1 = self.oldest_month
      date2 = self.newest_month
      remaining_months = (date2.year * 12 + date2.month) - (date1.year * 12 + date1.month) + 1
    end
  end

  def load_new_month
    if self.next_month_to_analyze
      Transaction.batch_analyze_by_month(self.oldest_month.prev_month.year, self.oldest_month.prev_month.month, self.id)
      if self.oldest_transaction_month < self.oldest_month.prev_month
        self.oldest_month = self.oldest_month.prev_month
        self.save
      end
    end

    #need to set user data re what months have been analyzed.
  end
  #### - oldest date is Date.parse("November 2017")
  ## newest is Date.parse("November 2017").end_of_month

end
