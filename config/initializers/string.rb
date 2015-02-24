class String
  def markdown
    Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true).render(self).html_safe
  end
end
