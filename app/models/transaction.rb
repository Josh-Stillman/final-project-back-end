require 'rest-client'
require 'JSON'
require 'nokogiri'
require 'uri'

class Transaction < ApplicationRecord

  belongs_to :user
  belongs_to :business, optional: true

  def self.test_api(start, fin)
    self.all[start..fin].inject([]) do |acc, transaction|
      acc << transaction.query_name_api
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

  def self.batch_analyze_by_month(query_year, query_month, user_id)
    my_transactions = Transaction.where(user_id: user_id).where('extract(year from date) = ? AND extract(month from date) = ?', query_year, query_month)

    my_transactions.each do |transaction|
      transaction.initiate_org_search

    end
    #n|
    #   Transaction.associate_all_matching_transactions_with_business(transaction.description, transactino.business_id)
    # end

  end

  def format_name
    self.description.gsub(/.com|\b(LLC|sq|squ|corp|corp.|inc.|inc|co|co.)\b/i, "").encode(Encoding.find('ASCII'), invalid: :replace, undef: :replace, replace: "")
  end

  def initiate_org_search

    if self.business_id == nil
      self.query_name_api
    else
      puts "already matched"
    end

  end

  def check_hardcode_dictionary
    my_dictionary = {
      "J.Crew": "J Crew",
      "Stop & Shop": "Ahold Delhaize",
      "United Tx": "United Continental Holdings"
    }
  end

  def query_name_api

    #if this description matches a hard-coded dictionary entry, return that Instead
      #united tx => united airlines => United continental holdings, with ID.
      #go straight to create entity.

    begin
      api_response = RestClient.get("https://www.opensecrets.org/api/?method=getOrgs&org=#{self.format_name}&apikey=#{Rails.application.secrets.api_key}")
    rescue RestClient::ExceptionWithResponse => e
      api_response = e.response
    end
    if api_response == "Resource not found or query was less than three characters"
      self.no_match
    else
      self.api_match?(Nokogiri::XML(api_response))
    end
  end

  def api_match?(api_response)

    possibilities = []
    api_response.xpath("//response").children.each do |org|
      if org.attr('orgname').match(/\b(#{self.format_name})\b/i)
        possibilities << [org.attr('orgname'), org.attr('orgid')]
      end
    end

    if possibilities.length == 0
      self.no_match
    elsif possibilities.length == 1
      self.single_match(possibilities[0])
    elsif possibilities.length > 1
      self.google_search_matches
    end

  end

  def no_match
    self.business_id = 1
    self.save

    Transaction.associate_all_matching_month_transactions(self.description, 1, self.date.year, self.date.month)

    # matching_transactions = Transaction.where(description: self.description)
    #
    # matching_transactions.each do |transaction|
    #   transaction.business_id = 1
    #   transaction.save
    # end

  end

  def single_match(match_array)

    #find or create_by in the future?
    newBiz = Business.find_or_create_by(name: match_array[0].strip, org_id: match_array[1])
    self.business = newBiz
    self.save

    Transaction.associate_all_matching_month_transactions(self.description, newBiz.id, self.date.year, self.date.month)

    #kick off scraping in the Entity model
  end

  def self.associate_all_matching_transactions_with_business(t_name, biz_id)
    matching_transactions = Transaction.where(description: t_name)

    matching_transactions.each do |transaction|
      transaction.business_id = biz_id
      transaction.save
    end

  end


  def google_search_matches
    #working
    #https://www.google.com/search?as_q=&as_epq=verizon&as_qdr=all&as_sitesearch=https%3A%2F%2Fwww.opensecrets.org%2Forgs%2F&as_occt=any&safe=images
    # resp = Nokogiri::HTML(RestClient.get("https://www.google.com/search?as_q=&as_epq=#{self.format_name}&as_qdr=all&as_sitesearch=https%3A%2F%2Fwww.opensecrets.org%2Forgs%2F&as_occt=any&safe=images"))
    resp = RestClient.get("https://www.googleapis.com/customsearch/v1?q=#{URI.escape(self.format_name)}&cx=010681079516391757268%3A1pvx9xge4gg&exactTerms=#{URI.escape(self.format_name)}&key=#{Rails.application.secrets.google_api_key}")

    parsed = JSON.parse(resp)
    if parsed["queries"]["request"][0]["totalResults"]== "0"
      self.no_match
      puts "no match"
    else
      puts parsed["items"][0]["title"].gsub(/:.*/, "")
      puts parsed["items"][0]["link"].gsub(/http.*id=|&cycle=.*/, "")
      self.single_match([parsed["items"][0]["title"].gsub(/:.*/, ""), parsed["items"][0]["link"].gsub(/http.*id=|&cycle=.*/, "") ])
    end


    # unless !!resp.css("cite")[0]
    #   self.no_match
    # else
      # puts resp.css("div.obp div.med").text
      #
      #
      # #
      # org_name = resp.css("h3.r a")[0].text
      # org_id = resp.css("cite")[0].text.match(/id=.*/)[0]
      # org_id.gsub(/id=/, "")
      # [org_name.gsub(/:.*/, ""), org_id.gsub(/id=/, "")]


      #self.single_match([org_name, org_id.gsub(/id=/, "")])
    # end

  end

end


#handle more than one possibility
  #google advanced search

#handle no possibilities
  #option to google search

#handle one possibility
  #go ahead and make the association.  offer user ability to reassociate.

#categorize all subsequent transactions matching that name.

#add a column to transactions to determine whether it's been checked.
  #keep track of which months have been checked. class method that tells you where to resume searching. also checks for new data.



#handle how fast this is happening and limits.  I think it has to be one month at a time.  Gives you data to display initially as it loads.

##################################

#   1. format the name
#   2. query the API with the name
#   3. If no matches, try again and/or query google.  IF multiple matches, do something else.
#   4. save organization with new ID
#     5. Find all matching transactions, add belongs to that organization.
#
#   5.Go to website, scrape website.
#   6. From website XML, create "Cycle objects" belonging to the organization.

#end
