# Callrail

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/callrail`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'callrail'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install callrail

## Usage
###### Time options
Callrail defaults to last_30_days if a date range isn't specified.
opts[:date_range] - Values: recent, today, yesterday, last_7_days, last_30_days, this_month, last_month, all_time
opts[:start_date] - ex: “2015-09-05” for all calls after and including September 9, 2015 - “2015-09-05T10:00” for all calls after 10 AM September 5, 2015
opts[:end_date] - ex: “2015-10-05” for all calls before and including October 9, 2

* *Examples of what is currently enabled

###### Setting Connection
```ruby
opts = {}
opts[:key] = "<Your Callrail API Key>"
opts[:account_id] = <your_account_id> 
```
* * Account ID is optional for the initial connection. You can set the account id later if you need to retrieve it first.

``` testcon = Callrail::Api.new(:key => opts[:key]) ```



###### Get Accounts
``` testcon.get_accounts ```


###### Set Specific Account

```
opts[:account_id] = <your_account_id>
testcon.set_account_id(:account_id => opts[:account_id])
```
** Account ID must be set for everything but Get Accounts

###### Get Companies

```testcon.get_companies() ```

###### Get a specific Company 
``` opts[:company_id] = <company_id> ```
``` testcon.get_companies(:company_id => opts[:company_id]) ```

###### Create a Company
```
opts = {}
opts[:name] = "XXX - Test Company 1"
opts[:time_zone] = "America/Los_Angeles" # 
testcon.create_company(:name => opts[:name])
```


###### Update a Company
```
opts = {}
opts[:name] = "XXX - Test Company 2"
opts[:company_id] = <company_id> 
# opts[:time_zone] = "America/Phoenix"
# opts[:callscore_enabled] = false
# opts[:keyword_spotting_enabled] = false
# opts[:callscribe_enabled] = false
# opts[:swap_exclude_jquery] = true
# opts[:swap_ppc_override] = false
# opts[:swap_landing_override] = nil
# opts[:swap_cookie_duration] = 90
testcon.update_company(:company_id => opts[:company_id], :time_zone => opts[:time_zone] )
```

###### Disable a Company
```
opts = {}
opts[:company_id] = <company_id>
testcon.disable_company(opts)
```
###### Get Users
``` testcon.get_users ```

###### Get Users For a specific company
```
user_opts = {:company_id => <company_id>}
puts testcon.get_users(user_opts)
```

###### Get Specific User
```
opts[:user_id] = <user_id>
testcon.get_users(:user_id => opts[:user_id] )
```

###### Create User
```
user_opts ={}
user_opts[:first_name] = "User"
user_opts[:last_name] = "Test"
user_opts[:email] = "test@test.com"
user_opts[:role] = "reporting"      
user_opts[:password] = '<password>'
user_opts[:companies] = [<company_id>, <company_id2>, <company_id3>]
testcon.create_user(user_opts)
```

###### Update a user
```
user_opts[:user_id] = <user_id>
user_opts[:last_name] = "Test2"
testcon.update_user(user_opts)
```

###### Get Trackers
```
tracker_options = {}
testcon.get_trackers(tracker_options)
```

###### Get Trackers for a Company
```
tracker_options[:company_id] = <company_id>
testcon.get_trackers(tracker_options)
```

###### Get a specific tracker
```
tracker_options = {}
tracker_options[:tracker_id] = <tracker_id>
testcon.get_trackers(tracker_options)
```

###### Tracker Filtering
```
tracker_options = {}
tracker_options[:filtering] = [{:field => "type", :value => "source"},{:field => "status", :value => "active"}]
puts "Filters: 1. #{tracker_options[:filtering][0][:field]} =  #{tracker_options[:filtering][0][:value]} 2. #{tracker_options[:filtering][1][:field]} =  #{tracker_options[:filtering][1][:value]}  "
testcon.get_trackers(tracker_options)
```

###### Create a Source Tracker
```
tracker_options = {}
tracker_options[:name] = "Test Source tracker"
tracker_options[:type] = "source"
tracker_options[:company_id] = <company_id>
tracker_options[:call_flow] = {:type => "basic", :recording_enabled => true, :destination_number => "+15555555555", :greeting_text => nil, :greeting_recording_url => nil}
tracker_options[:tracking_number] = {:area_code => "555", :local => "+15555555555"}
tracker_options[:source] = {:type => "all"}
tracker_options[:sms_enabled] = true
tracker_options[:whisper_message] = "This is a test number call"
testcon.create_tracker(tracker_options)
```
###### Update a Source Tracker
tracker_options = {}
tracker_options[:source] = {:type => "search", :search_engine => "all", :search_type => "paid"}
tracker_options[:tracker_id] = <tracker_id>
puts testcon.update_tracker(tracker_options)

###### Get Calls   
# Sorting: customer_name, customer_phone_number, duration, start_time, source
# Filtering: date_range, answer_status, device, direction, lead_status
# Searching: caller_name, note, source, dialed_number, caller_number, outgoing_number
        
```
call_options = {}
testcon.get_calls(call_options)
```

###### Get a specific call
```
call_options = {call_id: <call_id>}
testcon.get_calls(call_options)
```

###### Update a specific call
```
call_options = {call_id: <call_id>}
call_options[:note] = "Test"
testcon.update_call(call_options)
```
###### Get Calls summary
# Summary Grouping: source, keywords, campaign, referrer, landing_page, or company
# Summary Fields: total_calls, missed_calls, answered_calls, first_time_callers, average_duration, formatted_average_duration, leads. Defaults to total_calls
```
summary_options = {group_by: "campaign"}
testcon.get_calls_summary(summary_options)
```

For a time series (grouped by date), set  summary_options[:time_series] = true


###### Getting Call recording URL
```
call_options = {}
call_options[:call_id] = >call_id>
puts testcon.get_call_recording(call_options)
```

###### Getting Integrations for a company
```
int_opts = {}
int_opts[:company_id] = <company_id>
testcon.get_integrations(int_opts)
```

###### Getting a specific Integrations
```
int_opts = {}
int_opts[:integration_id] = <integration_id>
testcon.get_integrations(int_opts)
```
###### Creating a Webhook Integration
```
int_opts = {}
int_opts[:company_id] = <company_id>
int_opts[:type] = "Webhooks"
int_opts[:config] = {:post_call_webhook => ["https://requestb.in"]}
testcon.create_integration(int_opts)
```

###### Updating a Webhook Integration
```
int_opts = {}
int_opts[:integration_id] = <integration_id>
int_opts[:state] = 'active'
int_opts[:config] = {:post_call_webhook => ["https://requestb.in?test=12345"]}
testcon.update_integration(int_opts)
```

###### Disabling an Integration
```
int_opts = {}
int_opts[:integration_id] = <integration_id>
testcon.disable_integration(int_opts)
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mhoskiso/callrail. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Callrail project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/callrail/blob/master/CODE_OF_CONDUCT.md).
