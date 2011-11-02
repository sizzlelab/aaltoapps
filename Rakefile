#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
begin
  require 'vlad'
  Vlad.load :scm => :git
rescue LoadError
  # do nothing
end

if Rails.env.development?
  # gettext_i18n_rails contains a rake task for extracting translatable strings.
  # It is only used for its rake tasks and only in development environment.
  require 'gettext_i18n_rails'
  ENV['TEXTDOMAIN'] = 'aaltoapps'

  require 'rails-i18n-updater'
end

AaltoApps::Application.load_tasks
