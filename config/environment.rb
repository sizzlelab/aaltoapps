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

# set sass/scss compiler output directory
Sass::Plugin.options[:css_location] = Rails.root + 'public/stylesheets/generated'
