# Helper for models with data in Markdown format
module MarkdownHelper

  module ClassMethods

    # Creates a method that returns parsed HTML for each field.
    def markdown_fields(*fields)
      fields.each do |field|
        define_method("#{field}_html") { markdown_field_as_html field }
      end
    end
  end

  def self.included(includer)
    includer.extend ClassMethods
  end

  private

  def markdown_field_as_html(field)
    markdown = send field
    if markdown.blank?
      nil
    else
      Redcarpet.new(markdown, *REDCARPET_OPTIONS).to_html.html_safe
    end
  end

end
