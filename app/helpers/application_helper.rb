module ApplicationHelper

  # create a properly formatted link to tag's product list page
  def tag_link(tag, link_body=nil)
    name = tag.name
    link_body ||= name
    name = "\"#{name}\""  if name.include?(ActsAsTaggableOn::TagList::delimiter)
    link_to link_body, tag_products_path(name)
  end

  def published_products_tag_cloud(css_class_list, &block)
    tag_cloud( Product.top_tags().where(:products => {:approval_state => 'published'}),
               css_class_list, &block )
  end
end