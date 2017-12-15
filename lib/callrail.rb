require 'bundler/setup'
require "callrail/version"
require 'json'
require 'ostruct'
require 'rest-client'

module Callrail
  class Api

    MAX_PAGE_SIZE = '250'

    def initialize(key)
      @url = 'https://api.callrail.com/v2/a'
      $auth = "Token " + key      
    end

    def parse_json(response)
      body = JSON.parse(response.to_str) if response.code == 200
      OpenStruct.new(code: response.code, body: body)
    end

    def set_params(opts)
      params = {}
      params[:page] = opts[:page] || 1
      params[:page_request] = true if opts[:page]
      params[:per_page] = opts[:per_page] || MAX_PAGE_SIZE
      params[:path] = opts[:path]
      params[:total_records] = get_total_records(params)
      params[:total_pages] = get_total_pages(params)
      params[:data] = opts[:data] || ""
      return params
    end

    def get_total_records(params)
      total_records = parse_json(RestClient.get(@url+params[:path], params: params, :content_type => 'application/json', :accept => 'application/json', :Authorization => $auth)).body['total_records'] || 1      
      return total_records
    end

    def get_total_pages(params)
      total_pages = parse_json(RestClient.get(@url+params[:path], params: params, :content_type => 'application/json', :accept => 'application/json', :Authorization => $auth)).body['total_pages'] || 1      
      return total_pages
    end

    def get_responses(params)
      responses = []
      while params[:total_pages] > 0      
        response = parse_json(RestClient.get(@url+params[:path], params: params,:Authorization => $auth)).body
        responses.push(response)
        params[:page] += 1 unless params[:page_request]
        params[:total_pages] -= 1
      end
      return responses
    end

    def get_accounts(opts = {})
      opts[:path] = ".json"
      opts[:data] = "accounts"
      params = set_params(opts)   
      responses = get_responses(params)

      return results
    end

    def get_companies(opts = {}) 
      opts[:path] = (opts['company_id']) ? "/" + opts['account_id'].to_s + "/companies/" + opts['company_id'].to_s + ".json" : "/" + opts['account_id'].to_s + "/companies.json"
      opts[:data] = (opts['company_id']) ? "" : "companies"
      params = set_params(opts) 
      results = (opts['company_id']) ? parse_json(RestClient.get(@url+path, :Authorization => $auth)).body : parse_json(RestClient.get(@url+path, :Authorization => $auth)).body['companies']
    end

    def create_company(opts = {}) # http://apidocs.callrail.com/#time-zones
      opts[:path] = "/" + opts['account_id'].to_s + "/companies.json"

    end

    def get_users( opts={} )
      path = (opts['user_id']) ? "/" + opts['account_id'].to_s + "/users/" + opts['user_id'].to_s + ".json" : "/" + opts['account_id'].to_s + "/users.json"
      results = (opts['user_id']) ? parse_json(RestClient.get(@url+path, :Authorization => $auth)).body : parse_json(RestClient.get(@url+path, :Authorization => $auth)).body['users']
    end

    def get_calls( opts={} )

    end

  end
end
