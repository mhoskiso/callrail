require 'bundler/setup'
require "callrail/version"
require 'json'
require 'ostruct'
require 'rest-client'

module Callrail
  class Api

    MAX_PAGE_SIZE = '250'

    def initialize(opts = {})
      @url = 'https://api.callrail.com/v2/a'
      @auth = "Token token=" + opts[:key]
      @account_id = opts[:account_id].to_s if opts[:account_id]  
    end

    def set_account_id(opts = {})
      @account_id = opts[:account_id].to_s
    end    

    def parse_json(response)
      body = JSON.parse(response.to_str) if response.code == 200
      OpenStruct.new(code: response.code, body: body)
    end

    def set_params(opts = {})
      params = {}
      #Pagination params
      params[:page] = opts[:page] || 1
      params[:per_page] = opts[:per_page] || MAX_PAGE_SIZE
      params[:path] = opts[:path] if opts[:path]
      params[:total_records] = get_total_records(params) if opts[:path]
      params[:total_pages] = get_total_pages(params) if opts[:path]
      #Company Params
      params[:name] = opts[:name] if opts[:name]
      params[:callscore_enabled] = opts[:callscore_enabled] if opts[:callscore_enabled]
      params[:keyword_spotting_enabled] = opts[:keyword_spotting_enabled] if opts[:keyword_spotting_enabled]
      params[:callscribe_enabled] = opts[:callscribe_enabled] if opts[:callscribe_enabled]
      params[:time_zone] = opts[:time_zone] if opts[:time_zone]
      params[:swap_exclude_jquery] = opts[:swap_exclude_jquery] if opts[:swap_exclude_jquery]
      params[:swap_ppc_override] = opts[:swap_ppc_override] if opts[:swap_ppc_override]
      params[:swap_landing_override] = opts[:swap_landing_override] if opts[:swap_landing_override]
      params[:swap_cookie_duration] = opts[:swap_cookie_duration] if opts[:swap_cookie_duration]
      return params
    end

    def get_total_records(params)
      total_records = parse_json(RestClient.get(@url+params[:path], params: params, :content_type => 'application/json', :accept => 'application/json', :Authorization => @auth)).body['total_records'] || 1      
      return total_records
    end

    def get_total_pages(params)
      total_pages = parse_json(RestClient.get(@url+params[:path], params: params, :content_type => 'application/json', :accept => 'application/json', :Authorization => @auth)).body['total_pages'] || 1      
      return total_pages
    end

    def get_responses(opts = {})
      responses = []
      params = set_params(opts)
      while params[:total_pages] > 0      
        response = parse_json(RestClient.get(@url+params[:path], params: params,:Authorization => @auth)).body
        response = (opts[:data]) ? response[opts[:data]] : response
        responses.push(response)
        params[:page] += 1 unless opts[:page]
        params[:total_pages] -= 1
      end
      return responses
    end

    def get_accounts(opts = {})
      opts[:path] = (opts[:account_id]) ? "/" + opts[:account_id].to_s + ".json" : ".json"
      opts[:data] = "accounts" unless  opts[:account_id]
      results = get_responses(opts)  
      return results
    end

    def get_companies(opts = {}) 
      opts[:path] = (opts[:company_id]) ? "/" + @account_id + "/companies/" + opts[:company_id].to_s + ".json" : "/" + @account_id + "/companies.json"
      opts[:data] = "companies" unless opts[:company_id]
      results = get_responses(opts)
      return results
    end

    def create_company(opts = {}) # http://apidocs.callrail.com/#time-zones
      params = set_params(opts)
      path = "/" + @account_id + "/companies.json"
      response = parse_json(RestClient.post(@url+path, params ,:Authorization => @auth))
      return response.code    
    end

    def update_company(opts = {})
      params = set_params(opts) 
      path = "/" + @account_id + "/companies/" + opts[:company_id].to_s
      response = parse_json(RestClient.put(@url+path, params, :Authorization => @auth))      
    end

    def disable_company( opts = {})
      path = "/" + @account_id + "/companies/" + opts[:company_id].to_s
      response = parse_json(RestClient.delete(@url+path, :Authorization => @auth))
    end

    def get_users( opts={} )
      path = (opts[:user_id]) ? "/" + @account_id + "/users/" + opts[:user_id].to_s + ".json" : "/" + @account_id + "/users.json"
      results = (opts[:user_id]) ? parse_json(RestClient.get(@url+path, :Authorization => @auth)).body : parse_json(RestClient.get(@url+path, :Authorization => @auth)).body['users']
    end

    def get_calls(opts={})

    end

  end
end
