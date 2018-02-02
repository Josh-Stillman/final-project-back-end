require 'rest-client'
require 'JSON'
require 'nokogiri'

class Transaction < ApplicationRecord

  belongs_to :user

  def self.test_api(start, fin)
    self.all[start..fin].inject([]) do |acc, transaction|
      acc << transaction.query_name_api
    end
  end

  def format_name
    search_name = self.description
    self.description.gsub(/.com|LLC|\bsq\b|\bsqu\b|\bcorp\b|\bcorp.\b|\binc.\b|\binc\b|\bco\b|\bco.\b/i, "")
  end

  def query_name_api
    begin
      api_response = RestClient.get("https://www.opensecrets.org/api/?method=getOrgs&org=#{self.format_name}&apikey=#{Rails.application.secrets.api_key}")
    rescue RestClient::ExceptionWithResponse => e
      api_response = e.response
    end
    if api_response == "Resource not found or query was less than three characters"
      [self.format_name, "no match"]
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
    possibilities
  end

  def no_match
    puts "no match"
  end

  def multiple_matches
    resp = Nokogiri::HTML(RestClient.get("https://www.google.com/search?as_q=&as_epq=#{self.format_name}&as_sitesearch=https%3A%2F%2Fwww.opensecrets.org%2Forgs"))
    unless !!resp.css("cite")[0]
      self.no_match
    else
      org_id = resp.css("cite")[0].text.match(/id=.*/)[0]
      org_id.gsub(/id=/, "")
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

#set up google custom search engine and register for api key.


#   1. format the name
#   2. query the API with the name
#   3. If no matches, try again and/or query google.  IF multiple matches, do something else.
#   4. save organization with new ID
#     5. Find all matching transactions, add belongs to that organization.
#
#   5.Go to website, scrape website.
#   6. From website XML, create "Cycle objects" belonging to the organization.

end
