require "callrail/version"
require 'json'
require 'ostruct'
require 'rest-client'

module Callrail
  class Api

    def initialize(key)
      @url = 'https://api.callrail.com/v2/a'
      $auth = "Token " + key      
    end

    def parse_json(response)
      body = JSON.parse(response.to_str) if response.code == 200
      OpenStruct.new(code: response.code, body: body)
    end

    def get_accounts
      path = ".json"
      results = parse_json(RestClient.get(@url+path, :Authorization => $auth)).body['accounts']
    end

    def get_companies(opts = {}) 
      path = (opts['company_id']) ? "/" + opts['account_id'].to_s + "/companies/" + opts['company_id'].to_s + ".json" : "/" + opts['account_id'].to_s + "/companies.json"
      results = (opts['company_id']) ? parse_json(RestClient.get(@url+path, :Authorization => $auth)).body : parse_json(RestClient.get(@url+path, :Authorization => $auth)).body['companies']
    end

    def create_company(opts = {}) # http://apidocs.callrail.com/#time-zones
      path = "/" + opts['account_id'].to_s + "/companies.json"

    end

    def get_users( opts={} )
      path = (opts['user_id']) ? "/" + opts['account_id'].to_s + "/users/" + opts['user_id'].to_s + ".json" : "/" + opts['account_id'].to_s + "/users.json"
      results = (opts['user_id']) ? parse_json(RestClient.get(@url+path, :Authorization => $auth)).body : parse_json(RestClient.get(@url+path, :Authorization => $auth)).body['users']
    end

    def get_calls( opts={} )

    end

  end
end
