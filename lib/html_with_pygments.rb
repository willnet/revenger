class HtmlWithPygments < Redcarpet::Render::HTML
  def block_code(code, language)
    Pygments.highlight(code, lexer: language)
  rescue Albino::ShellArgumentError
    code
  end
end
