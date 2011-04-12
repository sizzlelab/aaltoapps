class User < ActiveRecord::Base
  has_many :ratings, :dependent => :destroy
  has_many :published, :class_name => "Product", :foreign_key => "publisher_id"
  has_many :comments
  attr_protected :is_admin
  validates :asi_id, :presence => true
  validates :password, :confirmation => true
  # terms == the language of the accepted terms and conditions
  validates :terms, :acceptance => { :accept => I18n.locale }
  attr_accessor :terms
  
  PERSON_HASH_CACHE_EXPIRE_TIME = 0#15  #ALSO THIS CACHE TEMPORARILY OFF TO TEST PERFORMANCE WIHTOUT IT
  PERSON_NAME_CACHE_EXPIRE_TIME = 3.hours  ## THE CACHE IS TEMPORARILY OFF BECAUSE CAUSED PROBLEMS ON ALPHA: SEE ALSO COMMENTING OUT AT THE PLACE WHER CACHE IS USED!

  # supported ASI attributes:

  # read-only
  ASI_RO_ATTRIBUTES = [:username, :updated_at]

  # read/write
  ASI_RW_ATTRIBUTES = [:name, :address, :phone_number, :email,
                       :description, :gender, :birthdate,
                       :website, :phone_number, :irc_nick, :msn_nick]

  # write-only
  ASI_WO_ATTRIBUTES = [:password, :consent]

  # nested read/write attributes
  # these are accessed using the innermost name
  ASI_RW_NESTED_ATTRIBUTES = {
    :name => [:family_name, :given_name],
    :address => [:postal_code, :street_address, :locality],
  }

  # attributes that cannot be unset
  ASI_NONUNSETTABLE_ATTRIBUTES = Set.new [:password, :email, :gender]

  # make getters for readable ASI attributes
  (ASI_RO_ATTRIBUTES + ASI_RW_ATTRIBUTES).each do |attr|
    define_method attr do
      asi_attributes[attr] ||= begin
        p = get_person_hash
        p && p[attr.to_s]
      end
    end
  end

  # make setters for writable ASI attributes
  (ASI_WO_ATTRIBUTES + ASI_RW_ATTRIBUTES).each do |attr|
    define_method "#{attr}=" do |val|
      val = nil if val == ''
      # Set value. If nil and the attribute is non-unsettable, don't change the value.
      asi_attributes[attr.to_s] = val unless val.nil? && ASI_NONUNSETTABLE_ATTRIBUTES.member?(attr)
    end
  end

  # make getters and setters for nested attributes
  ASI_RW_NESTED_ATTRIBUTES.each do |attr, subattrs|
    subattrs = [subattrs] unless subattrs.is_a? Enumerable
    attr_s = attr.to_s
    subattrs.each do |subattr|
      define_method subattr do
        a = self.send(attr)
        a && a[subattr.to_s]
      end

      define_method "#{subattr}=" do |val|
        val = nil if val == ''
        asi_attributes[attr_s] ||= Hash.new
        asi_attributes[attr_s][subattr.to_s] = val
      end
    end
  end

  # reader for locally set password
  attr_reader :password

  # readers for special nested unstructured fields:

  def unstructured_name
    n = name
    n && n['unstructured']
  end

  def unstructured_address
    a = name
    a && a['unstructured']
  end

  attr_writer :asi_cookie
  def asi_cookie
    @asi_cookie || Session.aaltoapps_cookie
  end

  def self.create_to_asi(params, cookie)
    # Try to create the person to ASI
    person_hash = {
      :person => params.slice(:username, :password, :email).
                        merge!(:consent => APP_CONFIG.consent_versions[I18n.locale])
    }
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

  def is_admin?
    is_admin
  end

  def save(*)
    save_asi_data
    super
  end

  # clear changed ASI attributes on reload
  def reload
    @asi_attributes.clear
    super
  end


  private

  def self.cache_fetch(id,cookie)
    # FIXME: CACHING DISABLED DUE PROBLEMS AT ALPHA SERVER
    UserConnection.get_person(id, cookie)  # A line to skip the cache temporarily
    #Rails.cache.fetch(cache_key(id,cookie), :expires_in => PERSON_HASH_CACHE_EXPIRE_TIME) {PersonConnection.get_person(id, cookie)}
  end


  def asi_attributes
    @asi_attributes ||= Hash.new
  end

  def save_asi_data
    if !@asi_attributes.empty?
      params = @asi_attributes.dup

      if params["name"] || params[:name]
        # If name is going to be changed, expire name cache
        Rails.cache.delete("person_name/#{self.id}")
        Rails.cache.delete("given_name/#{self.id}")
      end
      UserConnection.put_attributes(params, asi_id, asi_cookie)
    end

    true
  end

  def get_person_hash
    begin
      person_hash = User.cache_fetch(asi_id, asi_cookie)
    rescue RestClient::ResourceNotFound => e
      #Could not find person with that id in ASI Database!
      return nil
    end

    return person_hash["entry"]
  end

end
