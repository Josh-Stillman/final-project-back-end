require 'rest-client'
require 'json'
require 'nokogiri'
require 'uri'

module Adapter

  class OpenSecrets

    attr_accessor :transaction

    def self.test_api(start, fin)
      Transaction.all[start..fin].inject([]) do |acc, transaction|
        acc << transaction.query_name_api
      end
    end

    def initialize(transaction)
      @transaction = transaction
    end

    def initiate_org_search
      self.query_name_api if @transaction.business_id == nil
    end

    def query_name_api
      begin
        api_response = RestClient.get("https://www.opensecrets.org/api/?method=getOrgs&org=#{@transaction.format_name}&apikey=#{ENV['api_key']}")
      rescue RestClient::ExceptionWithResponse => e
        api_response = e.response
      end
      if api_response == "Resource not found or query was less than three characters"
        @transaction.no_api_match
      else
        self.api_match?(Nokogiri::XML(api_response))
      end
    end

    def api_match?(api_response)
      possibilities = []
      api_response.xpath("//response").children.each do |org|
        if org.attr('orgname').match(/\b(#{@transaction.format_name})\b/i)
          possibilities << [org.attr('orgname'), org.attr('orgid')]
        end
      end

      if possibilities.length == 0
        @transaction.no_api_match
      elsif possibilities.length == 1
        @transaction.successful_api_match(possibilities[0])
      elsif possibilities.length > 1
        Adapter::GoogleCustomSearch.new(@transaction).google_search_matches
      end
    end

  end

  class GoogleCustomSearch

    def initialize(transaction)
      @transaction = transaction
    end

    def google_search_matches
      resp = RestClient.get("https://www.googleapis.com/customsearch/v1?q=#{URI.escape(@transaction.format_name)}&cx=010681079516391757268%3A1pvx9xge4gg&exactTerms=#{URI.escape(@transaction.format_name)}&key=#{ENV['google_api_key']}")
      parsed = JSON.parse(resp)
      if parsed["queries"]["request"][0]["totalResults"]== "0"
        @transaction.no_api_match
        puts "no match"
      else
        puts parsed["items"][0]["title"].gsub(/:.*/, "")
        puts parsed["items"][0]["link"].gsub(/http.*id=|&cycle=.*/, "")
        @transaction.successful_api_match([parsed["items"][0]["title"].gsub(/:.*/, ""), parsed["items"][0]["link"].gsub(/http.*id=|&cycle=.*/, "") ])
      end
    end

  end

  class CampaignFinanceScaper

  end

end
