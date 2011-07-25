module UsersHelper
  def user_link(user)
    username = user.username
    if username
      link_to username, user, :class => 'user-link user-link-normal'
    else
      # unknown user (e.g. user deleted)
      content_tag :span, s_('user_link|unknown'), :class => 'user-link user-link-undefined user-link-unknown'
    end
  rescue SystemCallError
    # error in ASI connection
    content_tag :span, s_('user_link|error!'), :class => 'user-link user-link-undefined user-link-error'
  end
end
