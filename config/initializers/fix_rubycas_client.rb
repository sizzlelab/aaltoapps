if AaltoApps::Application::CAS_ENABLED
  # monkey-patch RubyCAS-Client's logout_url method to add return url as an
  # url parameter so that CAS server can provide link back to the application
  module CASClient
    class Client
      attr_accessor :logout_return_url
      alias_method :orig_logout_url, :logout_url
      def logout_url(destination_url = nil, follow_url = logout_return_url)
        orig_logout_url(destination_url, follow_url)
      end
    end
  end
end
