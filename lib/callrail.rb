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
      body = JSON.parse(response.to_str) if response.code == 200 || response.code == 201
      OpenStruct.new(code: response.code, body: body)
    end

    def set_params(opts = {})
      params = {}
      #Result params
        params[:date_range] = opts[:date_range] if opts[:date_range]
          # Values: recent, today, yesterday, last_7_days, last_30_days, this_month, last_month, all_time
        params[:start_date] = opts[:start_date] if opts[:start_date]
          # ex: “2015-09-05” for all calls after and including September 9, 2015 - “2015-09-05T10:00” for all calls after 10 AM September 5, 2015
        params[:end_date] = opts[:end_date] if opts[:end_date]
          # ex: “2015-10-05” for all calls before and including October 9, 2015 - “2015-09-05T10:00” for all calls before 10 AM September 5, 2015
        params[:sort] = opts[:sort] if opts[:sort]
          # ex: /users.json?sort=email Will return a list of user objects for the target account, sorted by email address in alphabetical order.
        params[:search] = opts[:search] if opts[:search]
          # ex: users.json?search=belcher Will return a list of user objects in the target account that match the name given.
        params[:fields] = opts[:fields] if opts[:fields]
          # ex: calls/444941612.json?fields=company_id,company_name Will return the additional user requested fields for the target call.
        params[:page] = opts[:page] || 1
        params[:per_page] = opts[:per_page] || MAX_PAGE_SIZE
        params[:path] = opts[:path] if opts[:path]
      #Filters
        if opts[:filtering]
          opts[:filtering].each do |filter|
            params[filter[:field].to_sym] = filter[:value]            
          end
        end
      #Shared Params
        params[:name] = opts[:name] if opts[:name]
      #Account Params
        # Sorting: id, name
      #Company Params
        # Sorting: id, name
        # Filtering: status
        # Searching: name
        params[:callscore_enabled] = opts[:callscore_enabled] if opts[:callscore_enabled]
        params[:keyword_spotting_enabled] = opts[:keyword_spotting_enabled] if opts[:keyword_spotting_enabled]
        params[:callscribe_enabled] = opts[:callscribe_enabled] if opts[:callscribe_enabled]
        params[:time_zone] = opts[:time_zone] if opts[:time_zone]
          # USA Values: America/New_York (Eastern Time Zone), America/Indiana/Indianapolis (Indiana Time Zone), America/Chicago (Central Time Zone), 
          #             America/Denver (Mountain Time Zone), America/Phoenix (Arizona Time Zone), America/Los_Angeles (Pacific Time Zone)
          #             Full List: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
        params[:swap_exclude_jquery] = opts[:swap_exclude_jquery] if opts[:swap_exclude_jquery]
        params[:swap_ppc_override] = opts[:swap_ppc_override] if opts[:swap_ppc_override]
        params[:swap_landing_override] = opts[:swap_landing_override] if opts[:swap_landing_override]
        params[:swap_cookie_duration] = opts[:swap_cookie_duration] if opts[:swap_cookie_duration]
      #User Params
        # Sorting: id, email, created_at
        # Searching: first_name, last_name, email
        params[:first_name] = opts[:first_name] if opts[:first_name]
        params[:last_name] = opts[:last_name] if opts[:last_name]
        params[:email] = opts[:email] if opts[:email]
        params[:role] = opts[:role] if opts[:role]      
        params[:password] = opts[:password] if opts[:password]
        params[:companies] = opts[:companies] if opts[:companies]
        params[:company_ids] = opts[:company_ids] if opts[:company_ids] #Callrail disabled
      #Tracker Params
        # Filtering: type, status
        params[:type] = opts[:type] if opts[:type]
        params[:company_id] = opts[:company_id] if opts[:company_id]
        params[:call_flow] = opts[:call_flow] if opts[:call_flow]
        params[:pool_size] = opts[:pool_size] if opts[:pool_size]
        params[:pool_numbers] = opts[:pool_numbers] if opts[:pool_numbers]
        params[:source] = opts[:source] if opts[:source]
        params[:swap_targets] = opts[:swap_targets] if opts[:swap_targets]
        params[:whisper_message] = opts[:whisper_message] if opts[:whisper_message]
        params[:sms_enabled] = opts[:sms_enabled] if opts[:sms_enabled]
        params[:tracking_number] = opts[:tracking_number] if opts[:tracking_number]
      #Integration Params
        params[:config] = opts[:config] if opts[:config] 
        params[:state] = opts[:state] if opts[:state]

      #Call Params
        # Sorting: customer_name, customer_phone_number, duration, start_time, source
        # Filtering: date_range, answer_status, device, direction, lead_status
        # Searching: caller_name, note, source, dialed_number, caller_number, outgoing_number
      #Text Message Params
        # Filtering: date_range
        # Searching: customer_phone_number, customer_name
      #pagination

      return params
    end

    def get_responses(opts = {})
      responses = []
      params = set_params(opts)
      response = parse_json(RestClient.get(@url+params[:path], params: params,:Authorization => @auth)).body
      total_pages = response["total_pages"] || 1
      total_records = response["total_records"] || 1              

      while total_pages > 0
        response = (opts[:data]) ? response[opts[:data]] : response 
        responses.push(response)
        params[:page] += 1 unless opts[:page]
        total_pages -= 1     
        response = parse_json(RestClient.get(@url+params[:path], params: params,:Authorization => @auth)).body unless total_pages < 1            
      end
      return responses.flatten! || responses
    end

