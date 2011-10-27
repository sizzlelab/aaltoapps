require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'yaml'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module AaltoApps
  class Application < Rails::Application

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Markdown parsing and rendering options
    # (see http://rdoc.info/github/tanoku/redcarpet/master/Redcarpet#instance_attr_details)
    ::REDCARPET_OPTIONS = [
      :autolink,    # automatically convert URLs to links
      :filter_html, # no raw HTML allowed
      :fenced_code, # allow ```-syntax for code blocks
      :hard_wrap,   # convert line breaks to <br> (since we don't allow raw HTML)
      :no_image,    # no inline images
      :safelink,    # no unknown URL types allowed
    ]

    # load local config file
    app_conf = YAML.load_file("#{Rails.root}/config/aaltoapps_config.yml")[Rails.env].symbolize_keys
    APP_CONFIG = OpenStruct.new(app_conf.except(:rails_config))

    # load cas client library if needed
    CAS_ENABLED = !! app_conf[:rails_config].andand['rubycas']
    require 'rubycas-client-rails' if CAS_ENABLED

    # merge local config values into Rails configuration
    merge_config = lambda do |app_config, data|
      data.each do |key, value|
        if value.is_a? Hash
          app_config[key] = ActiveSupport::OrderedOptions.new  unless app_config.has_key? key
          merge_config.call(app_config[key], value)
        else
          app_config[key] = value
        end
      end
    end
    app_conf[:rails_config].andand.each do |key, value|
      if value.is_a? Hash
        merge_config.call(config.send(key), value)
      else
        config.send("#{key}=", value)
      end
    end
  end
end
