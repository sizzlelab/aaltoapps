class PagesController < ApplicationController

  # show a static (or semi-static) page
  def show
    page = params[:id]

    # check that page id doesn't contain dangerous characters that an
    # attacker could use to render other controllers' view templates
    raise PageNotFound, "Invalid characters in page id (#{page})" if page =~ /[^a-zA-Z0-9_\-]/

    authorize! :show_page, page

    begin
      # render the requested page template
      # don't use layout if this is an AJAX request
      render :action => page, :layout => !request.xhr?
    rescue ActionView::MissingTemplate => e
      raise PageNotFound, e
    end
  end

end
