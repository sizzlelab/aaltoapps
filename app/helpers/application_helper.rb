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
    AaltoApps::Application::CAS_ENABLED
  end

  # Passes each member of list to block and returns the concatenated results
  # with the given separators between items.
  #
  # opts:
  # separator::  separator between elements (default ', ' or ',' if
  #              :nowrap or :surround in use)
  # last_separator::  different separator in the last place (e.g. " and ")
  #                   (default = same as :separator)
  # nowrap::  Surround each item (except the last) and the separator
  #           after it with a HTML element that prevents line break between
  #           the item and the separator. Also prevents line breaks in the
  #           item; don't use with long list items.
  # surround::  like +nowrap+, but with custom values
  def map_join(list, *opts, &block)
    options = opts.extract_options!
    if options[:nowrap]
      options[:surround] = [raw('<span style="white-space: nowrap;">'), raw(''), raw('</span> ')]
    end
    separator      = options[:separator]      || opts[0] || raw(options[:surround] ? ',' : ', ')
    last_separator = options[:last_separator] || opts[1] || separator

    results = list.map &block
    case results.length
      when 0 then ''
      when 1 then results[0]
      else
        # Array#join doesn't support html_safe => concatenate with inject
        if options[:surround]
          s1,s2,s3 = options[:surround]
          s1 + results[0..-2].inject { |a,b| a.to_s + s2 + separator + s3 + s1 + b.to_s } +
            s2 + last_separator + s3 + results.last
        else
          results[0..-2].inject {|a,b| a.to_s + separator + b.to_s } + last_separator + results.last
        end
    end
  end

  # Calls #map_join using output captured from the part of template inside block.
  def capture_map_join(list, *args, &block)
    if respond_to?(:is_haml?) && is_haml?
      # don't let haml insert unwanted whitespaces
      map_join(list, *args) {|item| raw capture(item, &block).chomp }
    else
      map_join(list, *args) {|item| capture item, &block }
    end
  end

  # convenience method for #map_join(..., +:nowrap=>true+, ...)
  def map_join_nowrap(list, *args, &block)
    options = args.extract_options!
    map_join(list, *args, options.merge(:nowrap => true), &block)
  end

  # convenience method for #capture_map_join(..., +:nowrap=>true+, ...)
  def capture_map_join_nowrap(list, *args, &block)
    options = args.extract_options!
    capture_map_join(list, *args, options.merge(:nowrap => true), &block)
  end

#  def x(list, separator = ', ', last_separator = separator, &block)
#    a = '<span class="value-and-separator">'
#    b = '</span>'
#    results = list[0..-2].map { |value| a + block.call(value) + b }
#    case results.length
#      when 0 then ''
#      when 1 then results[0]
#      else
#        # Array#join doesn't support html_safe => concatenate with inject
#        results[0..-2].inject {|a,b| a.to_s + separator + b.to_s } + last_separator + results.last
#    end
#  end
end
