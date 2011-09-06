# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
AaltoApps::Application.initialize!

Object.send(:include,FastGettext::Translation)
FastGettext.add_text_domain('frontend', :path => 'config/locales/gettext', :type => :po)

# add localized partials directory to view path
[ActionController::Base, ActionMailer::Base].each do |klass|
  klass.class_eval do
    prepend_view_path Rails.root + 'config/locales/partials'
  end
end

# Set Haml output format to xhtml.
# XHTML is used in the mobile site, but Haml doesn't allow setting this on a
# per-request basis, so we'll just have to use it on the regular site as well.
# In practice the only difference is that empty tags are closed unnecessarily.
Haml::Template.options[:format] = :xhtml
