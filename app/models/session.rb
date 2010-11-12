require 'json'

class Session
  attr_accessor :username
  attr_writer   :password
  attr_accessor :app_name
  attr_writer   :app_password
  attr_accessor :cookie
  attr_reader   :person_id
  
  @@aaltoapps_cookie = nil # a cookie stored for a general App-only session for AaltoApps
  @@session_uri = "#{APP_CONFIG.ssl_asi_url}/session"
  AALTOAPPS_COOKIE_CACHE_KEY = "aaltoapps_cookie"
  
  # Creates a session and logs it in to Aalto Social Interface (ASI)
  def self.create(params={})
    session = Session.new(params)
    session.login
    return session
  end

  def initialize(params={})
    self.username = params[:username]
    self.password = params[:password]
    self.app_name = params[:app_name] || APP_CONFIG.asi_app_name
    self.app_password = params[:app_password] || APP_CONFIG.asi_app_password
  end
  
  #Logs in to Aalto Social Interface (ASI)
  def login(params={})
    params = {:session => {}}
    
    # if both username and password given as parameters or instance variables
    if ((@username && @password) || (params[:username] && params[:password]))
      params[:session][:username] = params[:username] || @username
      params[:session][:password] = params[:password] || @password
    end
    params[:session][:app_name] = @app_name || APP_CONFIG.asi_app_name
    params[:session][:app_password] = @app_password || APP_CONFIG.asi_app_password

    resp = RestHelper.make_request(:post, @@session_uri, params , nil, true)

    #@headers["Cookie"] = resp[1].headers[:set_cookie].to_
    @cookie = resp[1].cookies
    @person_id = resp[0]["entry"]["user_id"]
  end
  
  # A class method for destroying a session based on cookie
  def self.destroy(cookie)
    begin
      resp = RestHelper.make_request(:delete, @@session_uri, {:cookies => cookie}, nil, true)
    rescue RestClient::ResourceNotFound => e
      # If resource is not found, the session is no more valid, so can be considered destroyed
    end
  end
  
  def destroy
    Session.destroy(@cookie)
  end
  
  #a general app-only session cookie that maintains an open session to ASI for AaltoApps
  #Stored in cache to have the same cookie available between pageloads
  def self.aaltoapps_cookie
    if @@aaltoapps_cookie.nil?
      @@aaltoapps_cookie = Rails.cache.fetch(AALTOAPPS_COOKIE_CACHE_KEY) {update_aaltoapps_cookie}
    end
    return @@aaltoapps_cookie
  end
  
  #this method can be called, if aaltoapps_cookie is not valid anymore
  def self.update_aaltoapps_cookie
    Rails.logger.debug "Updating AaltoApps-cookie from ASI"
    @@aaltoapps_cookie = Session.create.cookie
    Rails.cache.write(AALTOAPPS_COOKIE_CACHE_KEY, @@aaltoapps_cookie)
    return @@aaltoapps_cookie
  end
  
  # Used for tests
  def self.set_aaltoapps_cookie(new_cookie)
    @@aaltoapps_cookie = new_cookie
    Rails.cache.write(AALTOAPPS_COOKIE_CACHE_KEY, @@aaltoapps_cookie)
  end
  
  # Posts a GET request to ASI for this session
  def check
    begin
      return RestHelper.get(@@session_uri,{:cookies => @cookie})
    rescue RestClient::ResourceNotFound => e
      return nil
    end
  end
  
end
