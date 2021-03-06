# This file is based on the corresponding file in Kassi project
# (http://github.com/sizzlelab/kassi) released under MIT license.
# Copyright (c) 2010 OtaSizzle, Aalto University
# Copyright (c) 2010-2012 Aalto University and the authors

require 'rest_client'
require "benchmark"

module RestHelper

  def self.event_id
    Thread.current[:event_id]
  end

  def self.event_id=(id)
    Thread.current[:event_id] = id
  end
  
  def self.get(url, headers=nil)
    make_request(:get, url, headers)
  end
  
  def self.delete(url, headers=nil)
    make_request(:delete, url, headers)
  end
  
  def self.post(url, params=nil, headers=nil)
    make_request(:post, url, params, headers)
  end
  
  def self.put(url, params=nil, headers=nil)
    make_request(:put, url, params, headers)
  end

  def self.make_request(method, url, params=nil, headers=nil, return_full_response=false, no_redirects=false)
    cookie_used_for_call = nil #this is used if getting unauthorized response
    ((method.to_sym == :post || method.to_sym == :put) ? headers : params).tap do |hdr|
      if hdr
        cookie_used_for_call = hdr[:cookies]
        
        # workaround for rest_client's broken cookie handling:
        cookies = hdr.delete(:cookies)
        hdr['Cookie'] = cookies.map { |k,v| "#{k}=#{v}" }.join(';') if cookies
      end
    end
    
    raise ArgumentError.new("Unrecognized method #{method} for rest call") unless ([:get, :post, :delete, :put].include?(method))

    begin
      begin
        response = call(method, url, params, headers, no_redirects)

      rescue RestClient::RequestTimeout => e
        # In case of timeout, try once again
        Rails.logger.error { "Rest-client reported a timeout when calling #{method} for #{url} with params #{params}. Trying again..." }
        response = call(method, url, params, headers, no_redirects)
      end
    
    rescue RestClient::Unauthorized, RestClient::Forbidden => e
      error = case e
        when RestClient::Unauthorized then 'unauthorized'
        when RestClient::Forbidden    then 'forbidden'
      end
      Rails.logger.error { "Rest-client #{error} when calling #{method} for #{url}."}

      # if the call was made with AaltoApps-cookie, try renewing it      
      if (cookie_used_for_call == Session.aaltoapps_cookie)
         Rails.logger.info "Renewing AaltoApps-cookie and trying again..."
         new_cookie = Session.update_aaltoapps_cookie
         if method.to_sym == :get || method.to_sym == :delete
           params.merge!({:cookies => new_cookie})
         else
           headers.merge!({:cookies => new_cookie})
         end
         response = call(method, url, params, headers, no_redirects)
      else
        # Logged in as user, but the session has expired or is otherwise unvalid
        # this is handled in application_controller
        Rails.logger.info "Expired cookie (unauthorized) was for user-session. Logging out and redirecting to root_path"
        raise e
      end
    end
    
    unless return_full_response
      return JSON.parse(response.body)
    else
      return [JSON.parse(response.body), response]
    end
  end
  
  private 
  
  def self.call(method, url, params=nil, headers=nil, no_redirects=false)
    handle_result = if no_redirects
      Proc.new do |response, request, result, &block|
        if (300...400).include? response.code
          response  # return the result without processing it any further
        else
          response.return!(request, result, &block)  # continue processing normally
        end
      end
    end

    response = nil
    time = Benchmark.realtime do
      response = case method    
        when :get, :delete
          if (event_id)
            if url.match(/\?/)
              addition = "&event_id=#{event_id}"
            else
              addition = "?event_id=#{event_id}"
            end
            url += addition
          end
          RestClient.try(method, url, params, &handle_result)
        when :post, :put
          if (event_id)
            params.merge!(:event_id => event_id)
          end
          RestClient.try(method, url, params, headers, &handle_result)
      end
    end
    Rails.logger.info "ASI Call: (#{(time*1000).round}ms) #{method} #{url} (#{Time.now})"
    return response
    
  end
end
