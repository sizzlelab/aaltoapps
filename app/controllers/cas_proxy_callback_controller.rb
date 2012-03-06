# Load CasProxyCallbackController from rubycas-client gem.
# The controller defines a single action: receive_pgt, which receives
# proxy-granting ticket from CAS server.

if AaltoApps::Application::CAS_ENABLED
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

else
  # cas not enabled => create an empty controller so that proper 404 errors
  # are generated if someone tries to use it
  class CasProxyCallbackController < ActionController::Base; end
end
