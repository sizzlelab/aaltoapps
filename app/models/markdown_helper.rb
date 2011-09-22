# Helper for models with data in Markdown format
module MarkdownHelper

  module ClassMethods

    # Creates a method that returns parsed HTML for each field.
    def markdown_fields(*fields)
      fields.each do |field|
        define_method("#{field}_html") { |*args| markdown_field_as_html field, *args }
      end
    end
  end

  def self.included(includer)
    includer.extend ClassMethods
  end

  private

  def markdown_field_as_html(field, *options)
    markdown = send field
    if markdown.blank?
      nil
    else
      allowed_options = [:no_links, :no_image]
      # parse both hash and array options
      hash = options.extract_options!
      rc_opts = (Set.new(options) & allowed_options) | REDCARPET_OPTIONS
      hash.slice(allowed_options).each do |opt, val|
        rc_opts.send(val ? :add : :delete, opt)
      end
      Redcarpet.new(markdown, *rc_opts).to_html.html_safe
    end
  end

end
