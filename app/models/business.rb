class Business < ApplicationRecord
  has_many :transactions
  has_many :cycles
  after_create :get_2016_and_2018_cycles

  def user_total_spending(user_id)
    self.transactions.where(user_id: user_id).sum(:amount)
  end

  def total_dem
    self.cycles[0].dem_amount + self.cycles[1].dem_amount
  end

  def total_rep
    self.cycles[0].rep_amount + self.cycles[1].rep_amount
  end

  def total_dem_pct
    (self.total_dem.to_f / self.total_amount.to_f).round(2)
  end

  def total_rep_pct
    (self.total_rep.to_f  / self.total_amount.to_f).round(2)
  end

  def total_amount
    self.total_dem + self.total_rep
  end


  def self.populate_cycles

    self.all.each do |biz|
      unless biz.id == 1 || biz.cycles != []
        biz.get_2016_and_2018_cycles
      end

      end
  end



  def get_2016_and_2018_cycles
    resp = Nokogiri::HTML(RestClient.get("https://www.opensecrets.org/orgs/totals.php?id=#{self.org_id}"))
    row_18 = resp.css(".datadisplay tr")[1]
    row_16 = resp.css(".datadisplay tr")[2]
    row_18_nums = row_18.css("td")
    row_16_nums = row_16.css("td")


    Cycle.create(year: row_18_nums[0].text, total: row_18_nums[1].text.gsub(/\D/, '').to_i, dem_amount: row_18_nums[2].text.gsub(/\D/, '').to_i, rep_amount: row_18_nums[3].text.gsub(/\D/, '').to_i, dem_pct: row_18_nums[4].text.gsub(/\D/, '').to_i, rep_pct: row_18_nums[5].text.gsub(/\D/, '').to_i, business: self)

    Cycle.create(year: row_16_nums[0].text, total: row_16_nums[1].text.gsub(/\D/, '').to_i, dem_amount: row_16_nums[2].text.gsub(/\D/, '').to_i, rep_amount: row_16_nums[3].text.gsub(/\D/, '').to_i, dem_pct: row_16_nums[4].text.gsub(/\D/, '').to_i, rep_pct: row_16_nums[5].text.gsub(/\D/, '').to_i, business: self)

    #scrape description from summary page?  <div class="about_org">

  end
end
