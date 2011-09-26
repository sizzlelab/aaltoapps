module ApplicationHelper

  # create a properly formatted link to tag's product list page
  def tag_link(tag, link_body=nil)
    name = tag.name
    link_body ||= name
    name = "\"#{name}\""  if name.include?(ActsAsTaggableOn::TagList::delimiter)
    link_to link_body, tag_products_path(name)
  end

  # Replace occurrences of [[...]] with html links to the specified location.
  # Used with localizable strings.
  def substitute_links(text, *link_to_args)
    raw html_escape(text).
      to_str.  # convert SafeBuffer to String so that gsub works
      gsub(/\[\[(.*?)\]\]/) { link_to $1, *link_to_args }
  end

  def cas_enabled?
    !! AaltoApps::Application.config.try(:rubycas).try(:cas_base_url)
  end

  # Passes each member of list to block and returns the concatenated results
  # with the given separators between items.
  def each_join(list, separator = ', ', last_separator = separator, &block)
    results = list.map &block
    case results.length
      when 0 then ''
      when 1 then results[0]
      else
        # Array#join doesn't support html_safe => concatenate with inject
        results[0..-2].inject {|a,b| a.to_s + separator + b.to_s } + last_separator + results.last
    end
  end

  # Calls #each_join using output captured from the part of template inside block.
  def capture_each_join(*args, &block)
    if respond_to?(:is_haml?) && is_haml?
      # don't let haml insert unwanted whitespaces
      each_join(*args) {|item| raw capture(item, &block).chomp }
    else
      each_join(*args) {|item| capture item, &block }
    end
  end
end
