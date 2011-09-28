source 'http://rubygems.org'

gem 'rails', '~> 3.1.1.rc1' # >3.1.1.rc1 needed because of rails issue #1339

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

gem 'jquery-rails'

gem 'haml'
gem 'andand'
gem 'sqlite3-ruby', :require => 'sqlite3', :group => :development
gem 'pg'
gem 'ruby-debug19'
gem 'rest-client'
gem "will_paginate", "~> 3.0.pre2"
gem 'vlad'
gem 'vlad-git'
gem 'fast_gettext'
gem 'rails-i18n-updater'
gem "paperclip", :git => "http://github.com/thoughtbot/paperclip.git"
gem 'routing-filter'
gem 'cancan'
gem 'acts-as-taggable-on'
gem 'redcarpet'
gem 'rubycas-client-rails', :require => false

# these are used to extract translatable strings from code
group :development, :test do
  gem 'gettext_i18n_rails', :require => false
  gem 'gettext', :require => false
  gem 'ruby_parser', :require => false
end

# enable Wirble in rails console if installed
gem 'wirble', :require => false, :group => :development

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'rspec-rails', '>= 2.1.0'
  gem 'cucumber', '>= 0.9.4'
  gem 'webrat'
  gem 'railroady'
end
