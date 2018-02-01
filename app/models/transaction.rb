require 'rest-client'
require 'JSON'
require 'nokogiri'

class Transaction < ApplicationRecord

  def format_name
    search_name = self.description
    self.description.gsub(/.com|LLC|sq |squ /, "")
  end

  def query_name_api
    begin
      api_response = RestClient.get("https://www.opensecrets.org/api/?method=getOrgs&org=#{self.format_name}&apikey=#{Rails.application.secrets.api_key}")
    rescue RestClient::ExceptionWithResponse => e
      api_response = e.response
    end
    if api_response === "Resource not found or query was less than three characters"
      puts api_response
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





#   1. format the name
#   2. query the API with the name
#   3. If no matches, try again and/or query google.  IF multiple matches, do something else.
#   4. save organization with new ID
#     5. Find all matching transactions, add belongs to that organization.
#
#   5.Go to website, scrape website.
#   6. From website XML, create "Cycle objects" belonging to the organization.

end
