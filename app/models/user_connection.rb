# This file is based on the file app/models/person_connection.rb in Kassi
# project (http://github.com/sizzlelab/kassi) released under MIT license.
# Copyright (c) 2010 OtaSizzle, Aalto University
# Copyright (c) 2010-2012 Aalto University and the authors

# This is a separate class to handle remote connection to ASI database where the
# actual information of user model is stored.
# 
# In practise we use the REST interface as described in ASI documentation at
# #{APP_CONFIG.asi_url}

class UserConnection 
  include RestHelper

  def self.create_person(params, cookie)
    return RestHelper.make_request(:post, "#{APP_CONFIG.asi_url}/people", params, {:cookies => cookie})
  end

  def self.get_person(id, cookie)
    return RestHelper.make_request(:get, "#{APP_CONFIG.asi_url}/people/#{id}/@self", {:cookies => cookie})
  end

  def self.find_people(params, cookie)
    q = case params
      when Hash then '?' + params.map { |k,v| CGI::escape(k.to_s) + '=' + CGI::escape(v.to_s) }.join('&')
      when String then params
      else ''
    end
    return RestHelper.make_request(:get, "#{APP_CONFIG.asi_url}/people#{q}", {:cookies => cookie} )
  end

  def self.get_pending_friend_requests(id, cookie)
    return RestHelper.make_request(:get, "#{APP_CONFIG.asi_url}/people/#{id}/@pending_friend_requests", {:cookies => cookie})
  end

  def self.put_attributes(params, id, cookie)
    return RestHelper.make_request(:put, "#{APP_CONFIG.asi_url}/people/#{id}/@self", {:person => params}, {:cookies => cookie})
  end

  def self.update_avatar(image, id, cookie)
    # Transform cookie to a string with "=" for HTTPClient
    cookie = "#{cookie.keys[0]}=#{cookie.values[0]}"

    response = HTTPClient.post("#{APP_CONFIG.asi_url}/people/#{id}/@avatar", { :file => image }, {'Cookie' => cookie})
    if response.status != 200
      raise Exception.new(JSON.parse(response.body.content)["messages"])
    end
  end   
end
