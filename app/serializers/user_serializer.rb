class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :total_analyzed_transactions, :newest_month, :oldest_month, :next_month_to_analyze, :remaining_months_to_analyze, :number_matched_transactions, :number_unmatched_transactions, :percent_matched, :business_count, :oldest_transaction_month, :months_analyzed

  def total_analyzed_transactions
    object.total_analyzed_transactions.length
  end

  def next_month_to_analyze
    object.next_month_to_analyze
  end

  def remaining_months_to_analyze
    object.remaining_months_to_analyze
  end

  def number_matched_transactions
    object.matched_transactions.length
  end

  def number_unmatched_transactions
    object.unmatched_transactions.length
  end

  def percent_matched
      object.percent_matched
  end

  def business_count
    object.businesses.length
  end

  def oldest_transaction_month
    object.oldest_transaction_month
  end

  def months_analyzed
    object.months_analyzed
  end

end
