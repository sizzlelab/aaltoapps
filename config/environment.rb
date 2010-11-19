# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
AaltoApps::Application.initialize!

Object.send(:include,FastGettext::Translation)
FastGettext.add_text_domain('frontend',:path=>'locale')
