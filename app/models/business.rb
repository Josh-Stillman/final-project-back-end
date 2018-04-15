require 'nokogiri'

class Business < ApplicationRecord
  has_many :transactions
  has_many :cycles
  after_create :get_2016_and_2018_cycles

  def self.populate_cycles
    self.all.each do |biz|
      unless biz.id == 1 || biz.cycles != []
        biz.get_2016_and_2018_cycles
      end
    end
  end

  def user_total_spending(user_id)
    @user = User.find(user_id)
    self.transactions.where(user_id: user_id).where(date: @user.oldest_month..@user.newest_month).sum(:amount)
  end

  def total_dem
    unless self.cycles == []
      self.cycles[0].dem_amount + self.cycles[1].dem_amount
    end

  end

  def total_rep
    unless self.cycles == []
    self.cycles[0].rep_amount + self.cycles[1].rep_amount
    end
  end

  def total_dem_pct
    unless self.cycles == []
    (self.total_dem.to_f / self.total_amount.to_f).round(2)
    end
  end

  def total_rep_pct
    unless self.cycles == []
    (self.total_rep.to_f  / self.total_amount.to_f).round(2)
    end
  end

  def total_amount
    unless self.cycles == []
    self.total_dem + self.total_rep
    end
  end

  def get_2016_and_2018_cycles
    data = Adapter::CampaignFinanceScaper.new(self).get_2016_and_2018_cycles
    data ? self.populate_campaign_cycles(data[0], data[1]) : self.no_campaign_finance_data
  end

  def no_campaign_finance_data
    self.transactions.each do |t|
      t.business_id = 1
      t.save
    end
    self.destroy
  end

  def populate_campaign_cycles(data_2018, data_2016)
    Cycle.create(year: data_2018[0].text, total: data_2018[1].text.gsub(/\D/, '').to_i, dem_amount: data_2018[2].text.gsub(/\D/, '').to_i, rep_amount: data_2018[3].text.gsub(/\D/, '').to_i, dem_pct: data_2018[4].text.gsub(/\D/, '').to_i, rep_pct: data_2018[5].text.gsub(/\D/, '').to_i, business: self)

    Cycle.create(year: data_2016[0].text, total: data_2016[1].text.gsub(/\D/, '').to_i, dem_amount: data_2016[2].text.gsub(/\D/, '').to_i, rep_amount: data_2016[3].text.gsub(/\D/, '').to_i, dem_pct: data_2016[4].text.gsub(/\D/, '').to_i, rep_pct: data_2016[5].text.gsub(/\D/, '').to_i, business: self)
  end

end
