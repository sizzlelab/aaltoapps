class User < ActiveRecord::Base
  has_many :ratings, :dependent => :destroy
  has_many :published, :class_name => "Product", :foreign_key => "publisher_id"
  has_many :comments
  attr_protected :is_admin, :receive_admin_email
  validates :username, :password, :presence => { :on => :create }
  validates :terms, :acceptance => { :on => :create }
  validates :password, :confirmation => { :if => Proc.new { |user| user.password.present? } }
  validates :email, :presence => true
  attr_accessor :terms, :no_asi_fetch
  
  PERSON_HASH_CACHE_EXPIRE_TIME = 0#15  #ALSO THIS CACHE TEMPORARILY OFF TO TEST PERFORMANCE WIHTOUT IT
  PERSON_NAME_CACHE_EXPIRE_TIME = 3.hours  ## THE CACHE IS TEMPORARILY OFF BECAUSE CAUSED PROBLEMS ON ALPHA: SEE ALSO COMMENTING OUT AT THE PLACE WHER CACHE IS USED!

  # supported ASI attributes:

  # read-only
  ASI_RO_ATTRIBUTES = [:username]

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
  ASI_NONUNSETTABLE_ATTRIBUTES = Set.new [:password, :gender]

  def initialize(attr_values={})
    _asi_id, self.asi_cookie, self.terms, self.password_confirmation, self.no_asi_fetch =
      [:asi_id, :asi_cookie, :terms, :password_confirmation, :no_asi_fetch].map { |attr|
        attr_values.delete(attr) || attr_values.delete(attr.to_s)
      }

    # set nested attributes if given as nested hash entries
    ASI_RW_NESTED_ATTRIBUTES.each do |attr, subattrs|
      subattr_values = attr_values.delete(attr) || attr_values.delete(attr.to_s)
      if subattr_values
        subattrs = [subattrs] unless subattrs.is_a? Enumerable
        subattrs.each do |subattr|
          self.send("#{subattr}=", subattr_values[subattr] || subattr_values[subattr.to_s])
        end
      end
    end

    # set nested attributes if given as flat hash entries
    ASI_RW_NESTED_ATTRIBUTES.values.flatten.each do |attr|
      value = attr_values.delete(attr) || attr_values.delete(attr.to_s)
      self.send("#{attr}=", value)  if value
    end

    # set all other values
    attr_values.each do |attr, value|
      asi_attributes[attr.to_s] = value
    end

    super(:asi_id => _asi_id)
  end

  # make getters for readable ASI attributes
  (ASI_RO_ATTRIBUTES + ASI_RW_ATTRIBUTES).each do |attr|
    define_method attr do
      if asi_attributes.has_key? attr.to_s
        asi_attributes[attr.to_s]
      elsif asi_id && !no_asi_fetch
        p = get_person_hash
        p && p[attr.to_s]
      end
    end
  end

  # make getters for locally set values of write-only attributes
  ASI_WO_ATTRIBUTES.each do |attr|
    define_method attr do
      asi_attributes[attr.to_s]
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

  # readers for special nested unstructured fields:

  def unstructured_name
    n = name
    n && n['unstructured']
  end

  def unstructured_address
    a = name
    a && a['unstructured']
  end

  # special reader for ASI's updated_at to prevent name collision with local updated_at
  def asi_updated_at
    asi_attributes['updated_at'] ||
      if asi_id && !no_asi_fetch
        get_person_hash['updated_at']
      else
        nil
      end
  end

  # return ASI attributes as hash
  def asi_data(include_email = false)
    hash = asi_attributes
    hash.reverse_merge!(get_person_hash)  if asi_id && !no_asi_fetch
    hash.delete('email')  unless include_email
    hash
  end

  attr_writer :asi_cookie
  def asi_cookie
    @asi_cookie || Session.aaltoapps_cookie
  end

  # Search users from ASI with given parameters. Returns User records.
  # If prevent_asi_fetch is true, the User records have no_asi_fetch set,
  # which means that the record will not try to fetch missing data from ASI
  # server.
  def self.asi_find(params={}, prevent_asi_fetch=true)
    response = UserConnection.find_people(params, Session.aaltoapps_cookie)
    if response && response['entry'].present?
      response['entry'].map do |entry|
        entry[:asi_id] = entry.delete 'id'
        entry[:no_asi_fetch] = prevent_asi_fetch
        User.new(entry)
      end
    else
      []
    end
  end

  def is_admin?
    is_admin
  end

  # clear changed ASI attributes on reload
  def reload
    @asi_attributes.clear
    super
  end

  def to_xml(options = {}, &block)
    options[:only] = Array.wrap(options[:only])
    options[:except] = Array.wrap(options[:except])
    options[:methods] = Array.wrap(options[:methods])

    if  (options[:only].empty? || options[:only].member?('asi_data') || options[:only].member?(:asi_data)) &&
        ! (options[:except].member?('asi_data') || options[:except].member?(:asi_data))
      options[:methods] |= [ :asi_data ]
    end
    if options[:only].empty?
      options[:only] = attributes.keys - options[:except].map(&:to_s)
    else
      options[:only] &= attributes.keys + attributes.keys.map(&:to_sym)
    end

    super(options, &block)
  end


  private

  # called by save, save!, update_attributes etc.
  def create_or_update(*)
    return false unless valid?

    if asi_id
      # update user information in ASI
      if @asi_attributes.present?
        params = @asi_attributes.dup

        if params["name"] || params[:name]
          # If name is going to be changed, expire name cache
          Rails.cache.delete("person_name/#{self.id}")
          Rails.cache.delete("given_name/#{self.id}")
        end
        UserConnection.put_attributes(params, asi_id, asi_cookie)
      end

    else

      # If no asi_id, try to create a new person to ASI
      person_hash = {
        :person => asi_attributes.slice(*%w(username password email)).
                                  merge!(:consent => APP_CONFIG.consent_versions[I18n.locale])
      }
      response = UserConnection.create_person(person_hash, asi_cookie)

      # Because ASI now associates the used cookie to a session for the newly created user
      # Change the cookie to nil if it was used (because now it is no more an app-only cookie)
      Session.update_aaltoapps_cookie  if asi_cookie == Session.aaltoapps_cookie

      # Pick id from the response
      self.asi_id = response["entry"]["id"]
    end

    # if language not set, set it to fallback value
    language ||= APP_CONFIG.fallback_locale

    super
  end

  def self.cache_fetch(id,cookie)
    # FIXME: CACHING DISABLED DUE PROBLEMS AT ALPHA SERVER
    UserConnection.get_person(id, cookie)  # A line to skip the cache temporarily
    #Rails.cache.fetch(cache_key(id,cookie), :expires_in => PERSON_HASH_CACHE_EXPIRE_TIME) {PersonConnection.get_person(id, cookie)}
  end


  def asi_attributes
    @asi_attributes ||= Hash.new
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
