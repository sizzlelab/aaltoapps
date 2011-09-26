# Load CasProxyCallbackController from rubycas-client gem.
# The controller defines a single action: receive_pgt, which receives
# proxy-granting ticket from CAS server.

# rubycas-filter/rubycas-filter-rails compatibility hack
module CASClient
  module Frameworks
    module Rails
      class Filter < RubyCAS::Filter; end
    end
  end
end

require 'casclient/frameworks/rails/cas_proxy_callback_controller'

# Rails 3 compatibility hack
class CasProxyCallbackController
  RAILS_ROOT = ::Rails.root
end
