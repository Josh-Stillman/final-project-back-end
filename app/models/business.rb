class Business < ApplicationRecord
  has_many :transactions
  has_many :cycles
  after_create :get_2016_and_2018_cycles
  #has_many :cycles



  def get_2016_and_2018_cycles
    resp = Nokogiri::HTML(RestClient.get("https://www.opensecrets.org/orgs/totals.php?id=#{self.org_id}"))
    row_18 = resp.css(".datadisplay tr")[1]
    row_16 = resp.css(".datadisplay tr")[2]
    row_18_nums = row_18.css("td")
    row_16_nums = row_16.css("td")

    Cycle.create(year: row_18_nums[0], total: row_18_nums[1], dem_amount: row_18_nums[2], rep_amount: row_18_nums[3], dem_pct: row_18_nums[4], rep_pct: row_18_nums[5], business: self)

    Cycle.create(year: row_16_nums[0], total: row_16_nums[1], dem_amount: row_16_nums[2], rep_amount: row_16_nums[3], dem_pct: row_16_nums[4], rep_pct: row_16_nums[5], business: self)

    


    #scrape description if any
    #create two cycle objects - 2016 and 2018
    #totals?
  end
end
