module ProductsHelper
	def show_welcome_info
		request.request_uri==root_path
	end

	def approval_status product
		if product.is_approved.nil?
			_("waiting for approval")
		elsif product.is_approved == true
			_("approved")
		else
			_("blocked")
		end
	end

  # Returns product list path with current request parameters (except page)
  # combined with parameters given in _params
  def products_path_with_params(_params)
    _params = params.except(:page, :controller, :action).merge(_params)
    if _params[:platform_id]
      _params[:platform] = _params.delete(:platform_id)
      platform_products_path _params
    else
      products_path _params
    end
  end
end
