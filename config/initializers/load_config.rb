require 'yaml'
require 'ostruct'
APP_CONFIG = OpenStruct.new(YAML.load_file("#{Rails.root}/config/aaltoapps_config.yml")[Rails.env].symbolize_keys)