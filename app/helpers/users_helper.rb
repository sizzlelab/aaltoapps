module UsersHelper
  def user_link(user, type=:link)
    username = user.username
    if username
      case type
      when :nolink
        content_tag :span, username, :class => 'user-link user-link-noerror user-link-nolink'
      else
        link_to username, user, :class => 'user-link user-link-noerror user-link-normal'
      end
    else
      # unknown user (e.g. user deleted)
      content_tag :span, s_('user_link|unknown'), :class => 'user-link user-link-undefined user-link-unknown'
    end
  rescue SystemCallError, RestClient::Exception
    # error in ASI connection
    content_tag :span, s_('user_link|error!'), :class => 'user-link user-link-undefined user-link-error'
  end
end
