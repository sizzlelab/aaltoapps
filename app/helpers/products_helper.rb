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

  def products_path_with_params(_params)
    products_path params.except(:page, :controller, :action).merge(_params)
  end
end
