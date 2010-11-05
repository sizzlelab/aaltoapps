# An api for ASI REST interface
# Needs a database table Variables (key = string, value = string) and a model for it
class AsiSession
  # Login to ASI
  # Required params: :username, :password
  def login(params)
    required_params = [:username, :password]
    if required_params.all?{|req_param| params.has_key?(req_param)}
      response = RestClient.post asi_uri('session'), 
        :session => { 
          :app_name => asi_app_name, 
          :app_password => asi_app_password, 
          :username => params[:username], 
          :password => params[:password] }
      return response
    else
      raise "Missing parameter(s)"
    end
  end
  
  # Register a new user to ASI
  # Required params: :username, :email, :password, :is_association, :consent
  def register(params)
    required_params = [:username, :email, :password, :is_association, :consent]
    if required_params.all?{|req_param| params.has_key?(req_param)}
      session = open_application_session
      begin
        response = RestClient.post asi_uri('people'), {:person => params}, {:cookies => session}
      rescue RestClient::RequestFailed => e
        raise e.response
      end
      close_session(session)
      return response
    else
      raise "Missing parameter(s)"
    end
  end
  
  def edit
  end
  
private

  def open_application_session
    response = RestClient.post asi_uri('session'), :session => { :app_name => asi_app_name, :app_password => asi_app_password }
    return response.cookies
  end
  
  def close_session(session)
    response = RestClient.delete asi_uri('session'), :cookies => session
    return response
  end
  
  def asi_uri(path)
    return '%{server}/%{path}' % { :server => asi_server, :path => path }
  end
  
  def asi_server
    return Variable.find_by_key('asi_server').value
  end
  
  def asi_app_name
    return Variable.find_by_key('asi_app_name').value
  end
  
  def asi_app_password
    return Variable.find_by_key('asi_app_password').value
  end
end