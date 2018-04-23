require 'rest-client'
require 'json'
require 'nokogiri'
require 'uri'

class Transaction < ApplicationRecord

  belongs_to :user
  belongs_to :business, optional: true

  ## potentially unnecessary validation:
  #validates :description, uniqueness: { scope: [:date, :original, :amount] }

  def self.batch_analyze_by_month(query_year, query_month, user_id)
    my_transactions = Transaction.where(user_id: user_id).where('extract(year from date) = ? AND extract(month from date) = ?', query_year, query_month)

    my_transactions.each do |transaction|
      unless transaction.check_for_already_tagged_transactions(user_id)
        Adapter::OpenSecrets.new(transaction).initiate_org_search
      end
    end
  end

  def self.associate_all_matching_month_transactions(t_name, biz_id, query_year, query_month)
    my_transactions = Transaction.where('extract(year from date) = ? AND extract(month from date) = ?', query_year, query_month)
    matching_transactions = my_transactions.where(description: t_name)

    matching_transactions.each do |transaction|
      transaction.business_id = biz_id
      transaction.save
    end

  end

  #currently unused version of method above without date restrictions
  def self.associate_all_matching_transactions_with_business(t_name, biz_id)
    matching_transactions = Transaction.where(description: t_name)

    matching_transactions.each do |transaction|
      transaction.business_id = biz_id
      transaction.save
    end

  end

  def format_name
    self.description.gsub(/.com|\b(LLC|sq|squ|corp|corp.|inc.|inc|co|co.)\b/i, "").encode(Encoding.find('ASCII'), invalid: :replace, undef: :replace, replace: "")
  end

  def check_for_already_tagged_transactions(user_id)
      ts = Transaction.where(description: self.description)
      matches = ts.select do |t| t.business_id != nil end
      if matches.first
        my_ts = Transaction.where(description: self.description, user_id: user_id, business_id: nil)
        my_ts.each do |t|
          t.business_id = matches.first.business_id
          t.save
        end
        puts "matched all of user's transactions matching description of #{self.description}"
        return true
      end
      return nil
  end

  def no_api_match
    self.business_id = 1
    self.save

    Transaction.associate_all_matching_month_transactions(self.description, 1, self.date.year, self.date.month)
  end

  def successful_api_match(match_array)
    newBiz = Business.find_or_create_by(name: match_array[0].strip, org_id: match_array[1])
    self.business = newBiz
    self.save

    Transaction.associate_all_matching_month_transactions(self.description, newBiz.id, self.date.year, self.date.month)
  end



end
