module ProductsHelper

  # returns localized approval status for given Product or status string
  def approval_status(param)
    param = param.approval_state if param.is_a?(Product)
    case param
      when 'submitted' then _('submitted')
      when 'pending'   then _('waiting for approval')
      when 'published' then _('published')
      when 'blocked'   then _('blocked')
    end
  end

  # Returns product list path with current request parameters (except page)
  # combined with parameters given in _params
  def products_path_with_params(_params)
    url_for( params.except(:page).
             merge(:controller => 'products', :action => 'index').
             merge(_params) )
  end

  def published_products_tag_cloud(css_class_list, &block)
    tag_cloud( Product.accessible_by(current_ability)
                 .where(:products => {:approval_state => 'published'})
                 .top_tags(),
               css_class_list, &block )
  end
end