# Account 
    def get_accounts(opts = {})
      opts[:path] = (opts[:account_id]) ? "/" + opts[:account_id].to_s + ".json" : ".json"
      opts[:data] = "accounts" unless  opts[:account_id]
      return get_responses(opts)  
    end

# Company 
    def get_companies(opts = {}) 
      opts[:path] = (opts[:company_id]) ? "/" + @account_id + "/companies/" + opts[:company_id].to_s + ".json" : "/" + @account_id + "/companies.json"
      opts[:data] = "companies" unless opts[:company_id]
      return get_responses(opts)
    end

    def create_company(opts = {}) # http://apidocs.callrail.com/#time-zones
      params = set_params(opts)
      path = "/" + @account_id + "/companies.json"
      response = parse_json(RestClient.post(@url+path, params ,:Authorization => @auth))
      return response   
    end

    def update_company(opts = {})
      params = set_params(opts) 
      path = "/" + @account_id + "/companies/" + opts[:company_id].to_s + ".json"
      return parse_json(RestClient.put(@url+path, params, :Authorization => @auth)).body      
    end

    def disable_company( opts = {})
      path = "/" + @account_id + "/companies/" + opts[:company_id].to_s
      return parse_json(RestClient.delete(@url+path, :Authorization => @auth))
    end

# User 
    def get_users( opts={} )
      opts[:path] = (opts[:user_id]) ? "/" + @account_id + "/users/" + opts[:user_id].to_s + ".json" : "/" + @account_id + "/users.json"
      opts[:data] = "users" unless opts[:user_id]
      return get_responses(opts)
    end

    def create_user( opts = {})
      params = set_params(opts)
      path = "/" + @account_id + "/users.json"
      return parse_json(RestClient.post(@url+path, params ,:Authorization => @auth))
    end

    def update_user(opts = {})
      params = set_params(opts) 
      path =  "/" + @account_id + "/users/" + opts[:user_id].to_s + ".json"
      return parse_json(RestClient.put(@url+path, params, :Authorization => @auth))      
    end

# Calls
  def get_calls( opts={} )
    opts[:path] = (opts[:call_id]) ? "/" + @account_id + "/calls/" + opts[:call_id].to_s + ".json" : "/" + @account_id + "/calls.json" 
    opts[:data] = "calls"  unless opts[:call_id]
    return get_responses(opts)
  end

# Tracker     
    def get_trackers(opts={})
      opts[:path] = (opts[:tracker_id]) ? "/" + @account_id + "/trackers/" + opts[:tracker_id].to_s + ".json" : "/" + @account_id + "/trackers.json"
      opts[:data] = "trackers" unless opts[:tracker_id]
      return get_responses(opts)
    end

    def create_tracker(opts={})
      opts[:path] = "/" + @account_id + "/trackers.json"
      params = set_params(opts)
      return parse_json(RestClient.post(@url+opts[:path], params ,:Authorization => @auth))
    end

    def update_tracker(opts={})
      path = "/" + @account_id + "/trackers/" + opts[:tracker_id].to_s + ".json"
      params = set_params(opts)
      return parse_json(RestClient.put(@url+path, params, :Authorization => @auth))  
    end

    def disable_tracker(opts={})
      path = "/" + @account_id + "/trackers/" + opts[:tracker_id].to_s + ".json"
      return parse_json(RestClient.delete(@url+path, :Authorization => @auth))
    end
  
  # Integrations
    def get_integrations(opts ={})
      opts[:path] = (opts[:integration_id]) ? "/" + @account_id + "/integrations/" + opts[:integration_id].to_s + ".json" : "/" + @account_id + "/integrations.json"
      opts[:data] = "integrations" unless opts[:integration_id]
      return get_responses(opts)
    end

    def create_integration(opts ={})
      opts[:path] = "/" + @account_id + "/integrations.json"
      params = set_params(opts)
      return parse_json(RestClient.post(@url+opts[:path], params ,:Authorization => @auth))
    end

    def update_integration(opts = {})
      params = set_params(opts) 
      path = "/" + @account_id + "/integrations/" + opts[:integration_id].to_s + ".json"
      return parse_json(RestClient.put(@url+path, params, :Authorization => @auth))      
   end

   def disable_integration(opts={})
      path = "/" + @account_id + "/integrations/" + opts[:integration_id].to_s + ".json"
      return parse_json(RestClient.delete(@url+path, :Authorization => @auth))
   end

  end
end
