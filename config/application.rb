require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'yaml'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module AaltoApps
  class Application < Rails::Application

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

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
    app_conf[:rails_config].each do |key, value|
      merge_config.call(config.send(key), value)
    end
  end
end
