class User < ActiveRecord::Base
  has_many :ratings, :dependent => :destroy
  has_many :published, :class_name => "Product", :foreign_key => "publisher_id"
  has_many :comments
  attr_accessor :guid, :password, :password2, :username, :email, :form_username,
                :form_given_name, :form_family_name, :form_password, 
                :form_password2, :form_email, :consent,
                :birthdate, :gender, :website
  attr_protected :is_admin
  validates :asi_id, :presence => true
  
  PERSON_HASH_CACHE_EXPIRE_TIME = 0#15  #ALSO THIS CACHE TEMPORARILY OFF TO TEST PERFORMANCE WIHTOUT IT
  PERSON_NAME_CACHE_EXPIRE_TIME = 3.hours  ## THE CACHE IS TEMPORARILY OFF BECAUSE CAUSED PROBLEMS ON ALPHA: SEE ALSO COMMENTING OUT AT THE PLACE WHER CACHE IS USED!
  
  def self.create_to_asi(params, cookie)
    # Try to create the person to ASI
    person_hash = {:person => params.slice(:username, :password, :email).merge!({:consent => "FI1"}) }
    response = UserConnection.create_person(person_hash, cookie)

    # Pick id from the response (same id in kassi and ASI DBs)
    params[:id] = response["entry"]["id"]
    
    # Because ASI now associates the used cookie to a session for the newly created user
    # Change the cookie to nil if it was used (because now it is no more an app-only cookie) 
    Session.update_aaltoapps_cookie   if  (cookie == Session.aaltoapps_cookie)    
    
    # Add name information for the person to ASI 
    #params["given_name"] = params["given_name"].slice(0, 28)
    #params["family_name"] = params["family_name"].slice(0, 28)
    
    #UserConnection.put_attributes(params.except(:username, :email, :password, :password2, :locale, :terms, :id), params[:id], cookie)
    
    # Create locally with less attributes 
    User.create(:asi_id => params[:id])
  end
  
  def self.create(params)
    super(:asi_id => params[:asi_id])
  end
  
  def username(cookie=nil)
    username_from_person_hash(cookie)
    # No expire time, because username doesn't change (at least not yet)
    #Rails.cache.fetch("person_username/#{self.id}") {username_from_person_hash(cookie)}  
  end
  
  def username_from_person_hash(cookie=nil)
    if new_record?
      return form_username ? form_username : ""
    end
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    return person_hash["username"]
  end
  
  def given_name_or_username(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Not found!" if person_hash.nil?
    if person_hash["name"].nil? || person_hash["name"]["given_name"].blank?
      return person_hash["username"]
    end
    return person_hash["name"]["given_name"]
  end
  
  def given_name(cookie=nil)
    if new_record?
      return form_given_name ? form_given_name : ""
    end
    # We rather return the username than blank if no given name is set
    return Rails.cache.fetch("given_name/#{self.id}", :expires_in => PERSON_NAME_CACHE_EXPIRE_TIME) {given_name_or_username(cookie)}
    #given_name_or_username(cookie) 
  end
  
  def set_given_name(name, cookie)
    update_attributes({:name => {:given_name => name } }, cookie)
  end
  
  def family_name(cookie=nil)
    if new_record?
      return form_family_name ? form_family_name : ""
    end
    person_hash = get_person_hash(cookie)
    return "Not found!" if person_hash.nil?
    return "" if person_hash["name"].nil?
    return person_hash["name"]["family_name"]
  end
  
  def set_family_name(name, cookie)
    update_attributes({:name => {:family_name => name } }, cookie)
  end
  
  def street_address(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Not found!" if person_hash.nil?
    return "" if person_hash["address"].nil?
    return person_hash["address"]["street_address"]
  end
  
  def set_street_address(street_address, cookie)
    update_attributes({:address => {:street_address => street_address } }, cookie)
  end
  
  def postal_code(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Not found!" if person_hash.nil?
    return "" if person_hash["address"].nil?
    return person_hash["address"]["postal_code"]
  end
  
  def set_postal_code(postal_code, cookie)
    update_attributes({:address => {:postal_code => postal_code } }, cookie)
  end
  
  def locality(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Not found!" if person_hash.nil?
    return "" if person_hash["address"].nil?
    return person_hash["address"]["locality"]
  end
  
  def set_locality(locality, cookie)
    update_attributes({:address => {:locality => locality } }, cookie)
  end
  
  def unstructured_address(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Not found!" if person_hash.nil?
    return "" if person_hash["address"].nil?
    return person_hash["address"]["unstructured"]
  end
  
  def phone_number(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    
    return person_hash["phone_number"]
  end
  
  def set_phone_number(number, cookie)
    update_attributes({:phone_number => number}, cookie)
  end
  
  def email(cookie=nil)
    if new_record?
      return form_email ? form_email : ""
    end
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    
    return person_hash["email"]
  end
  
  def set_email(email, cookie)
    update_attributes({:email => email}, cookie)
  end
  
  def password(cookie = nil)
    if new_record?
      return form_password ? form_password : ""
    end
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    
    return person_hash["password"]
  end
  
  def set_password(password, cookie)
    update_attributes({:password => password}, cookie)
  end
  
  def description(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    
    return person_hash["description"]
  end
  
  def set_description(description, cookie)
    update_attributes({:description => description}, cookie)
  end
  
  def update_attributes(params, cookie=nil)
    if params[:preferences]
      super(params)
    else
      # change empty strings to nil
      params.each { |k,v| params[k] = nil if v == '' }
      # ASI doesn't allow these fields to be unset
      params.delete :email if params[:email].nil?
      params.delete :gender if params[:gender].nil?
      
      #Handle name part parameters also if they are in hash root level
      User.remove_root_level_fields(params, "name", ["given_name", "family_name"])
      User.remove_root_level_fields(params, "address", ["street_address", "postal_code", "locality"])
      
      if params["name"] || params[:name]
        # If name is going to be changed, expire name cache
        Rails.cache.delete("person_name/#{self.id}")
        Rails.cache.delete("given_name/#{self.id}")
      end
      UserConnection.put_attributes(params.except("password2"), asi_id, cookie)
    end
  end
  
  def get_person_hash(cookie=nil)
    cookie = Session.aaltoapps_cookie if cookie.nil?
    
    begin
      person_hash = User.cache_fetch(asi_id,cookie)
    rescue RestClient::ResourceNotFound => e
      #Could not find person with that id in ASI Database!
      return nil
    end
    
    return person_hash["entry"]
  end
  
  def is_admin?
    is_admin == 1
  end
  
  def self.cache_fetch(id,cookie)
    # FIXME: CACHING DISABLED DUE PROBLEMS AT ALPHA SERVER
    UserConnection.get_person(id, cookie)  # A line to skip the cache temporarily
    #Rails.cache.fetch(cache_key(id,cookie), :expires_in => PERSON_HASH_CACHE_EXPIRE_TIME) {PersonConnection.get_person(id, cookie)}
  end
  
  def self.remove_root_level_fields(params, field_type, fields)
    fields.each do |field|
      if params.has_key?(field) && (!params.has_key?(field_type) || !params[field_type].has_key?(field))
        params.update({field_type => Hash.new}) unless params.has_key?(field_type)
        params[field_type].update({field => params[field]})
        params.delete(field)
      end
    end
  end

end
