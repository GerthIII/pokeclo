require "kramdown"
require "rouge"
require "kramdown-parser-gfm"

module ApplicationHelper
  def render_markdown(text)
    Kramdown::Document.new(text, input: 'GFM', syntax_highlighter: "rouge").to_html
  end
end
